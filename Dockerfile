FROM registry.access.redhat.com/rhel-atomic

MAINTAINER Tobias Schottdorf <tobias.schottdorf@gmail.com>  

LABEL name="cockroachdb/cockroach" \
      vendor="CockroachDB" \
      version="0.10.1" \
      release="1" \
      summary="CockroachDB is ..." \
      description="CockroachDB will ....."

#Atomic Help File
COPY help.1 /help.1

### add licenses to this directory
COPY licenses /licenses

#Copy files to container
COPY cockroach /cockroach 

#Set perms to support non-root & arbitrary uid runtime in OpenShift
RUN chown -R 99:0 /cockroach && \
    chmod -R 775 /cockroach

#Working Dirctory
WORKDIR /cockroach/    

#Expose TCP Ports
EXPOSE 26257/tcp 8080/tcp    

#Non-root runtime
USER 99

#Run the script to start up the DB
ENTRYPOINT ["/cockroach/cockroach.sh"]     
CMD ["start","--insecure"]
