try{
    Import-Module FC_Core -DisableNameChecking -Force -ErrorAction Stop
  }
  catch {
    $modulePath = "$((get-item $PSCommandPath).Directory.Parent.FullName)\Modules"
    Write-Host "Setting the env:PSModulePath to the same repo: $modulePath"
  
    if (!(Test-Path $modulePath)) {
      Write-Error "I can't find any Powershell modules in the repo at: $modulePath. I need the modules!"
    }
    else {
      if (!($env:PSModulePath -like "*;$modulePath*")) {
        $env:PSModulePath = $env:PSModulePath + ";$modulePath\"
      }
    }
  
  Import-Module FC_Core -DisableNameChecking -Force -ErrorAction Stop
  }

  $projectRoot = Split-Path $PSScriptRoot -Parent
  if(-Not (Test-Path "$projectRoot\tsqlt.zip")){
    Invoke-WebRequest http://tsqlt.org/download/tsqlt/ -OutFile "$projectRoot\tsqlt.zip"
  }

  Expand-Archive -Path "$projectRoot\tsqlt.zip" -DestinationPath "$projectRoot\tSQLtInstall" -Force


       Set-Location $PSScriptRoot
        Invoke-UnixLineEndings -Directory ..