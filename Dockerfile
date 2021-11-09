# Default image is: mcr.microsoft.com/mssql/server:2017-CU8-ubuntu
# I am not explicitly adding this so that our CI never builds an image that we do not explicitly tell it.
ARG IMAGE=mcr.microsoft.com/mssql/server:2019-GDR2-ubuntu-16.04
FROM $IMAGE
USER 0:0
ARG CD_SA_PASSWORD

LABEL maintainer="brandonmcclure89@gmail.com" Description="A base image for running tSQLt unit tests on SQL server" 

 # Install Unzip
RUN apt-get update \
    && apt-get install unzip -y
# Install SQLPackage for Linux and make it executable
RUN wget -progress=bar:force -q -O sqlpackage.zip https://go.microsoft.com/fwlink/?linkid=2134311 \
    && unzip -qq sqlpackage.zip -d /opt/sqlpackage \
    && chmod +x /opt/sqlpackage/sqlpackage

# pwsh
RUN apt-get install -y wget apt-transport-https \
&& . /etc/os-release \
$$ echo $VERSION_ID \
&& wget -q https://packages.microsoft.com/config/ubuntu/$VERSION_ID/packages-microsoft-prod.deb \
&& dpkg -i packages-microsoft-prod.deb \
&& apt-get update \
&& apt-get install -y powershell

# create directory within SQL container for database files
RUN /bin/mkdir -p /var/opt/mssql/backup \
&& /bin/mkdir -p /var/opt/mssql/dbfiles

USER 10001:0

COPY --chown=10001:0 entrypoint.sh /usr/bin
COPY --chown=10001:0 init.sh /usr/bin
COPY --chown=10001:0 tSQLtInstall/ /tSQLtInstall/
COPY --chown=10001:0 installTSQLT.ps1 /usr/bin

ENV SA_PASSWORD=$CD_SA_PASSWORD
 
 EXPOSE 1433
HEALTHCHECK --interval=10s --timeout=3s --start-period=10s --retries=10 \
   CMD /opt/mssql-tools/bin/sqlcmd -S localhost -d master -V16 -U sa -P $SA_PASSWORD -Q "SELECT 1" || exit 1


CMD /bin/bash /usr/bin/entrypoint.sh