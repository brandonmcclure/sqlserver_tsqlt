echo "Checking SQL Server"
STATUS=$(/opt/mssql-tools/bin/sqlcmd -S localhost -V16 -U sa -P $SA_PASSWORD -l 300 -d master -Q "SET NOCOUNT ON; SELECT 1" -W -h-1 )
while [ "$STATUS" != 1 ]
do
sleep 1s
 
echo "Checking SQL Server"
STATUS=$(/opt/mssql-tools/bin/sqlcmd -S localhost -V16 -U sa -P $SA_PASSWORD -d master -l 300 -Q "SET NOCOUNT ON; SELECT 1" -W -h-1 )
done
 
echo "SQL UP!"
echo "Install tsqlt"
/opt/mssql-tools/bin/sqlcmd -S localhost -V16 -U sa -P $SA_PASSWORD -l 300 -d master -i /tSQLtInstall/PrepareServer.sql
rc=$?; if [[ $rc != 0 ]]; then echo "tSQLt install step failed with code $rc" && exit $rc; fi
