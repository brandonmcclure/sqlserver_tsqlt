projectName := sqlserver_tsqlt# This should be the folder name this Makefile is in to match what the build script will name it as. IDK how to get the current directory in pure make that works on windows
# https://stackoverflow.com/questions/2004760/get-makefile-directory
registry := 
repository := bmcclure89/
sqltag := 2019-latest

SHELL := pwsh.exe
.SHELLFLAGS := -noprofile -command

.PHONY: build
# All target is the default/what is run if you just type 'make'. It should get a developer up and running as quick as possible. 
all: setup build

# Setup: should be run to prepare for the build. I have used this alot with the docker images, because you want to use unix style line endings, so I want to scan all my script files before the image is built. I prefer to keep the logic of what exactly to do in a single PS script though. 
setup:
	@./build/Setup.ps1

#  Build: should build the project. In the case of docker this should build/tag the images in a consistent method. It has a preq on the setup target. So if you run 'make build' the setup target/script will run as well automatically. 
build: 
	./build/build.ps1 -registry '$(registry)' -repository '$(repository)' -SQLtagNames '$(sqltag)'

build_%: 
	./build/build.ps1 -registry '$(registry)' -repository '$(repository)' -SQLtagNames $*

run: 
	@docker run -d -p 1433:1433 -e ACCEPT_EULA=Y --name=$(projectName) $(registry)$(repository)$(projectName):$(sqltag)

test: run
	Invoke-Pester ./tests/

Install_tsqlt_to_%:
	docker exec $(projectName) pwsh -f /installTSQLT.ps1 -db "$*" -sa_password "$([Environment]::GetEnvironmentVariable('SA_PASSWORD', 'User') | ConvertTo-SecureString | ConvertFrom-SecureString -AsPlainText)"

# clean: up after yourself. I have itty bitty storage on my development machine, so I need to make sure I reclaim as much space as possible! 
clean:
	-@docker stop $(projectName)
	-@docker rm -v $(projectName)
clean_envvars:
	-[Environment]::SetEnvironmentVariable("SA_PASSWORD","", "User")