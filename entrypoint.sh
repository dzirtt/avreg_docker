#/bin/bash

#env vars, nend to put in container
#MYSQL_DATABASE
#MYSQL_USER: avreg
#MYSQL_PASSWORD: udsdozEyKNBR

notFirstRunFlag='/notFirstRun.flag'

#wait until mysql start
until echo '\q' | mysql -h database -P 3306 -u $MYSQL_USER -p$MYSQL_PASSWORD $MYSQL_DATABASE; do
	    >&2 echo "MySQL is unavailable - sleeping"
	    sleep 5
done

#need to create db structure
if [ ! -f $notFirstRunFlag ]; then
    sql=$(mysql -h database -P 3306 -u $MYSQL_USER -p$MYSQL_PASSWORD $MYSQL_DATABASE -e 'show tables;')

    if [ -z "$sql" ]; then
        echo -e "$MYSQL_DATABASE empty, create structure\n"
        mysql -h database -P 3306 -u $MYSQL_USER -p$MYSQL_PASSWORD $MYSQL_DATABASE < /dump.sql
        touch $notFirstRunFlag
    fi
fi


#start apache, avreg
service apache2 start
service avreg start

#tail logs to console
tail -f /var/log/avreg.log