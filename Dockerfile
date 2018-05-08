FROM debian:jessie

#add to start script or compose to set login:pass
#ENV LOGIN
#ENV PASSWORD

ENV DELUGE_HOME /home/deluge
ENV DELUGE_CONFIG_DIR ${DELUGE_HOME}/config
ENV DELUGE_DATA_DIR ${DELUGE_HOME}/data

RUN echo "mysql-server-5.5 mysql-server/root_password password 12345" | debconf-set-selections 
RUN echo "mysql-server-5.5 mysql-server/root_password_again password 12345" | debconf-set-selections

# remove policy file to allow start services while apt-get install
RUN rm -rf /usr/sbin/policy-rc.d

# Install components
RUN apt-get update 
RUN apt-get install -y wget gnupg apt-utils dialog

RUN echo 'deb http://avreg.net/repos/6.1/debian/ jessie main contrib non-free'  >> /etc/apt/sources.list
RUN wget -q -O - http://avreg.net/repos/avreg.public.key | apt-key add -

RUN apt-get update 
RUN apt-get install -y avreg-server-mysql 

#for debug purpose
RUN apt-get -qyy -t jessie install nano lsof 
    
RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

#RUN mkdir -p ${DELUGE_DATA_DIR} ${DELUGE_CONFIG_DIR} ${DELUGE_DATA_DIR}/autoadd ${DELUGE_HOME}/tmp

#create db avreg6_db

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
