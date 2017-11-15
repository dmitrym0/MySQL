#!/bin/bash
set -e

MYSQL_USER=mysql

[[ "$UID" ]] || UID=$(id -u)

if [ $UID -eq 0 ] ; then

	chmod a+rw /var/log/mysqld.log
	chown -R $MYSQL_USER: /var/run/mysqld/
	
fi

exec "$@"
