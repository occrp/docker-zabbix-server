#!/bin/bash

#
# Zabbix Server docker entrypoint
#

# TODO add more configuration options

# do we have a config file?
if [ ! -s /etc/zabbix/zabbix_server.conf ]; then
    # no, we don't; let's fix it!
    echo "config file not found at /etc/zabbix/zabbix_server.conf; recreating from a template"
    cp /usr/share/zabbix-server-pgsql/zabbix_server.conf /etc/zabbix/zabbix_server.conf
    [ -z ${ZABBIX_DBHOST+x} ] || sed -i -r -e "s/^# DBHost=.*$/DBHost=${ZABBIX_DBHOST//\//\\\/}/" /etc/zabbix/zabbix_server.conf # If set to empty string, socket is used for PostgreSQL.
    [ -z ${ZABBIX_DBPORT+x} ] || sed -i -r -e "s/^# DBPort=.*$/DBPort=${ZABBIX_DBPORT//\//\\\/}/" /etc/zabbix/zabbix_server.conf
    [ -z ${ZABBIX_DBNAME+x} ] || sed -i -r -e "s/^DBName=.*$/DBName=${ZABBIX_DBNAME//\//\\\/}/" /etc/zabbix/zabbix_server.conf
    [ -z ${ZABBIX_DBUSER+x} ] || sed -i -r -e "s/^DBUser=.*$/DBUser=${ZABBIX_DBUSER//\//\\\/}/" /etc/zabbix/zabbix_server.conf
    [ -z ${ZABBIX_DBPASSWORD+x} ] || sed -i -r -e "s/^# DBPassword=.*$/DBPassword=${ZABBIX_DBPASSWORD//\//\\\/}/" /etc/zabbix/zabbix_server.conf
else
    echo "config file found at /etc/zabbix/zabbix_server.conf"
    # unset the 
    echo "ignoring any ZABBIX_DB environment variables"
    unset -v ZABBIX_DBHOST ZABBIX_DBPORT ZABBIX_DBNAME ZABBIX_DBUSER ZABBIX_DBPASSWORD
    # let's get db connection data from the config file
    echo "retrieving database config"
    ZABBIX_DBHOST="$( egrep '^DBHost=.+$' /etc/zabbix/zabbix_server.conf | sed -r -e 's/^DBHost=(.+)$/\1/' )"
    ZABBIX_DBPORT="$( egrep '^DBPort=.+$' /etc/zabbix/zabbix_server.conf | sed -r -e 's/^DBPort=(.+)$/\1/' )"
    ZABBIX_DBNAME="$( egrep '^DBName=.+$' /etc/zabbix/zabbix_server.conf | sed -r -e 's/^DBName=(.+)$/\1/' )"
    ZABBIX_DBUSER="$( egrep '^DBUser=.+$' /etc/zabbix/zabbix_server.conf | sed -r -e 's/^DBUser=(.+)$/\1/' )"
    ZABBIX_DBPASSWORD="$( egrep '^DBPassword=.+$' /etc/zabbix/zabbix_server.conf | sed -r -e 's/^DBPassword=(.+)$/\1/' )"
fi

# if any of the vars is empty at this point, it means we're using the default value
echo "+- ZABBIX_DBHOST: ${ZABBIX_DBHOST:='localhost'}"
echo "+- ZABBIX_DBPORT: ${ZABBIX_DBPORT:='5432'}"
echo "+- ZABBIX_DBHOST: ${ZABBIX_DBNAME:='zabbix'}"
echo "+- ZABBIX_DBUSER: ${ZABBIX_DBUSER:='zabbix'}"
# yeah, the default password is empty. if it's set nothing will change, if it's not, it will get set to empty string
ZABBIX_DBPASSWORD="$ZABBIX_DBPASSWORD"

# check if we have a database configured
PGPASSWORD="$ZABBIX_DBPASSWORD"
echo "setting up the database..."
echo "+-- schema..."
gunzip -c /usr/share/zabbix-server-pgsql/schema.sql.gz | psql -U "$ZABBIX_DBUSER" -h "$ZABBIX_DBHOST" -p "$ZABBIX_DBPORT"
echo "+-- images..."
gunzip -c /usr/share/zabbix-server-pgsql/images.sql.gz | psql -U "$ZABBIX_DBUSER" -h "$ZABBIX_DBHOST" -p "$ZABBIX_DBPORT" 
echo "+-- data..."
gunzip -c /usr/share/zabbix-server-pgsql/data.sql.gz | psql -U "$ZABBIX_DBUSER" -h "$ZABBIX_DBHOST" -p "$ZABBIX_DBPORT"
echo "+-- done."

# run the darn thing
exec "$@"