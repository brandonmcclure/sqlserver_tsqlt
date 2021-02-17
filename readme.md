This is the base image that I use to deploy dacpacs and run unit tests. This image is in no way affiliated with Microsoft or the tSQLt project.

# Setup/build
You need pwsh core and gnu make

Run `make` to download the latest tSQLt release from [their website](http://tsqlt.org/download/tsqlt/) and build the docker image. 

## Set your own SA Password:
Create a User scoped enviornment variable, as a secure string
```
[System.Environment]::SetEnvironmentVariable("SA_PASSWORD",("WeakP@ssword" | ConvertTo-SecureString -AsPlaintext | ConvertFrom-SecureString),"User")
```
# How to use
You can run as is with: `docker run -d -p 1433:1433 -e ACCEPT_EULA="Y" --name=$(projectName) $(registry)$(repository)$(projectName)_$(sqltag):latest`

## Useing this image as a base
See my [adventure works]() example.



You can install tsqlt to a new isntance by running the following docker exec:
```
docker exec sqlserver_tsqlt pwsh -f /installTSQLT.ps1 -db 'container_test' -sa_password "$([Environment]::GetEnvironmentVariable('SA_PASSWORD', 'User') | ConvertTo-SecureString | ConvertFrom-SecureString -AsPlainText)"
```

Or embed it into a custom Docker image via a custom init.sh script:
```
pwsh -f /installTSQLT.ps1 -db 'myDB' -sa_password $SA_PASSWORD
```

# Build for multiple tags
```
make build_2019-GDR2-ubuntu-16.04 build_2017-cu19-ubuntu
```

# Microsoft Tags
https://mcrflowprodcentralus.data.mcr.microsoft.com/mcrprod/mssql/server?P1=1609435282&P2=1&P3=1&P4=QruUIrFFizDrrrFcA9Ai06m3dEyvDqtLoAACOLiryt4%3D&se=2020-12-31T17%3A21%3A22Z&sig=DzRw9mpySDQbqYO3ESuZDssJN9xVemgOF7RVk2z3HlI%3D&sp=r&sr=b&sv=2015-02-21