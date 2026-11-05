using System.Diagnostics;

namespace HolmesKit.Desktop.Tests;

public class ManagementConfirmationTests
{
    [Theory]
    [InlineData("del_run", "exists", 0)]
    [InlineData("del_run", "missing", 0)]
    [InlineData("del_run", "denied", 1)]
    [InlineData("export_key", "exists", 1)]
    [InlineData("export_key", "missing", 0)]
    [InlineData("export_key", "denied", 1)]
    public async Task RegistryPrerequisiteErrors_AreNotMistakenForAbsence(string label, string state, int expected)
    {
        var root = new Services.HolmesKitPathResolver(AppContext.BaseDirectory).RootDirectory;
        var source = File.ReadAllText(Path.Combine(root, "HolmesKit.bat"));
        var block = source.Split(":" + label + "\r\n").Last();
        var command = block.Split('\n').First(x => x.TrimStart().StartsWith("powershell -NoProfile -Command"));
        var script = command[(command.IndexOf('"') + 1)..command.LastIndexOf('"')]
            .Replace("%~1", @"HKCU\Fixture").Replace("%~2", "Fixture");
        var mocks = "function Get-Item { param($LiteralPath,$EA) " +
            "if($LiteralPath -ne 'HKCU:\\Fixture'){ throw 'Wrong registry path' }; " +
            "if($env:HK_TEST_ANSWER -eq 'missing'){ throw [System.Management.Automation.ItemNotFoundException]::new('Missing') }; " +
            "if($env:HK_TEST_ANSWER -eq 'denied'){ throw [UnauthorizedAccessException]::new('Denied') }; " +
            "$k=[pscustomobject]@{}; $k | Add-Member ScriptMethod GetValueNames { @('Fixture') }; return $k }; " +
            "function Remove-ItemProperty { param($LiteralPath,$Name,$EA) Write-Output 'STUB_REMOVED' }; ";
        var info = new ProcessStartInfo("powershell.exe") { UseShellExecute = false, CreateNoWindow = true,
            RedirectStandardOutput = true, RedirectStandardError = true };
        info.ArgumentList.Add("-NoProfile"); info.ArgumentList.Add("-NonInteractive"); info.ArgumentList.Add("-EncodedCommand");
        info.ArgumentList.Add(Convert.ToBase64String(System.Text.Encoding.Unicode.GetBytes(mocks + script)));
        info.Environment["HK_TEST_ANSWER"] = state;
        using var process = Process.Start(info)!;
        var stdout = process.StandardOutput.ReadToEndAsync(TestContext.Current.CancellationToken);
        var stderr = process.StandardError.ReadToEndAsync(TestContext.Current.CancellationToken);
        await process.WaitForExitAsync(TestContext.Current.CancellationToken);
        var output = await stdout; _ = await stderr;
        Assert.Equal(expected, process.ExitCode);
        if (label == "del_run" && state == "exists") Assert.Contains("STUB_REMOVED", output);
        else Assert.DoesNotContain("STUB_REMOVED", output);
    }
    public static IEnumerable<object[]> Cases() => new[] { "apps_mgr.ps1", "startup_mgr.ps1" }
        .SelectMany(file => new[] { "Y", "y", "N", "n", "", "invalid", "Y; throw 'injection'", "<EOF>" }
            .Select(answer => new object[] { file, answer }));

    [Theory]
    [MemberData(nameof(Cases))]
    public async Task ActualManagementApprovalGate_BlocksWithoutAffirmativeInput(string file, string answer)
    {
        var root = new Services.HolmesKitPathResolver(AppContext.BaseDirectory).RootDirectory;
        var source = File.ReadAllText(Path.Combine(root, "modules", file));
        var apps = file.StartsWith("apps");
        var start = source.IndexOf(apps ? "$app = $apps[$idx - 1]" : "$entry = $allEntries[$idx - 1]", StringComparison.Ordinal);
        var end = source.IndexOf(apps ? "try {" : "if ($entry.Type", start, StringComparison.Ordinal);
        Assert.True(start > 0 && end > start);
        var gate = source[start..end];
        // Only the actual selection + approval block, never any native operation implementation.
        Assert.DoesNotContain("Start-Process", gate);
        Assert.DoesNotContain("Toggle-", gate);
        var script = "function Read-Host { param($Prompt) if($env:HK_TEST_ANSWER -eq '<EOF>'){ throw 'Input unavailable' }; return $env:HK_TEST_ANSWER }; " +
            "$apps=@(@{DisplayName='Fixture'}); $allEntries=@(@{Name='Fixture';Locked=$false}); $idx=1; foreach($once in @(1)){ " + gate + "; Write-Output 'AUTHORIZED'; }";
        var info = new ProcessStartInfo("powershell.exe") { UseShellExecute = false, CreateNoWindow = true,
            RedirectStandardOutput = true, RedirectStandardError = true };
        info.ArgumentList.Add("-NoProfile"); info.ArgumentList.Add("-NonInteractive");
        info.ArgumentList.Add("-EncodedCommand");
        info.ArgumentList.Add(Convert.ToBase64String(System.Text.Encoding.Unicode.GetBytes(script)));
        info.Environment["HK_TEST_ANSWER"] = answer;
        using var process = Process.Start(info)!;
        var output = process.StandardOutput.ReadToEndAsync(TestContext.Current.CancellationToken);
        var errors = process.StandardError.ReadToEndAsync(TestContext.Current.CancellationToken);
        await process.WaitForExitAsync(TestContext.Current.CancellationToken);
        var text = await output;
        _ = await errors;
        if (answer.Equals("Y", StringComparison.OrdinalIgnoreCase)) Assert.Contains("AUTHORIZED", text);
        else Assert.DoesNotContain("AUTHORIZED", text);
    }
}
