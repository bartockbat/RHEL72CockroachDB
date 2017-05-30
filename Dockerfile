FROM rhel7:latest

MAINTAINER Tobias Schottdorf <tobias.schottdorf@gmail.com>  

#recommended LABELS for RHEL7 
LABEL name="rhel72/CockroachDB"
LABEL version="CockroachDB version 0.10.1"
LABEL vendor="CockroachDB"
LABEL release="Opensource Edition"

#Atomic Help File
COPY help.1 /help.1

#Create dir for binary and script
RUN mkdir -p /cockroach    

#Copy files to container
COPY /cockroach /cockroach 

#Working Dirctory
WORKDIR /cockroach/    

#Expose TCP Ports
EXPOSE 26257/tcp 8080/tcp    

#Run the script to start up the DB
ENTRYPOINT ["/cockroach/cockroach.sh"]     
         
