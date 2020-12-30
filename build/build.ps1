#Requires -version 7
param(
    [parameter(Position=0)]$registry
,[parameter(Position=1)]$repository = "bmcclure89/"
,[parameter(Position=2)][STRING[]]$SQLtagNames = '2017-latest'
,[parameter(Position=3)][securestring]$SAPassword
,[parameter(Position=4)][bool]$isLatest = $true
,[parameter(Position=5)]$workingDir = (Split-Path $PSScriptRoot -parent)

)

Import-Module FC_Core, FC_Docker -Force -ErrorAction Stop -DisableNameChecking

# Param validation/defaults
if($null -eq $SAPassword){
    if ($null -ne [Environment]::GetEnvironmentVariable("SA_PASSWORD", "User")){
        Write-Host "Using the USER env variable"
        $SAPassword = [Environment]::GetEnvironmentVariable("SA_PASSWORD", "User") | ConvertTo-SecureString
    }
    if($null -eq $SAPassword){
        Write-Error "Setting unsecure default password for SA"
        $SAPassword = (ConvertTo-SecureString 'WeakP@ssword' -AsPlainText -Force)
        
    }
    if($null -eq $SAPassword){
        Write-Error "I don't know what to set for SAPassword!" -ErrorAction Stop
    }
}

# loop over the base sql tags. IE what sql server version/cu do you want?
foreach($SQLtagName in $SQLtagNames){
        Write-Log "SQLtagname: $sqltagName"
    $buildArgs = @{ 
        CD_SA_PASSWORD="$($SAPassword | ConvertFrom-SecureString -AsPlainText)"; 
        IMAGE="mcr.microsoft.com/mssql/server:$($SQLtagName.ToLower())";
}
    $imageName = "$((Split-Path $workingDir -Leaf).ToLower())"
    Invoke-DockerImageBuild  -registry $registry `
    -repository $repository `
    -imageName $imageName `
    -buildArgs $buildArgs `
    -tagPrefix "$($SQLtagName)_" `
    -isLatest $isLatest `
     -logLevel 'Debug' `
    -workingDir $workingDir
}
    