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

  $myTSQLTExtension = "EXEC sp_configure 'clr enabled', 1;  
  RECONFIGURE;  
  GO  
  
  CREATE TABLE [tSQLt].[DebugTests]
  (
      [IsDebug] bit not null default 1,
      constraint PK_T1 PRIMARY KEY ([IsDebug]),
       constraint CK_T1_Locked CHECK ([IsDebug]=1)
  )
  go
  
  
  create procedure tSQLt.DebugEnter
  as
  begin
      insert into [tSQLt].[DebugTests]
      select coalesce(IsDebug,1) from [tSQLt].[DebugTests] where IsDebug = 1
  end
  go
  
  create procedure tSQLt.DebugExit
  as
  begin
      truncate table [tSQLt].[DebugTests]
  end
  go"
  
  $myTSQLTExtension | Set-Content $projectRoot\tSQLtInstall\myTSQLTExtension.sql
  
       Set-Location $PSScriptRoot
       Invoke-UnixLineEndings -Directory ..
 