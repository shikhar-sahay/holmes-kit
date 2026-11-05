using System.Diagnostics;
using System.Text;
using System.Text.RegularExpressions;

namespace HolmesKit.Desktop.Tests;

public class CliSafetyTests
{
    private static readonly (string Menu, string Choice, string Id)[] Operations =
    [
        ("core_menu", "1", "core-full"), ("core_menu", "2", "cleanup-temp"),
        ("core_menu", "3", "power-high"), ("core_menu", "4", "cleanup-background"),
        ("advanced_menu", "1", "ui-responsive"), ("advanced_menu", "2", "visual-performance"),
        ("advanced_menu", "3", "startup-prune"), ("advanced_menu", "4", "network-maintenance"),
        ("advanced_menu", "5", "services-cleanup"), ("advanced_menu", "6", "hibernation-disable"),
        ("gaming_menu", "1", "gaming-fps"), ("gaming_menu", "2", "gaming-latency"),
        ("gaming_menu", "3", "gaming-full"), ("restore_menu", "1", "restore-registry"),
        ("restore_menu", "2", "restore-power"), ("restore_menu", "3", "restore-services"),
        ("restore_menu", "4", "restore-hibernation"), ("restore_menu", "5", "restore-network"),
        ("restore_menu", "6", "restart-explorer"), ("apply_all", "", "apply-all")
    ];

    public static IEnumerable<object[]> MenuCases() => Operations.SelectMany(op =>
        new[] { "Y", "y", "N", "n", "", "invalid", "Y&echo BAD", "\"", "<EOF>" }
            .Select(answer => new object[] { op.Menu, op.Choice, answer }));

    [Theory]
    [MemberData(nameof(MenuCases))]
    public async Task EveryMenu_RequiresFreshExplicitApproval(string menu, string choice, string answer)
    {
        var input = (choice.Length > 0 ? choice + "\r\n" : "") + (answer == "<EOF>" ? "" : answer + "\r\n");
        var result = await Run(menu, input, prelude: "set HK_CONFIRMED=1\r\nset HK_CONFIRM=Y\r\nset HK_APPLYALL=Y");
        if (answer.Equals("Y", StringComparison.OrdinalIgnoreCase))
        {
            var id = Operations.Single(x => x.Menu == menu && x.Choice == choice).Id;
            var expected = id switch
            {
                "core-full" or "apply-all" or "cleanup-temp" => "cleanup_temp",
                "power-high" => "apply_power_plan", "cleanup-background" => "cleanup_background",
                "ui-responsive" => "ui_responsiveness_tweaks", "visual-performance" => "visual_performance_mode",
                "startup-prune" => "startup_pruning", "network-maintenance" => "network_maintenance",
                "services-cleanup" => "services_cleanup", "hibernation-disable" => "disable_hibernation",
                "gaming-fps" or "gaming-full" => "gaming_fps_tweaks", "gaming-latency" => "gaming_latency_maintenance",
                "restore-registry" => "restore_latest_registry", "restore-power" => "restore_power_defaults",
                "restore-services" => "restore_services", "restore-hibernation" => "enable_hibernation",
                "restore-network" => "restore_network_defaults", "restart-explorer" => "restart_explorer",
                _ => throw new InvalidOperationException(id)
            };
            Assert.Contains("MUTATE:" + expected, result.Output);
        }
        else Assert.DoesNotContain("MUTATE:", result.Output);
    }

    public static IEnumerable<object[]> BackupCases() => Operations.Where(x => x.Menu != "restore_menu")
        .Select(x => new object[] { x.Menu, x.Choice, x.Id });

    [Theory]
    [MemberData(nameof(BackupCases))]
    public async Task BackupFailure_BlocksEveryCliAndGuiOperation(string menu, string choice, string id)
    {
        var result = await Run(menu, (choice.Length > 0 ? choice + "\r\n" : "") + "Y\r\n", backupFails: true);
        Assert.Contains("Required backup failed", result.Output);
        Assert.DoesNotContain("MUTATE:", result.Output);
        Assert.DoesNotContain("completed successfully", result.Output);
        var gui = await Run("command_dispatch", "", backupFails: true, arguments: "--run " + id);
        Assert.NotEqual(0, gui.ExitCode);
        Assert.Contains("Required backup failed", gui.Output);
        Assert.DoesNotContain("MUTATE:", gui.Output);
    }

    [Fact]
    public async Task Authorization_IsConsumedBeforeAnotherIndependentOperation()
    {
        var result = await Run("run_confirmed", "", prelude: "set HK_CONFIRMED=1\r\ncall :run_confirmed power-high\r\ncall :run_confirmed power-high\r\nexit /b 0");
        Assert.Single(Regex.Matches(result.Output, "MUTATE:apply_power_plan"));
        Assert.Contains("Cancelled", result.Output);
    }

    [Fact]
    public async Task PartialApplyAllFailure_StopsLaterStepsAndReturnsFailure()
    {
        var result = await Run("command_dispatch", "", arguments: "--run apply-all", failedStep: "apply_power_plan");
        Assert.NotEqual(0, result.ExitCode);
        Assert.Contains("MUTATE:cleanup_temp", result.Output);
        Assert.Contains("MUTATE:apply_power_plan", result.Output);
        Assert.DoesNotContain("MUTATE:cleanup_background", result.Output);
        Assert.DoesNotContain("Apply All completed", result.Output);
    }

    [Fact]
    public async Task Dispatcher_IsNonInteractiveAndPreservesSuccess()
    {
        var result = await Run("command_dispatch", "", arguments: "--run power-high");
        Assert.True(result.ExitCode == 0, result.Output);
        Assert.Contains("BACKUP", result.Output);
        Assert.Contains("MUTATE:apply_power_plan", result.Output);
        Assert.DoesNotContain("Proceed?", result.Output);
    }

    [Theory]
    [InlineData(false)]
    [InlineData(true)]
    public async Task DispatcherRecoveryValidation_RequiresSuccess(bool exportFails)
    {
        var result = await Run("command_dispatch", "", arguments: "--run power-high", backupFails: exportFails);
        Assert.Equal(exportFails ? 1 : 0, result.ExitCode);
        if (exportFails)
        {
            Assert.DoesNotContain("MUTATE:", result.Output);
            Assert.Contains("Required backup failed", result.Output);
        }
        else Assert.Contains("MUTATE:apply_power_plan", result.Output);
    }

    // Only explicitly allowlisted CONTROL FLOW is copied. All other labels become inert stubs.
    // No real modifying engine body or external command is ever executed by this fixture.
    private static async Task<(int ExitCode, string Output)> Run(string entry, string input,
        bool backupFails = false, string arguments = "", string prelude = "", string failedStep = "")
    {
        var root = new Services.HolmesKitPathResolver(AppContext.BaseDirectory).RootDirectory;
        var source = File.ReadAllText(Path.Combine(root, "HolmesKit.bat"));
        var control = new HashSet<string>(StringComparer.OrdinalIgnoreCase)
        {
            "main_menu", "command_dispatch", "dispatch_selected", "dispatch_engine", "core_menu", "advanced_menu", "gaming_menu",
            "restore_menu", "confirm_open", "confirm_close", "run_confirmed", "apply_all", "run_apply_all",
            "run_full_core", "gaming_full_prep"
        };
        var fixture = new StringBuilder("@echo off\r\nsetlocal EnableExtensions EnableDelayedExpansion\r\n");
        // Exercise the native dispatcher with inert leaves, never launch the recovery/native adapter.
        fixture.AppendLine("set HK_RECOVERY_CHILD=1");
        fixture.AppendLine(prelude);
        fixture.AppendLine("set HK_LATEST=%CD%\\latest\r\nset HK_BACKUP_READY=0");
        fixture.AppendLine("goto " + entry);
        var blocks = Regex.Matches(source, @"(?ms)^:([a-z_]+)\r?\n(.*?)(?=^:[a-z_]+\r?$|\z)");
        Assert.True(blocks.Count > 40);
        foreach (Match block in blocks)
        {
            var label = block.Groups[1].Value;
            fixture.AppendLine(":" + label);
            if (label == "pause_return") { fixture.AppendLine("exit /b 0"); continue; }
            if (label == "ensure_backup")
            {
                fixture.AppendLine(backupFails ? "echo ERROR: Required backup failed.\r\nexit /b 1" : "echo BACKUP\r\nexit /b 0");
                continue;
            }
            if (!control.Contains(label) && !label.StartsWith("dispatch_"))
            {
                fixture.AppendLine($"echo MUTATE:{label}\r\nexit /b {(label == failedStep ? 1 : 0)}");
                continue;
            }
            var lines = new List<string>();
            var continuation = false;
            foreach (var line in block.Groups[2].Value.Split('\n'))
            {
                if (continuation || line.TrimStart().StartsWith("powershell ", StringComparison.OrdinalIgnoreCase))
                {
                    continuation = line.TrimEnd().EndsWith('^');
                    continue;
                }
                lines.Add(line.TrimEnd('\r'));
            }
            var body = string.Join("\r\n", lines);
            body = Regex.Replace(body, @"(?m)^\s*call :log[^\r\n]*", "rem log removed");
            body = Regex.Replace(body, @"(?m)^cls\s*$", "rem clear removed");
            body = body.Replace("call :print_header", "rem header removed");
            // Defense against accidentally broadening the allowlist to a native operation body.
            Assert.DoesNotMatch(@"(?im)^\s*(reg |sc |net |netsh |powercfg |taskkill |del |start |powershell |ipconfig |fsutil )", body);
            if (label != "ensure_backup") Assert.DoesNotMatch(@"(?im)^\s*(rd |md )", body);
            fixture.AppendLine(body);
        }
        var directory = Path.Combine(Path.GetTempPath(), "HolmesKit.Safety." + Guid.NewGuid().ToString("N"));
        Directory.CreateDirectory(directory);
        try
        {
            var path = Path.Combine(directory, "fixture.bat");
            File.WriteAllText(path, fixture.ToString(), Encoding.ASCII);
            var inputPath = Path.Combine(directory, "input.txt");
            File.WriteAllText(inputPath, input, Encoding.ASCII);
            var info = new ProcessStartInfo("cmd.exe") { UseShellExecute = false, CreateNoWindow = true,
                RedirectStandardInput = true, RedirectStandardOutput = true, RedirectStandardError = true, WorkingDirectory = directory };
            info.Arguments = "/d /s /c \"\"" + path + "\" " + arguments + " < \"" + inputPath + "\"\"";
            using var process = Process.Start(info)!;
            var output = process.StandardOutput.ReadToEndAsync();
            var error = process.StandardError.ReadToEndAsync();
            process.StandardInput.Close();
            using var timeout = new CancellationTokenSource(TimeSpan.FromSeconds(8));
            try { await process.WaitForExitAsync(timeout.Token); }
            catch { process.Kill(true); throw; }
            return (process.ExitCode, await output + await error);
        }
        finally { Directory.Delete(directory, true); }
    }
}
