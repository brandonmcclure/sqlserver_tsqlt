This is the base image that I use to deploy dacpacs and run unit tests. This image is in no way affiliated with Microsoft or the tSQLt project.

# Setup/build
You need pwsh core and gnu make

Run `make` to download the latest tSQLt release from [their website](http://tsqlt.org/download/tsqlt/) and build the docker image. 

## Set your own SA Password:
Create a User scoped enviornment variable, as a secure string
```
[System.Environment]::SetEnvironmentVariable("SA_PASSWORD",("d0ckerSA" | ConvertTo-SecureString -AsPlaintext | ConvertFrom-SecureString),"User")
```
# How to use


You can install tsqlt to a new isntance by running the following docker exec:
```
docker exec sqlserver pwsh -f '/installTSQLT.ps1' -db 'YourDBName' -sa_password 'YourSAPassword'
```