using HolmesKit.Desktop.Services;

namespace HolmesKit.Desktop.Tests;

public class DesktopHardeningTests
{
    [Fact]
    public void TailReader_BoundsLargeLogsAndReturnsNewestLines()
    {
        var path=Path.Combine(Path.GetTempPath(),Guid.NewGuid()+".log");
        try
        {
            File.WriteAllLines(path,Enumerable.Range(0,20000).Select(i=>$"{i:D5} {new string('x',100)}"));
            var tail=LogTailReader.Read(path);
            Assert.Equal(500,tail.Length);
            Assert.StartsWith("19500",tail[0]);
            Assert.StartsWith("19999",tail[^1]);
        }
        finally { File.Delete(path); }
    }

    [Fact]
    public async Task MutatingRequest_IgnoresCancellationRatherThanKillingAChange()
    {
        using var cancellation=new CancellationTokenSource();
        cancellation.Cancel();
        var result=await new ProcessRunner().RunAsync(new("cmd.exe",["/d","/c","echo completed"],Environment.CurrentDirectory,AllowCancellation:false),cancellationToken:cancellation.Token);
        Assert.True(result.Succeeded);
        Assert.Contains("completed",result.StandardOutput);
    }

    [Fact]
    public void CorruptedRecoveryEnvelope_IsNotPresentedAsUsable()
    {
        var path=Path.Combine(Path.GetTempPath(),Guid.NewGuid()+".json");
        try
        {
            File.WriteAllText(path,"{\"Payload\":\"{}\",\"Sha256\":\"bad\"}");
            Assert.False(BackupInspector.InspectJournal(path).IsValid);
        }
        finally { File.Delete(path); }
    }
}
