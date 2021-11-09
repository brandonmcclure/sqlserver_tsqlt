Describe "sqlserver image"{
    
    afterAll{
        $dockerName = 'sqlserver_tsqlt'
        
        docker stop $dockerName | out-null
            docker rm $dockerName | out-null
    }
    BeforeAll{
        Remove-Module DBATools, fc_core -Force -ErrorAction SilentlyContinue | Out-Null
        Import-Module DBATools, fc_core -ErrorAction Stop
        . "$PSScriptRoot/TestFunctions.ps1"

        $dockerName = 'sqlserver_tsqlt'
        $saPassword = 'we@kPassw0rd'
            
            docker stop $dockerName | out-null
            docker rm $dockerName | out-null
        docker run -d -p 1433:1433 -e ACCEPT_EULA=Y --name=$dockerName bmcclure89/sqlserver_tsqlt:2019-gdr2-ubuntu-16.04.main

        $queryOptions = @{
            database = "master";
            
        }
         $queryOptions += @{SqlInstance = '127.0.0.1' }  
         $sqlAuthPass = ConvertTo-SecureString -AsPlainText -Force -String $saPassword
    if ([string]::IsNullOrEmpty($sqlAuthPass)) {
        $creds = Get-Credential -Username 'sa' -Message 'enter the local container sql auth' -Title 'hey, need your password'
    }
    else {
        $creds = $(New-Object System.Management.Automation.PSCredential ('sa', $sqlAuthPass))
    }
    $queryOptions += @{SqlCredential = $creds }

    sleep 5
        Write-Verbose "Deleting test DB"
        Invoke-dbaquery -query "DROP DATABASE IF EXISTS container_test;" @queryOptions
        
        Write-Verbose "Creating test DB"
        Invoke-dbaquery -InputFile "$PSScriptRoot\newTestDB.sql" @queryOptions
    }

    Context "Image"{
        
        # AfterAll{
        #     Write-Verbose "Deleting test DB"
        #     Invoke-Sqlcmd -server 127.0.0.1 -database 'master' -Username 'sa' -password ([Environment]::GetEnvironmentVariable("SA_PASSWORD", "User") | ConvertTo-SecureString | ConvertFrom-SecureString -AsPlainText) -query "DROP DATABASE IF EXISTS container_test;"
        # }
        it 'can installTSQLt'{
            
            

            $EXEPath = "docker"
            $options = "exec $dockerName pwsh -f /installTSQLT.ps1 -db container_test -sa_password `"$saPassword`" -verbose"
        
            Write-Verbose $options
            $return = Start-MyProcess -EXEPath  $EXEPath -options $options

                $return.stdout
            
            if (-not [string]::IsNullOrEmpty($return.stderr) -or $return.stdout -like '*failed*'){
                Write-Warning "$($return.stdout)"
                Write-Warning "$($return.sterr)"
                Write-Warning "There was an error from the docker call"
                throw "$($return.sterr)"
            }
        }
        it 'pwsh is installed'{


            $EXEPath = "docker"
            $options = "exec $dockerName pwsh -c `"'hello world'`""
        
            $return = Start-MyProcess -EXEPath  $EXEPath -options $options

                
            
            if (-not [string]::IsNullOrEmpty($return.stderr) -or $return.stdout -like '*failed*'){
                Write-Warning "Output: $($return.stdout)"
                Write-Warning "Error: $($return.sterr)"
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