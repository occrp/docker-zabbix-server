# docker-zabbix-server

This image does *not* include the non-free MIBs, expect [a lot of messages complaining about that](http://serverfault.com/questions/440285/why-does-snmp-fail-to-use-its-own-mibs). please fork and install `snmp-mibs-downloader` package (which will download the non-free stuff) if you need that functionality to work.
