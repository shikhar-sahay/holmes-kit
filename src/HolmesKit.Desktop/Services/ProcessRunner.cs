using System.Diagnostics;
using System.IO;

namespace HolmesKit.Desktop.Services;

public sealed record ProcessRequest(string FileName, IReadOnlyList<string> Arguments, string WorkingDirectory, string? RawArguments = null, bool AllowCancellation = true);
public sealed record ProcessResult(int ExitCode, string StandardOutput, string StandardError, bool WasCancelled = false)
{
    public bool Succeeded => ExitCode == 0 && !WasCancelled;
}

public interface IProcessRunner
{
    Task<ProcessResult> RunAsync(ProcessRequest request, IProgress<string>? progress = null, CancellationToken cancellationToken = default);
}

public sealed class ProcessRunner : IProcessRunner
{
    public async Task<ProcessResult> RunAsync(ProcessRequest request, IProgress<string>? progress = null, CancellationToken cancellationToken = default)
    {
        if (!request.AllowCancellation) cancellationToken = CancellationToken.None;
        var startInfo = new ProcessStartInfo
        {
            FileName = request.FileName,
            WorkingDirectory = request.WorkingDirectory,
            UseShellExecute = false,
            CreateNoWindow = true,
            RedirectStandardOutput = true,
            RedirectStandardError = true,
            StandardOutputEncoding = System.Text.Encoding.UTF8,
            StandardErrorEncoding = System.Text.Encoding.UTF8
        };
        // CMD parses /c command text itself; normal argv escaping changes its quote syntax.
        if (request.RawArguments is not null) startInfo.Arguments = request.RawArguments;
        else foreach (var argument in request.Arguments) startInfo.ArgumentList.Add(argument);

        using var process = new Process { StartInfo = startInfo, EnableRaisingEvents = true };
        try
        {
            if (!process.Start()) return new(-1, "", "The process could not be started.");
        }
        catch (Exception ex) when (ex is System.ComponentModel.Win32Exception or InvalidOperationException)
        {
            return new(-1, "", ex.Message);
        }

        var output = new System.Text.StringBuilder();
        var errors = new System.Text.StringBuilder();
        var outputTask = ReadLinesAsync(process.StandardOutput, output, progress, cancellationToken);
        var errorTask = ReadLinesAsync(process.StandardError, errors, progress, cancellationToken);

        try
        {
            await process.WaitForExitAsync(cancellationToken);
            await Task.WhenAll(outputTask, errorTask);
            return new(process.ExitCode, output.ToString(), errors.ToString());
        }
        catch (OperationCanceledException)
        {
            try { if (!process.HasExited) process.Kill(true); } catch { }
            try { await Task.WhenAll(outputTask, errorTask); } catch (OperationCanceledException) { }
            return new(-1, output.ToString(), errors.ToString(), true);
        }
    }

    private static async Task ReadLinesAsync(StreamReader reader, System.Text.StringBuilder target, IProgress<string>? progress, CancellationToken token)
    {
        while (true)
        {
            var line = await reader.ReadLineAsync(token);
            if (line is null) break;
            target.AppendLine(line);
            if (target.Length > 524288) target.Remove(0, target.Length - 524288);
            if (!string.IsNullOrWhiteSpace(line)) progress?.Report(line.Trim());
        }
    }
}
