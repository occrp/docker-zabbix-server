FROM debian:jessie

MAINTAINER Michał "rysiek" Woźniak <rysiek@hackerspace.pl>

# DEBUG Zabbix 2.4.x
RUN cd /tmp/ && \
    apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install --no-install-recommends -y wget && \
    wget http://repo.zabbix.com/zabbix/2.4/debian/pool/main/z/zabbix-release/zabbix-release_2.4-1+jessie_all.deb && \
    dpkg -i zabbix-release_2.4-1+jessie_all.deb && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

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

EXPOSE 10051

ENTRYPOINT ["/entrypoint.sh"]
CMD ["run_zabbix"]
#    select ldap_bind_password from config;