using System.Diagnostics;
using System.Text.RegularExpressions;
using HolmesKit.Desktop.Services;

namespace HolmesKit.Desktop.Tests;

public class RecoveryLifecycleTests
{
    [Fact]
    public async Task ActualOrchestrator_RetainsBaselineAcrossProcessesAndRejectsCorruptionAndLocking()
    {
        var root = new HolmesKitPathResolver(AppContext.BaseDirectory).RootDirectory;
        var directory = Path.Combine(Path.GetTempPath(), "HolmesKit.Lifecycle." + Guid.NewGuid().ToString("N"));
        Directory.CreateDirectory(directory);
        try
        {
            var source = File.ReadAllText(Path.Combine(root, "modules", "recovery.ps1"));
            var adapter = """
                . (Join-Path $env:HK_FIXTURE_SOURCE 'modules\recovery_core.ps1')
                function Get-HolmesRegistryScope { [pscustomobject]@{ Id='Power|Active';Category='Power';Name='Active' } }
                function Get-ItemPropertyValue { 'fixture-machine' }
                function Read-HolmesState($Item) { if($Item.Id -ne 'Power|Active'){throw 'Isolation violation'}; [IO.File]::ReadAllText((Join-Path $env:HK_FIXTURE_ROOT 'state.json')) | ConvertFrom-Json }
                function Write-HolmesState($Item,$State) { if($Item.Id -ne 'Power|Active'){throw 'Isolation violation'}; [IO.File]::WriteAllText((Join-Path $env:HK_FIXTURE_ROOT 'state.json'),($State | ConvertTo-Json -Compress)) }
                """;
            source = source.Replace(". \"$PSScriptRoot\\recovery_core.ps1\"", adapter);
            source = source.Replace("$root=Split-Path -Parent $PSScriptRoot", "$root=$env:HK_FIXTURE_ROOT");
            source = Regex.Replace(source, @"(?m)^\s*& \$env:ComSpec[^\r\n]+", "Write-HolmesState ([pscustomobject]@{Id='Power|Active'}) ([pscustomobject]@{Guid='00000000-0000-0000-0000-000000000002'}); $global:LASTEXITCODE=0");
            Assert.DoesNotContain("& $env:ComSpec", source);
            Assert.Contains("function Write-HolmesState", source);
            var fixture = Path.Combine(directory, "fixture.ps1");
            File.WriteAllText(fixture, source);
            var state = Path.Combine(directory, "state.json");
            File.WriteAllText(state, "{\"Guid\":\"00000000-0000-0000-0000-000000000001\"}");
            var legacy = Path.Combine(directory, "HolmesKit_Backups", "latest");
            Directory.CreateDirectory(legacy);
            File.WriteAllText(Path.Combine(legacy, "sentinel.reg"), "LEGACY");

            async Task<(int Code, string Output)> Run(string operation)
            {
                var info = new ProcessStartInfo("powershell.exe") { UseShellExecute=false, CreateNoWindow=true, RedirectStandardOutput=true, RedirectStandardError=true };
                foreach (var arg in new[] { "-NoProfile", "-NonInteractive", "-ExecutionPolicy", "Bypass", "-File", fixture, "-Action", "Execute", "-Operation", operation }) info.ArgumentList.Add(arg);
                info.Environment["HK_FIXTURE_ROOT"]=directory; info.Environment["HK_FIXTURE_SOURCE"]=root;
                using var p = Process.Start(info)!;
                var output=p.StandardOutput.ReadToEndAsync(TestContext.Current.CancellationToken);
                var error=p.StandardError.ReadToEndAsync(TestContext.Current.CancellationToken);
                await p.WaitForExitAsync(TestContext.Current.CancellationToken);
                return (p.ExitCode, await output + await error);
            }

            var first=await Run("power-high"); Assert.True(first.Code == 0, first.Output);
            var journal=Path.Combine(directory, "HolmesKit_Backups", "recovery", "baseline.json");
            using var envelope=System.Text.Json.JsonDocument.Parse(File.ReadAllText(journal));
            var payload=envelope.RootElement.GetProperty("Payload").GetString()!;
            var second=await Run("power-high"); Assert.True(second.Code == 0, second.Output);
            Assert.Contains("00000000-0000-0000-0000-000000000001", payload);
            Assert.Equal("LEGACY", File.ReadAllText(Path.Combine(legacy,"sentinel.reg")));
            var restore=await Run("restore-power"); Assert.True(restore.Code == 0, restore.Output);
            Assert.Contains("00000000-0000-0000-0000-000000000001", File.ReadAllText(state));
            using (var locked=File.Open(Path.Combine(Path.GetDirectoryName(journal)!,"operation.lock"),FileMode.Open,FileAccess.ReadWrite,FileShare.None))
                Assert.NotEqual(0,(await Run("power-high")).Code);
            File.WriteAllText(journal,"{}");
            Assert.NotEqual(0,(await Run("power-high")).Code);
            Assert.Contains("00000000-0000-0000-0000-000000000001", File.ReadAllText(state));
        }
        finally { Directory.Delete(directory,true); }
    }
}
