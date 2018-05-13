FROM debian:jessie


ENV DEBIAN_FRONTEND noninteractive

ENV db_password udsdozEyKNBR
ENV db_user avreg

RUN echo "mysql-server-5.5 mysql-server/root_password password 12345" | debconf-set-selections 
RUN echo "mysql-server-5.5 mysql-server/root_password_again password 12345" | debconf-set-selections

# remove policy file to allow start services while apt-get install
RUN rm -rf /usr/sbin/policy-rc.d

# Install components
RUN apt-get update 
RUN apt-get install -y wget gnupg apt-utils dialog rsyslog
#debug 
RUN apt-get -qyy install nano lsof net-tools

RUN echo 'deb http://avreg.net/repos/6.2/debian/ jessie main contrib non-free'  >> /etc/apt/sources.list
RUN wget -q -O - http://avreg.net/repos/avreg.public.key | apt-key add -

RUN apt-get update 
RUN apt-get install -y --force-yes avreg-server-mysql 

RUN service mysql start; mysqldump -h localhost -u root -p12345 avreg6_db > /dump.sql
RUN service avreg stop; service mysql stop; update-rc.d mysql disable
RUN rm /var/run/avreg/supervisor.sock

#create db secret files
RUN echo 'db-user = '${db_user}'' > "/etc/avreg/avregd.secret"
RUN echo 'db-passwd = '${db_password}'' >> "/etc/avreg/avregd.secret"
RUN cp /etc/avreg/avregd.secret /etc/avreg/avreg-mon.secret; cp /etc/avreg/avregd.secret /etc/avreg/avreg-site.secret
RUN cp /etc/avreg/avregd.secret /etc/avreg/avreg-unlink.secret

RUN sed -i "s/; db-host = ''/db-host = 'database'/" /etc/avreg/avreg.conf
RUN echo -e ':rawmsg, contains, "avreg"  /var/log/avreg.log\n& stop' > /etc/rsyslog.d/avreg.conf; touch /var/log/avreg.log

#apache setup
RUN echo "ServerName avreg.local" > /etc/apache2/conf-available/fqdn.conf; a2enconf fqdn
RUN a2enmod rewrite; sed -i '/DocumentRoot/aRewriteEngine  on\nRewriteRule    ^/$  /avreg [R]' '/etc/apache2/sites-available/000-default.conf'

RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

#create db avreg6_db

EXPOSE 80
EXPOSE 874

## store video, create volume to here
#VOLUME /var/spool/avreg

ADD entrypoint.sh /
RUN chmod +x /entrypoint.sh

ENTRYPOINT ["/bin/bash", "/entrypoint.sh"]
#CMD exec /bin/bash -c "trap : TERM INT; sleep infinity & wait"
