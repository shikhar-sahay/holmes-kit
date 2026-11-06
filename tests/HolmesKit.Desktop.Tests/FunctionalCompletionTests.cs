using System.Diagnostics;
using System.Text;
using HolmesKit.Desktop.Models;
using HolmesKit.Desktop.Services;

namespace HolmesKit.Desktop.Tests;

public class FunctionalCompletionTests
{
    [Theory]
    [InlineData(false, "Native stdout failure", "")]
    [InlineData(true, "Native stdout failure", "")]
    [InlineData(false, "", "Native stderr failure")]
    [InlineData(true, "", "Native stderr failure")]
    [InlineData(false, "", "")]
    [InlineData(true, "", "")]
    public void ManagementFailures_RemainVisibleWithUsefulDiagnostics(bool uninstall, string output, string error)
    {
        Exception? failure = null;
        var thread = new Thread(() =>
        {
            var root = Path.Combine(Path.GetTempPath(), "HolmesKit outcome " + Guid.NewGuid().ToString("N"));
            Directory.CreateDirectory(root);
            try
            {
                var paths = new FixturePaths(root);
                var vm = new HolmesKit.Desktop.ViewModels.MainViewModel(new HolmesKitCommandService(new ResultRunner(new(1, output, error)), paths), paths) { Confirm = (_, _) => true };
                if (uninstall) vm.UninstallCommand.Execute(new InstalledApplication { Name = "Example", UninstallData = "inert" });
                else vm.ToggleStartupCommand.Execute(new StartupEntry { Name = "Example", Status = "Enabled" });
                Assert.Equal("Failed", vm.Status);
                Assert.False(vm.IsBusy);
                Assert.Contains(vm.Activity, line => line.Contains(output.Length > 0 ? output : error.Length > 0 ? error : "exit code 1"));
            }
            catch (Exception ex) { failure = ex; }
            finally { Directory.Delete(root, true); }
        });
        thread.IsBackground = true;
        thread.SetApartmentState(ApartmentState.STA); thread.Start();
        Assert.True(thread.Join(TimeSpan.FromSeconds(10)));
        Assert.Null(failure);
    }
    [Theory]
    [InlineData("apps", "null")]
    [InlineData("apps", "[null]")]
    [InlineData("apps", "[{\"Name\":\"Example\"}]")]
    [InlineData("startup", "null")]
    [InlineData("startup", "[null]")]
    [InlineData("startup", "[{\"Name\":\"Example\",\"Type\":\"Registry\",\"Status\":null}]")]
    [InlineData("system", "null")]
    [InlineData("system", "{\"Disks\":[null]}")]
    public async Task InvalidBridgeIdentities_AreRejectedInsteadOfBecomingActionable(string action, string json)
    {
        var service = new HolmesKitCommandService(new JsonRunner(json), new FixturePaths());
        await Assert.ThrowsAsync<InvalidDataException>(async () =>
        {
            if (action == "apps") await service.GetApplicationsAsync(TestContext.Current.CancellationToken);
            else if (action == "startup") await service.GetStartupEntriesAsync(TestContext.Current.CancellationToken);
            else await service.GetSystemInfoAsync(TestContext.Current.CancellationToken);
        });
    }

    [Fact]
    public async Task OptionalStartupText_IsNormalizedWithoutChangingIdentity()
    {
        var service = new HolmesKitCommandService(new JsonRunner("[{\"Name\":\"Example\",\"Type\":\"Registry\",\"Status\":\"Enabled\",\"Command\":null,\"Source\":null}]"), new FixturePaths());
        var item = Assert.Single(await service.GetStartupEntriesAsync(TestContext.Current.CancellationToken));
        Assert.Equal("Example", item.Name);
        Assert.Equal("", item.Command);
        Assert.Equal("Unknown", item.Source);
    }

    [Theory]
    [InlineData("Enabled", "Enabled", false, true)]
    [InlineData("Disabled", "Disabled", false, true)]
    [InlineData("Enabled", "Disabled", false, false)]
    [InlineData("Disabled", "Enabled", false, false)]
    [InlineData("", "Enabled", false, false)]
    [InlineData("Enabled", "Enabled", true, false)]
    public async Task ActualStartupResolver_RejectsChangedStateBeforeMutation(string requested, string current, bool locked, bool allowed)
    {
        var script = LoadFunctions("Resolve-HolmesStartup") + """
            $requested=[pscustomobject]@{Type='Registry';Hive='HKCU';RegPath='Fixture';Name='Example';Status=$env:HK_REQUESTED}
            $current=[pscustomobject]@{Type='Registry';Hive='HKCU';RegPath='Fixture';Name='Example';Status=$env:HK_CURRENT;Locked=($env:HK_LOCKED -eq 'True')}
            try { $resolved=Resolve-HolmesStartup $requested @($current); if($resolved -ne $current){throw 'Wrong row'}; 'ALLOWED' }
            catch { 'REJECTED: '+$_.Exception.Message }
            """;
        var result = await RunPowerShell(script, new() { ["HK_REQUESTED"] = requested, ["HK_CURRENT"] = current, ["HK_LOCKED"] = locked.ToString() });
        Assert.Contains(allowed ? "ALLOWED" : "REJECTED:", result);
    }

    [Theory]
    [InlineData("")]
    [InlineData("   ")]
    [InlineData("/remove \"optional value\"")]
    public async Task ArgumentFreeUninstaller_OmitsEmptyArgumentList(string arguments)
    {
        var script = LoadFunctions("Assert-HolmesUninstallerPath", "Start-HolmesUninstaller") + """
            function Test-Path { param($LiteralPath,$PathType) return $true }
            function Start-Process {
                param($FilePath,$ArgumentList,[switch]$Wait,[switch]$PassThru)
                if($FilePath -ne 'C:\Fixture\uninstall.exe' -or -not $Wait -or -not $PassThru){throw 'Wrong invocation'}
                if([string]::IsNullOrWhiteSpace($env:HK_ARGS)) {
                    if($PSBoundParameters.ContainsKey('ArgumentList')){throw 'Empty argument list forwarded'}
                } elseif($ArgumentList -cne $env:HK_ARGS){throw 'Arguments changed'}
                return [pscustomobject]@{ExitCode=0}
            }
            $result=Start-HolmesUninstaller 'C:\Fixture\uninstall.exe' $env:HK_ARGS
            if($result.ExitCode -ne 0){throw 'Wrong result'}; 'STUB_ONLY'
            """;
        Assert.Contains("STUB_ONLY", await RunPowerShell(script, new() { ["HK_ARGS"] = arguments }));
    }

    [Fact]
    public async Task ActualEmptyApplicationEnumeration_ReturnsEmptyJsonArray()
    {
        var script = LoadFunctions() + """
            $switch=$ast.Find({param($node) $node -is [Management.Automation.Language.SwitchStatementAst]},$true)
            $clause=@($switch.Clauses | Where-Object {$_.Item1.Value -eq 'apps-list'})[0].Item2.Extent.Text
            function Get-ItemProperty { param($Path,$ErrorAction) return @() }
            & ([scriptblock]::Create($clause.Substring(1,$clause.Length-2)))
            """;
        Assert.Equal("[]", (await RunPowerShell(script, new())).Trim());
    }

    private static string LoadFunctions(params string[] names)
    {
        var preamble = """
            $ErrorActionPreference='Stop'; $ProgressPreference='SilentlyContinue'; $tokens=$null; $errors=$null
            $ast=[Management.Automation.Language.Parser]::ParseFile((Join-Path $env:HK_ROOT 'modules\gui_bridge.ps1'),[ref]$tokens,[ref]$errors)
            if($errors.Count){throw 'Bridge parse errors'}
            """;
        return preamble + "\n" + string.Join("\n", names.Select(name =>
            $"$function=$ast.Find({{param($node) $node -is [Management.Automation.Language.FunctionDefinitionAst] -and $node.Name -eq '{name}'}},$true); . ([scriptblock]::Create($function.Extent.Text))")) + "\n";
    }

    [Fact]
    public async Task CliUninstall_UsesNamedScalarTransportAfterConfirmation()
    {
        var script = """
            $ErrorActionPreference='Stop'
            $source=[IO.File]::ReadAllText((Join-Path $env:HK_ROOT 'modules\apps_mgr.ps1'))
            $start=$source.IndexOf('$encodedCommand =')
            $end=$source.IndexOf('} catch',$start)
            $body=$source.Substring($start,$end-$start).Replace('$PSScriptRoot',"(Join-Path `$env:HK_ROOT 'modules')")
            function powershell.exe {
                $nameIndex=[array]::IndexOf($args,'-NameData')
                if($nameIndex -lt 0){throw 'Missing scalar name transport'}
                $name=[Text.Encoding]::UTF8.GetString([Convert]::FromBase64String($args[$nameIndex+1]))
                if($name -cne 'Example Ω'){throw 'Wrong application'}
                $global:LASTEXITCODE=0; 'STUB_UNINSTALL_ONLY'
            }
            $app=[pscustomobject]@{DisplayName='Example Ω';UninstallString='"C:\Fixture\uninstall.exe"'}
            & ([scriptblock]::Create($body))
            """;
        Assert.Contains("STUB_UNINSTALL_ONLY", await RunPowerShell(script, new()));
    }

    [Theory]
    [InlineData("Registry", false)]
    [InlineData("Scheduler", false)]
    [InlineData("Registry", true)]
    public async Task CliStartup_DelegatesOnlyUnprotectedEntriesToSharedBridge(string type, bool locked)
    {
        var script = """
            $ErrorActionPreference='Stop'; $tokens=$null; $errors=$null
            $ast=[Management.Automation.Language.Parser]::ParseFile((Join-Path $env:HK_ROOT 'modules\startup_mgr.ps1'),[ref]$tokens,[ref]$errors)
            foreach($name in @('Toggle-RegistryEntry','Toggle-SchedulerEntry')) {
                $f=$ast.Find({param($n) $n -is [Management.Automation.Language.FunctionDefinitionAst] -and $n.Name -eq $name},$true)
                . ([scriptblock]::Create($f.Extent.Text.Replace('$PSScriptRoot',"(Join-Path `$env:HK_ROOT 'modules')")))
            }
            $script:calls=0
            function powershell.exe {
                if($args -notcontains 'startup-toggle' -or $args -notcontains '-NonInteractive'){throw 'Wrong dispatch'}
                $payload=[Text.Encoding]::UTF8.GetString([Convert]::FromBase64String($args[-1])) | ConvertFrom-Json
                if($payload.Name -cne 'Example Ω' -or $payload.Status -ne 'Enabled'){throw 'Changed identity'}
                $script:calls++; $global:LASTEXITCODE=0
            }
            $entry=[pscustomobject]@{Type=$env:HK_TYPE;Name='Example Ω';Status='Enabled';Locked=($env:HK_LOCKED -eq 'True')}
            if($env:HK_TYPE -eq 'Registry'){Toggle-RegistryEntry $entry}else{Toggle-SchedulerEntry $entry}
            'CALLS='+$script:calls
            """;
        Assert.Contains("CALLS=" + (locked ? 0 : 1), await RunPowerShell(script, new() { ["HK_TYPE"] = type, ["HK_LOCKED"] = locked.ToString() }));
    }

    [Theory]
    [InlineData("\"C:\\Fixture\\uninstall.exe\"", 0, 0)]
    [InlineData("C:\\Fixture\\uninstall.exe /remove", 0, 0)]
    [InlineData("MsiExec.exe /I{12345678-1234-1234-1234-123456789abc}", 0, 0)]
    [InlineData("\"C:\\Fixture\\uninstall.exe\"", 1602, 3)]
    [InlineData("\"C:\\Fixture\\uninstall.exe\"", 3010, 0)]
    [InlineData("\"C:\\Fixture\\uninstall.exe\"", 5, 1)]
    public async Task ActualUninstallDispatch_ReportsNativeExitWithoutRunningAnUninstaller(string command, int nativeExit, int expected)
    {
        var script = LoadFunctions("ConvertFrom-HolmesData", "Assert-HolmesUninstallerPath", "Start-HolmesUninstaller") + """
            function Get-ItemProperty { param($Path,$ErrorAction) [pscustomobject]@{DisplayName='Example';UninstallString=$env:HK_COMMAND} }
            function Test-Path { param($LiteralPath,$PathType) return $true }
            function Write-HolmesLog { param($Message) }
            function Start-Process { param($FilePath,$ArgumentList,[switch]$Wait,[switch]$PassThru) return [pscustomobject]@{ExitCode=[int]$env:HK_EXIT} }
            $Data=@([Convert]::ToBase64String([Text.Encoding]::UTF8.GetBytes($env:HK_COMMAND)),[Convert]::ToBase64String([Text.Encoding]::UTF8.GetBytes('Example')))
            $switch=$ast.Find({param($node) $node -is [Management.Automation.Language.SwitchStatementAst]},$true)
            $clause=@($switch.Clauses | Where-Object {$_.Item1.Value -eq 'app-uninstall'})[0].Item2.Extent.Text
            try { & ([scriptblock]::Create($clause.Substring(1,$clause.Length-2))) } catch { [Console]::Error.WriteLine($_.Exception.Message); exit 1 }
            """;
        var text = await RunPowerShell(script, new() { ["HK_COMMAND"] = command, ["HK_EXIT"] = nativeExit.ToString() }, expected);
        Assert.Contains(nativeExit switch { 1602 => "cancelled", 3010 => "restart required", 0 => "completed", _ => "code 5" }, text);
    }

    private static async Task<string> RunPowerShell(string script, Dictionary<string, string> environment, int expectedExit = 0)
    {
        var info = new ProcessStartInfo("powershell.exe") { UseShellExecute = false, CreateNoWindow = true, RedirectStandardOutput = true, RedirectStandardError = true };
        foreach (var arg in new[] { "-NoProfile", "-NonInteractive", "-EncodedCommand", Convert.ToBase64String(Encoding.Unicode.GetBytes(script)) }) info.ArgumentList.Add(arg);
        info.Environment["HK_ROOT"] = new HolmesKitPathResolver(AppContext.BaseDirectory).RootDirectory;
        foreach (var pair in environment) info.Environment[pair.Key] = pair.Value;
        using var process = Process.Start(info)!;
        var output = process.StandardOutput.ReadToEndAsync(TestContext.Current.CancellationToken);
        var error = process.StandardError.ReadToEndAsync(TestContext.Current.CancellationToken);
        await process.WaitForExitAsync(TestContext.Current.CancellationToken);
        var text = await output + await error;
        Assert.True(process.ExitCode == expectedExit, text);
        return text;
    }

    private sealed class JsonRunner(string json) : IProcessRunner
    {
        public Task<ProcessResult> RunAsync(ProcessRequest request, IProgress<string>? progress = null, CancellationToken cancellationToken = default) => Task.FromResult(new ProcessResult(0, json, ""));
    }
    private sealed class ResultRunner(ProcessResult result) : IProcessRunner
    {
        public Task<ProcessResult> RunAsync(ProcessRequest request, IProgress<string>? progress = null, CancellationToken cancellationToken = default) => Task.FromResult(result);
    }
    private sealed class FixturePaths(string? root = null) : IHolmesKitPathResolver
    {
        public string RootDirectory => root ?? Environment.CurrentDirectory;
        public string BatchFile => "unused.bat";
        public string BridgeScript => "unused.ps1";
        public string LogFile => Path.Combine(RootDirectory, "fixture.log");
        public void Validate() { }
    }
}
