using System.Diagnostics;
using System.IO.Compression;
using System.Security.Cryptography;
using System.Text;
using System.Text.Json;

namespace HolmesKit.Desktop.Tests;

public class ValidationToolsTests
{
    [Fact]
    public void CurrentDocumentation_LocalLinksResolve()
    {
        var root=RepositoryRoot();
        var files=Directory.GetFiles(Path.Combine(root,"docs"),"*.md").Append(Path.Combine(root,"README.md"));
        foreach(var file in files)
            foreach(System.Text.RegularExpressions.Match match in System.Text.RegularExpressions.Regex.Matches(File.ReadAllText(file),@"!?\[[^\]]*\]\(([^)]+)\)"))
            {
                var target=match.Groups[1].Value;
                if(target.StartsWith("http",StringComparison.OrdinalIgnoreCase)||target.StartsWith('#'))continue;
                var path=Path.GetFullPath(Path.Combine(Path.GetDirectoryName(file)!,target.Split('#')[0]));
                Assert.True(File.Exists(path)||Directory.Exists(path),$"Broken link in {Path.GetFileName(file)}: {target}");
            }
    }
    internal static string RepositoryRoot()
    {
        var current=new DirectoryInfo(AppContext.BaseDirectory);
        while(current is not null){if(File.Exists(Path.Combine(current.FullName,"HolmesKit.slnx")))return current.FullName;current=current.Parent;}
        throw new DirectoryNotFoundException();
    }
    private static async Task<(int,string)> Run(string script,Dictionary<string,string> environment)
    {
        var info=new ProcessStartInfo("powershell.exe"){UseShellExecute=false,CreateNoWindow=true,RedirectStandardOutput=true,RedirectStandardError=true};
        foreach(var arg in new[]{"-NoProfile","-NonInteractive","-EncodedCommand",Convert.ToBase64String(Encoding.Unicode.GetBytes(script))})info.ArgumentList.Add(arg);
        foreach(var pair in environment)info.Environment[pair.Key]=pair.Value;
        using var p=Process.Start(info)!;
        var output=p.StandardOutput.ReadToEndAsync(TestContext.Current.CancellationToken);
        var error=p.StandardError.ReadToEndAsync(TestContext.Current.CancellationToken);
        await p.WaitForExitAsync(TestContext.Current.CancellationToken);
        return(p.ExitCode,await output+await error);
    }

    [Theory]
    [InlineData("valid",true)]
    [InlineData("missing",false)]
    [InlineData("mismatch",false)]
    [InlineData("extra",false)]
    [InlineData("traversal",false)]
    [InlineData("recovery-state",false)]
    public async Task PackageVerifier_RejectsIncompleteCorruptOrUnsafePayloads(string scenario,bool valid)
    {
        var path=Path.Combine(Path.GetTempPath(),Guid.NewGuid()+".zip");
        try
        {
            using(var file=File.Create(path))using(var zip=new ZipArchive(file,ZipArchiveMode.Create))
            {
                var names=new[]{"HolmesKit.exe","HolmesKit.bat","modules/gui_bridge.ps1","modules/recovery.ps1","modules/recovery_core.ps1","modules/startup_mgr.ps1","modules/apps_mgr.ps1","modules/sysinfo.ps1","modules/logo.ps1","VERSION.txt"};
                var manifest=new StringBuilder();
                foreach(var name in scenario=="recovery-state"?names.Append("baseline.json"):names)
                {
                    if(scenario=="missing"&&name=="HolmesKit.exe")continue;
                    using var writer=new StreamWriter(zip.CreateEntry(name).Open(),new UTF8Encoding(false));
                    writer.Write("inert fixture");
                    var hash=Convert.ToHexString(SHA256.HashData(Encoding.UTF8.GetBytes("inert fixture")));
                    manifest.AppendLine($"{(scenario=="mismatch"?new string('0',64):hash)}  {name}");
                }
                using(var writer=new StreamWriter(zip.CreateEntry("SHA256SUMS.txt").Open()))writer.Write(manifest);
                if(scenario=="extra")zip.CreateEntry("unlisted.txt");
                if(scenario=="traversal")zip.CreateEntry("../outside.txt");
            }
            var result=await Run("$ErrorActionPreference='Stop'; & (Join-Path $env:HK_ROOT 'tools/Test-PortableCandidate.ps1') -CandidateZip $env:HK_ZIP",new(){["HK_ROOT"]=RepositoryRoot(),["HK_ZIP"]=path});
            Assert.True((result.Item1==0)==valid,result.Item2);
        }
        finally{File.Delete(path);}
    }

    [Fact]
    public async Task EvidenceCollector_MarksEveryScenarioUnexecutedAndNeverOverwrites()
    {
        var directory=Path.Combine(Path.GetTempPath(),"HolmesKit.Evidence."+Guid.NewGuid().ToString("N"));Directory.CreateDirectory(directory);
        try
        {
            File.WriteAllText(Path.Combine(directory,"fixture.zip"),"inert fixture");
            var script="""
                $ErrorActionPreference='Stop'
                function Get-CimInstance { [pscustomobject]@{Caption='Fixture OS';Version='fixture';BuildNumber='fixture'} }
                & (Join-Path $env:HK_ROOT 'tools/Collect-ValidationEvidence.ps1') -CandidateZip (Join-Path $env:HK_DIR 'fixture.zip') -EnvironmentLabel 'fixture' -CheckpointId 'not-a-real-checkpoint' -OutputPath (Join-Path $env:HK_DIR 'evidence.json')
                """;
            var env=new Dictionary<string,string>{["HK_ROOT"]=RepositoryRoot(),["HK_DIR"]=directory};
            var result=await Run(script,env);Assert.True(result.Item1==0,result.Item2);
            var before=File.ReadAllText(Path.Combine(directory,"evidence.json"));
            using var json=JsonDocument.Parse(before);
            Assert.All(json.RootElement.GetProperty("Scenarios").EnumerateArray(),x=>Assert.Equal("NOT EXECUTED",x.GetProperty("Status").GetString()));
            var again=await Run(script,env);Assert.NotEqual(0,again.Item1);
            Assert.Equal(before,File.ReadAllText(Path.Combine(directory,"evidence.json")));
        }
        finally{Directory.Delete(directory,true);}
    }
}
