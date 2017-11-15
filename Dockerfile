FROM oraclelinux:7-slim

ARG PACKAGE_URL=https://repo.mysql.com/yum/mysql-5.7-community/docker/x86_64/mysql-community-server-minimal-5.7.20-1.el7.x86_64.rpm
ARG PACKAGE_URL_SHELL=https://repo.mysql.com/yum/mysql-tools-community/el/7/x86_64/mysql-shell-1.0.10-1.el7.x86_64.rpm

ENV MYSQL_LOG=/var/log/mysqld.log

# Install server
RUN rpmkeys --import https://repo.mysql.com/RPM-GPG-KEY-mysql \
  && yum install -y $PACKAGE_URL $PACKAGE_URL_SHELL \
  && yum clean all \
  && rm -rf /var/cache/yum \
  && mkdir /var/lib/mysql-health \
  && mkdir /docker-entrypoint-initdb.d

VOLUME /var/lib/mysql

COPY docker-entrypoint.sh /entrypoint.sh
COPY healthcheck.sh /var/lib/mysql-health/healthcheck.sh
COPY fix-permissions.sh /fix-permissions.sh
COPY docker-setup.sh /docker-setup.sh

RUN chmod a+x /*.sh /var/lib/mysql-health/healthcheck.sh

RUN /docker-setup.sh /var/lib/mysql \
	&& /docker-setup.sh /var/run/mysqld \
	&& /docker-setup.sh /var/lib/mysql-files \
	&& /docker-setup.sh /var/lib/mysql-health \
	&& /docker-setup.sh /var/log \
	&& ln -sf /dev/stdout ${MYSQL_LOG}

RUN sed -i -e "s%datadir=/var/lib/mysql%datadir=/var/lib/mysql/data%g" /etc/my.cnf

ENTRYPOINT ["/fix-permissions.sh","/entrypoint.sh"]
HEALTHCHECK CMD /var/lib/mysql-health/healthcheck.sh

EXPOSE 3306

CMD ["mysqld"]