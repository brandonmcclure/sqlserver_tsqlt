param($db,$sa_password)
Write-Host "installing on $db"
Write-Host "sa_password $sa_password"

try{
    "/opt/mssql-tools/bin/sqlcmd -S localhost -V16 -U sa -P $sa_password -l 300 -d $db -i /tSQLtInstall/tSQLt.class.sql"
    /opt/mssql-tools/bin/sqlcmd -S localhost -V16 -U sa -P $sa_password -l 300 -d $db -i /tSQLtInstall/tSQLt.class.sql

    "/opt/mssql-tools/bin/sqlcmd -S localhost -V16 -U sa -P $sa_password -l 300 -d $db -i /tSQLtInstall/myTSQLTExtension.sql"
    /opt/mssql-tools/bin/sqlcmd -S localhost -V16 -U sa -P $sa_password -l 300 -d $db -i /tSQLtInstall/myTSQLTExtension.sql

}
catch{
    $ex = $_.Exception
    $line = $_.InvocationInfo.ScriptLineNumber
    if ([string]::IsNullOrEmpty($_.InvocationInfo.ScriptName)) { $scriptName = "[No InvocationInfo Available]" }
    else { $scriptName = Split-Path $_.InvocationInfo.ScriptName -Leaf }
    $msg = $ex.Message
    Write-Log "Error in script $scriptName at line $line, error message: $msg" Error -ErrorAction Stop
  }