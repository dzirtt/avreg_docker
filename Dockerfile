FROM debian:stretch

#add to start script or compose to set login:pass
#ENV LOGIN
#ENV PASSWORD

ENV DEBIAN_FRONTEND noninteractive

ENV DELUGE_HOME /home/deluge
ENV DELUGE_CONFIG_DIR ${DELUGE_HOME}/config
ENV DELUGE_DATA_DIR ${DELUGE_HOME}/data


# Install components
RUN apt-get update 
RUN apt-get install wget gnupg

RUN echo 'deb http://avreg.net/repos/6.3/debian/ stretch main contrib non-free'  >> /etc/apt/sources.list
RUN wget -q -O - http://avreg.net/repos/avreg.public.key | apt-key add -

RUN apt-get update 
RUN apt-get install avreg-server-mysql

#for debug purpose
RUN apt-get -qyy -t jessie install nano lsof 
    
RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

RUN useradd -m -s /bin/nologin avreg
#RUN mkdir -p ${DELUGE_DATA_DIR} ${DELUGE_CONFIG_DIR} ${DELUGE_DATA_DIR}/autoadd ${DELUGE_HOME}/tmp

#copy predefined config files
#ADD core.conf ${DELUGE_HOME}/tmp
# Expose ports
EXPOSE 80
EXPOSE 443

#VOLUME ${DELUGE_CONFIG_DIR}
#VOLUME ${DELUGE_DATA_DIR}

#ADD entrypoint.sh /home/deluge
#RUN chmod +x /home/deluge/entrypoint.sh

ENTRYPOINT ["/bin/bash"]
#CMD ["/home/deluge/entrypoint.sh"]
