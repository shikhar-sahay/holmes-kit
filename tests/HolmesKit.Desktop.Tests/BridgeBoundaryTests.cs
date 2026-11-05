using System.Diagnostics;
using System.Text;
using HolmesKit.Desktop.Services;

namespace HolmesKit.Desktop.Tests;

public class BridgeBoundaryTests
{
    [Theory]
    [InlineData(@"C:\Fixture\uninstall.exe",true)]
    [InlineData(@"uninstall.exe",false)]
    [InlineData(@"C:\Fixture\remove.ps1",false)]
    [InlineData(@"C:\Windows\System32\cmd.exe",false)]
    [InlineData(@"C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe",false)]
    public async Task UninstallerBoundary_RejectsRelativeScriptsAndInterpreters(string path,bool allowed)
    {
        var root=new HolmesKitPathResolver(AppContext.BaseDirectory).RootDirectory;
        var script="""
            $ErrorActionPreference='Stop'
            $tokens=$null; $errors=$null
            $ast=[Management.Automation.Language.Parser]::ParseFile((Join-Path $env:HK_TEST_ROOT 'modules\gui_bridge.ps1'),[ref]$tokens,[ref]$errors)
            if($errors.Count){throw 'Bridge parse errors'}
            $function=$ast.Find({param($node) $node -is [Management.Automation.Language.FunctionDefinitionAst] -and $node.Name -eq 'Assert-HolmesUninstallerPath'},$true)
            # Load only this pure validation function; never execute the bridge action switch.
            . ([scriptblock]::Create($function.Extent.Text))
            function Test-Path { param($LiteralPath,$PathType) return $true }
            try { Assert-HolmesUninstallerPath $env:HK_TEST_PATH; Write-Output 'ALLOWED' } catch { Write-Output 'REJECTED' }
            """;
        var info=new ProcessStartInfo("powershell.exe"){UseShellExecute=false,CreateNoWindow=true,RedirectStandardOutput=true,RedirectStandardError=true};
        foreach(var arg in new[]{"-NoProfile","-NonInteractive","-EncodedCommand",Convert.ToBase64String(Encoding.Unicode.GetBytes(script))}) info.ArgumentList.Add(arg);
        info.Environment["HK_TEST_ROOT"]=root; info.Environment["HK_TEST_PATH"]=path;
        using var p=Process.Start(info)!;
        var output=p.StandardOutput.ReadToEndAsync(TestContext.Current.CancellationToken);
        var error=p.StandardError.ReadToEndAsync(TestContext.Current.CancellationToken);
        await p.WaitForExitAsync(TestContext.Current.CancellationToken);
        var text=await output+await error;
        Assert.True(p.ExitCode==0,text);
        Assert.Contains(allowed?"ALLOWED":"REJECTED",text);
    }
}
