FROM debian:jessie

MAINTAINER Michał "rysiek" Woźniak <rysiek@hackerspace.pl>

RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install --no-install-recommends -y \
        zabbix-server-pgsql && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

RUN mkdir -p /var/run/zabbix/ /var/log/zabbix-server/ && \
    chown -R zabbix:zabbix /var/run/zabbix/ /var/log/zabbix-server/
    
VOLUME ["/var/log/zabbix-server", "/etc/zabbix/"]

CMD ["/bin/bash", "-c", "zabbix_server -c /etc/zabbix/zabbix_server.conf; tail -f /var/log/zabbix-server/zabbix_server.log"]
#    select ldap_bind_password from config;