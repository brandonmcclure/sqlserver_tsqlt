IMAGE_NAME := sqlserver_tsqlt# This should be the folder name this Makefile is in to match what the build script will name it as. IDK how to get the current directory in pure make that works on windows
# https://stackoverflow.com/questions/2004760/get-makefile-directory
REGISTRY_NAME := 
REPOSITORY_NAME := bmcclure89/
sqltag := 2019-gdr2-ubuntu-16.04
CS_SA_PASSWORD := we@kPassw0rd

SHELL := pwsh.exe
.SHELLFLAGS := -noprofile -command

.PHONY: build
# All target is the default/what is run if you just type 'make'. It should get a developer up and running as quick as possible. 
all: setup build
# Setup: should be run to prepare for the build. I have used this alot with the docker images, because you want to use unix style line endings, so I want to scan all my script files before the image is built. I prefer to keep the logic of what exactly to do in a single PS script though. 
setup:
	@./build/Setup.ps1

#  Build: should build the project. In the case of docker this should build/tag the images in a consistent method. It has a preq on the setup target. So if you run 'make build' the setup target/script will run as well automatically. 
getcommitid: 
	$(eval COMMITID = $(shell git log -1 --pretty=format:"%H"))
getbranchname:
	$(eval BRANCH_NAME = $(shell git branch --show-current))

build: setup getcommitid getbranchname
	docker build --build-arg CD_SA_PASSWORD=$(CS_SA_PASSWORD) --build-arg IMAGE=mcr.microsoft.com/mssql/server:$(sqltag) -t $(REGISTRY_NAME)$(REPOSITORY_NAME)$(IMAGE_NAME):latest -t $(REGISTRY_NAME)$(REPOSITORY_NAME)$(IMAGE_NAME):$(BRANCH_NAME) -t $(REGISTRY_NAME)$(REPOSITORY_NAME)$(IMAGE_NAME):$(sqltag) -t $(REGISTRY_NAME)$(REPOSITORY_NAME)$(IMAGE_NAME):$(sqltag).$(BRANCH_NAME)  -t $(REGISTRY_NAME)$(REPOSITORY_NAME)$(IMAGE_NAME):$(sqltag).$(BRANCH_NAME).$(COMMITID) .


build_%: setup
	./build/build.ps1 -registry '$(REGISTRY_NAME)' -repository '$(REPOSITORY_NAME)' -SQLtagNames $*

run: 
	@docker run -d -p 1433:1433 -e ACCEPT_EULA=Y --name=$(IMAGE_NAME) $(REGISTRY_NAME)$(REPOSITORY_NAME)$(IMAGE_NAME):$(sqltag)
save_%:
	docker save -o $*.tar $(REGISTRY_NAME)$(REPOSITORY_NAME)$(IMAGE_NAME):$*_latest
test:
	Invoke-Pester ./tests/

Install_tsqlt_to_%:
	docker exec $(IMAGE_NAME) pwsh -f /installTSQLT.ps1 -db "$*" -sa_password "$([Environment]::GetEnvironmentVariable('SA_PASSWORD', 'User') | ConvertTo-SecureString | ConvertFrom-SecureString -AsPlainText)"

# clean: up after yourself. I have itty bitty storage on my development machine, so I need to make sure I reclaim as much space as possible! 
clean:
	-@docker stop $(IMAGE_NAME)
	-@docker rm -v $(IMAGE_NAME)
clean_envvars:
	-[Environment]::SetEnvironmentVariable("SA_PASSWORD","", "User")