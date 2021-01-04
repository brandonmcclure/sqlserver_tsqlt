param($db,$sa_password)
Write-Verbose "installing on $db"
/opt/mssql-tools/bin/sqlcmd -S localhost -V16 -U sa -P $sa_password -l 300 -d $db -i /tSQLtInstall/myTSQLTExtension.sql
/opt/mssql-tools/bin/sqlcmd -S localhost -V16 -U sa -P $sa_password -l 300 -d $db -i /tSQLtInstall/tSQLt.class.sql