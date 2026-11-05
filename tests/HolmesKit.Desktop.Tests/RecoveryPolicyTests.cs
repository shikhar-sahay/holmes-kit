using System.Diagnostics;
using System.Text;
using HolmesKit.Desktop.Services;

namespace HolmesKit.Desktop.Tests;

public class RecoveryPolicyTests
{
    [Theory]
    [InlineData("roundtrip")]
    [InlineData("retention")]
    [InlineData("corrupt")]
    [InlineData("identity")]
    [InlineData("scope")]
    [InlineData("duplicate")]
    [InlineData("absent")]
    [InlineData("typed")]
    [InlineData("conflict")]
    [InlineData("interrupted")]
    [InlineData("failure")]
    [InlineData("unrelated")]
    [InlineData("binary")]
    [InlineData("multistring")]
    [InlineData("operation-scope")]
    [InlineData("property-order")]
    [InlineData("null-dword")]
    [InlineData("fractional-qword")]
    [InlineData("null-binary")]
    [InlineData("bad-multistring")]
    [InlineData("empty-binary")]
    [InlineData("changed-type")]
    public async Task RecoveryPolicy_IsolatedFromNativeWindows(string scenario)
    {
        var root = new HolmesKitPathResolver(AppContext.BaseDirectory).RootDirectory;
        var directory = Path.Combine(Path.GetTempPath(), "HolmesKit.Recovery." + Guid.NewGuid().ToString("N"));
        Directory.CreateDirectory(directory);
        try
        {
            var script = """
                $ErrorActionPreference='Stop'
                . (Join-Path $env:HK_TEST_ROOT 'modules\recovery_core.ps1')
                $scope=@([pscustomobject]@{Id='Registry|Fixture|Value';Category='Registry';Path='Fixture';Name='Value'})
                $script:state=[pscustomobject]@{Exists=$true;Kind='DWord';Data=7}
                $script:writes=0
                function Read-HolmesState($Item) { if($Item.Path -ne 'Fixture'){throw 'Isolation violation'}; return $script:state }
                function Write-HolmesState($Item,$Value) { if($Item.Path -ne 'Fixture'){throw 'Isolation violation'}; $script:writes++; if($env:HK_TEST_CASE -eq 'failure'){throw 'Injected write failure'}; $script:state=$Value }
                function Check($value,$message) { if(-not $value){throw $message} }
                function MustFail($body) { $failed=$false; try { & $body } catch {$failed=$true}; Check $failed 'Expected rejection' }
                $j=New-HolmesJournal $scope 'machine-fixture' 'user-fixture'
                Assert-HolmesJournal $j $scope 'machine-fixture' 'user-fixture'
                switch($env:HK_TEST_CASE){
                  'property-order' { $a=[pscustomobject]@{Exists=$true;Kind='DWord';Data=7}; $b=[pscustomobject]@{Data=7;Kind='DWord';Exists=$true}; Check (Test-HolmesEqual $a $b) 'Property order caused false conflict' }
                  'null-dword' { $j.Entries[0].Before=[pscustomobject]@{Exists=$true;Kind='DWord';Data=$null}; MustFail { Assert-HolmesJournal $j $scope 'machine-fixture' 'user-fixture' } }
                  'fractional-qword' { $j.Entries[0].Before=[pscustomobject]@{Exists=$true;Kind='QWord';Data=1.5}; MustFail { Assert-HolmesJournal $j $scope 'machine-fixture' 'user-fixture' } }
                  'null-binary' { $j.Entries[0].Before=[pscustomobject]@{Exists=$true;Kind='Binary';Data=$null}; MustFail { Assert-HolmesJournal $j $scope 'machine-fixture' 'user-fixture' } }
                  'bad-multistring' { $j.Entries[0].Before=[pscustomobject]@{Exists=$true;Kind='MultiString';Data=@('text',7)}; MustFail { Assert-HolmesJournal $j $scope 'machine-fixture' 'user-fixture' } }
                  'empty-binary' { $j.Entries[0].Before=[pscustomobject]@{Exists=$true;Kind='Binary';Data=@()}; Assert-HolmesJournal $j $scope 'machine-fixture' 'user-fixture' }
                  'changed-type' { $j.Entries[0].After=[pscustomobject]@{Exists=$true;Kind='DWord';Data=26}; $script:state=[pscustomobject]@{Exists=$true;Kind='String';Data='26'}; $result=@(Restore-HolmesJournal $j $scope 'Registry'); Check ($script:writes -eq 0 -and $result[-1] -eq 1) 'External type change overwritten' }
                  'operation-scope' { $items=@([pscustomobject]@{Id='Service|SysMain'},[pscustomobject]@{Id='Service|BITS'},[pscustomobject]@{Id='Registry|HKCU\Control Panel\Desktop|MenuShowDelay'},[pscustomobject]@{Id='Registry|HKCU\Control Panel\Desktop\WindowMetrics|MinAnimate'}); $selected=@(Get-HolmesOperationScope $items 'services-cleanup'); Check ($selected.Count -eq 1 -and $selected[0].Id -eq 'Service|SysMain') 'Service scope drift'; $selected=@(Get-HolmesOperationScope $items 'ui-responsive'); Check ($selected.Count -eq 1 -and $selected[0].Id.EndsWith('MenuShowDelay')) 'UI scope drift' }
                  'binary' { $value=Convert-HolmesRegistryData ([pscustomobject]@{Kind='Binary';Data=@(0,255)}); Check ($value -is [byte[]] -and $value[1] -eq 255) 'Binary data lost its CLR type' }
                  'multistring' { $value=Convert-HolmesRegistryData ([pscustomobject]@{Kind='MultiString';Data=@('one','two')}); Check ($value -is [string[]] -and $value.Count -eq 2) 'Multi-string lost its CLR type' }
                  'roundtrip' { Save-HolmesJournal $env:HK_TEST_DIR $j; $copy=Read-HolmesJournalFile (Join-Path $env:HK_TEST_DIR 'baseline.json'); Check (Test-HolmesEqual $j $copy) 'Roundtrip changed state' }
                  'retention' { Save-HolmesJournal $env:HK_TEST_DIR $j; $id=$j.Id; $j.Operation='second'; Save-HolmesJournal $env:HK_TEST_DIR $j; $copy=Read-HolmesJournalFile (Join-Path $env:HK_TEST_DIR 'baseline.json'); Check ($copy.Id -eq $id -and $copy.Entries[0].Before.Data -eq 7) 'Baseline replaced'; $previous=Read-HolmesJournalFile (Join-Path $env:HK_TEST_DIR 'baseline.previous.json'); Check ($previous.Operation -eq '') 'Previous copy missing' }
                  'corrupt' { Save-HolmesJournal $env:HK_TEST_DIR $j; $p=Join-Path $env:HK_TEST_DIR 'baseline.json'; [IO.File]::WriteAllText($p,'{}'); MustFail { Read-HolmesJournalFile $p } }
                  'identity' { MustFail { Assert-HolmesJournal $j $scope 'other-machine' 'user-fixture' } }
                  'scope' { $j.Entries[0].Id='Registry|HKLM\Arbitrary|Value'; MustFail { Assert-HolmesJournal $j $scope 'machine-fixture' 'user-fixture' } }
                  'duplicate' { $j.Entries=@($j.Entries[0],$j.Entries[0]); MustFail { Assert-HolmesJournal $j $scope 'machine-fixture' 'user-fixture' } }
                  'interrupted' { $j.Status='Running'; MustFail { Restore-HolmesJournal $j $scope 'Registry' }; Check ($script:writes -eq 0) 'Wrote ambiguous state' }
                  default {
                    if($env:HK_TEST_CASE -eq 'absent'){$j.Entries[0].Before=[pscustomobject]@{Exists=$false;Kind='None';Data=$null}}
                    $j.Entries[0].After=[pscustomobject]@{Exists=$true;Kind='DWord';Data=26}
                    $script:state=$j.Entries[0].After
                    if($env:HK_TEST_CASE -eq 'conflict'){$script:state=[pscustomobject]@{Exists=$true;Kind='DWord';Data=99}}
                    $category=if($env:HK_TEST_CASE -eq 'unrelated'){'Services'}else{'Registry'}
                    $result=@(Restore-HolmesJournal $j $scope $category)
                    if($env:HK_TEST_CASE -eq 'conflict'){Check ($script:writes -eq 0 -and $result[-1] -eq 1) 'Conflict overwritten'}
                    elseif($env:HK_TEST_CASE -eq 'failure'){Check ($result[-1] -eq 1) 'Failure hidden'}
                    elseif($env:HK_TEST_CASE -eq 'unrelated'){Check ($script:writes -eq 0) 'Unrelated category changed'}
                    else {Check (Test-HolmesEqual $script:state $j.Entries[0].Before) 'Original existence/type/data not restored'}
                  }
                }
                Write-Output 'PASS'
                """;
            var info = new ProcessStartInfo("powershell.exe") { UseShellExecute = false, CreateNoWindow = true, RedirectStandardOutput = true, RedirectStandardError = true };
            info.ArgumentList.Add("-NoProfile"); info.ArgumentList.Add("-NonInteractive"); info.ArgumentList.Add("-EncodedCommand");
            info.ArgumentList.Add(Convert.ToBase64String(Encoding.Unicode.GetBytes(script)));
            info.Environment["HK_TEST_ROOT"] = root; info.Environment["HK_TEST_DIR"] = directory; info.Environment["HK_TEST_CASE"] = scenario;
            using var p = Process.Start(info)!;
            var stdout = p.StandardOutput.ReadToEndAsync(TestContext.Current.CancellationToken);
            var stderr = p.StandardError.ReadToEndAsync(TestContext.Current.CancellationToken);
            await p.WaitForExitAsync(TestContext.Current.CancellationToken);
            var output = await stdout + await stderr;
            Assert.True(p.ExitCode == 0, output);
            Assert.Contains("PASS", output);
        }
        finally { Directory.Delete(directory, true); }
    }
}
