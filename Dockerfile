FROM rhel7:latest
CMD ["/bin/bash"]   
MAINTAINER Tobias Schottdorf <tobias.schottdorf@gmail.com>  
RUN mkdir -p /cockroach    
COPY /cockroach /cockroach 
WORKDIR /cockroach/    
EXPOSE 26257/tcp 8080/tcp    
ENTRYPOINT ["/cockroach/cockroach.sh"]     
         
