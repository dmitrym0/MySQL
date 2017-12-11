#!/bin/bash
set -e

MYSQL_OS_USER=mysql

[[ "$UID" ]] || UID=$(id -u)

if [ $UID -eq 0 ] ; then

	chmod a+rw /var/log/mysqld.log
	chown -R $MYSQL_OS_USER: /var/run/mysqld/
	chown -R $MYSQL_OS_USER: /var/lib/mysql*
	
fi

exec "$@"
