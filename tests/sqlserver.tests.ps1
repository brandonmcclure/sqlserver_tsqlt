
Try{
    Import-Module ./TestFunctions.psm1, sqlserver, fc_core -ErrorAction Stop
}
catch{$tryAgain =$true}
if($tryAgain)
{
    Import-Module ./tests/TestFunctions.psm1,sqlserver, fc_core -ErrorAction Stop
}
Describe "sqlserver image"{
    Context "Image"{
        BeforeAll{
            Write-Verbose "Deleting test DB"
            Invoke-Sqlcmd -server 127.0.0.1 -database 'master' -Username 'sa' -password ([Environment]::GetEnvironmentVariable("SA_PASSWORD", "User") | ConvertTo-SecureString | ConvertFrom-SecureString -AsPlainText) -query "DROP DATABASE IF EXISTS container_test;"
            
            Write-Verbose "Creating test DB"
            Invoke-Sqlcmd -server 127.0.0.1 -database 'master' -Username 'sa' -password ([Environment]::GetEnvironmentVariable("SA_PASSWORD", "User") | ConvertTo-SecureString | ConvertFrom-SecureString -AsPlainText) -InputFile "$PSScriptRoot\newTestDB.sql"
        }
        # AfterAll{
        #     Write-Verbose "Deleting test DB"
        #     Invoke-Sqlcmd -server 127.0.0.1 -database 'master' -Username 'sa' -password ([Environment]::GetEnvironmentVariable("SA_PASSWORD", "User") | ConvertTo-SecureString | ConvertFrom-SecureString -AsPlainText) -query "DROP DATABASE IF EXISTS container_test;"
        # }
        it 'can installTSQLt'{
            
            

            $EXEPath = "docker"
            $options = "exec sqlserver_tsqlt pwsh -f /installTSQLT.ps1 -db 'container_test' -sa_password $([Environment]::GetEnvironmentVariable('SA_PASSWORD', 'User') | ConvertTo-SecureString | ConvertFrom-SecureString -AsPlainText)"
        
            $return = Start-MyProcess -EXEPath  $EXEPath -options $options

                $return.stdout
            
            if (-not [string]::IsNullOrEmpty($return.stderr) -or $return.stdout -like '*failed*'){
                throw "$($return.sterr)"
            }
        }
        it 'pwsh is installed'{


            $EXEPath = "docker"
            $options = "exec sqlserver_tsqlt pwsh -c `"'hello world'`""
        
            $return = Start-MyProcess -EXEPath  $EXEPath -options $options

                $return.stdout
            
            if (-not [string]::IsNullOrEmpty($return.stderr) -or $return.stdout -like '*failed*'){
                Write-Error "$($return.sterr)" -ErrorAction Stop
            }
        }
        
    }
    
    context 'Environment' {
        it 'SQL Server port is accessible'{

            $result = Test-Port -computer localhost -port 1433

            if($result.Open -eq $false){
            $result
            throw "port is not open"
            }
        }
    }

}