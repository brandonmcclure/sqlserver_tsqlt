This is the base image that I use to deploy dacpacs and run unit tests. Run `make` to download the latest tSQLt release from [their website](http://tsqlt.org/download/tsqlt/) and build the docker image. 

I use pwsh core to run the setup, so that is a prereq before you can build the image

You can install tsqlt to a new isntance by running the following docker exec:
```
docker exec sqlserver pwsh -f '/installTSQLT.ps1' -db 'YourDBName' -sa_password 'YourSAPassword'
```