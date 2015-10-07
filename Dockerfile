FROM debian:jessie

MAINTAINER Michał "rysiek" Woźniak <rysiek@hackerspace.pl>

RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install --no-install-recommends -y \
        zabbix-server-pgsql \
        postgresql-client && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

RUN mkdir -p /var/run/zabbix/ /var/log/zabbix-server/ && \
    chown -R zabbix:zabbix /var/run/zabbix/ /var/log/zabbix-server/
    
COPY entrypoint.sh /entrypoint.sh
RUN chmod a+x /entrypoint.sh

VOLUME ["/var/log/zabbix-server", "/etc/zabbix/"]

ENTRYPOINT ["/entrypoint.sh"]
CMD ["run_zabbix"]
#    select ldap_bind_password from config;