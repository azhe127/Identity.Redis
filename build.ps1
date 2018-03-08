$result = 0
$merge = ""
gci -rec `
| ? { $_.Name -like "*.IntegrationTest.csproj" `
       -Or $_.Name -like "*.Test.csproj" `
     } `
| % { 
    $testArgs = "test " + $_.FullName
    Write-Host "testargs" $testArgs
    Write-Host "coveragefile" $coveragefile
    JetBrains.dotCover.CommandLineTools\tools\dotCover.exe cover /TargetExecutable="C:\Program Files\dotnet\dotnet.exe" /TargetArguments="$testArgs" /Filters="-:*.Test;-:*.IntegrationTest;-:xunit.*;-:MSBuild;-:Moq;-:StackExchange.*" /Output="$_.snapshot"
    
    if ($LASTEXITCODE -ne 0) {
        $result = $LASTEXITCODE
    }

    $merge = $merge + $_.Name + ".snapshot;"
  }

  Write-Host "merge " $merge
  JetBrains.dotCover.CommandLineTools\tools\dotCover.exe merge /Source="$merge" /Output="coverage\coverage.snapshot"
  JetBrains.dotCover.CommandLineTools\tools\dotCover.exe report /Source="coverage\coverage.snapshot" /Output="coverage\docs\index.html" /ReportType="HTML"

  exit $result
  