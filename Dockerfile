# Використовуємо базовий образ Ubuntu 18.04
FROM ubuntu:18.04

# Оновлюємо пакетні списки та встановлюємо необхідні пакети
RUN apt-get update && apt-get install -y \
    apache2 \
    php \
    php-mysql \
    libapache2-mod-php \
    mysql-client \
    snmp \
    snmpd \
    fping \
    libiksemel-dev \
    libxml2-dev \
    libsnmp-dev \
    libevent-dev \
    libcurl4-openssl-dev \
    libpcre3-dev \
    libssl-dev \
    libffi-dev \
    libopenipmi-dev \
    libssh2-1-dev \
    libssh2-1 \
    libssh2-1-dev \
    libopenipmi-dev \
    libldap2-dev \
    libcurl3-dev \
    libmysqlclient-dev \
    libpq-dev \
    libxml2-dev \
    libjson-c-dev \
    libyajl-dev \
    libiksemel-utils \
    libiksemel-dev \
    libxml2-utils \
    libsnmp-dev \
    libevent-dev \
    libpcre3-dev \
    libssl-dev \
    libffi-dev \
    libopenipmi-dev \
    libssh2-1-dev \
    libopenipmi-dev \
    libldap2-dev \
    libcurl3-dev \
    libmysqlclient-dev \
    libpq-dev \
    libxml2-dev \
    libjson-c-dev \
    libyajl-dev \
    wget \
    curl \
    git

# Завантажуємо Zabbix сервер
RUN wget https://repo.zabbix.com/zabbix/5.4/ubuntu/pool/main/z/zabbix-release/zabbix-release_5.4-1+ubuntu18.04_all.deb && \
    dpkg -i zabbix-release_5.4-1+ubuntu18.04_all.deb && \
    apt-get update && \
    apt-get install -y zabbix-server-mysql zabbix-frontend-php zabbix-apache-conf zabbix-agent

# Налаштування бази даних для Zabbix
RUN service mysql start && \
    mysql -uroot -e "create database zabbix character set utf8 collate utf8_bin;" && \
    mysql -uroot -e "grant all privileges on zabbix.* to zabbix@localhost identified by 'password';" && \
    zcat /usr/share/doc/zabbix-server-mysql*/create.sql.gz | mysql -uzabbix -ppassword zabbix

# Налаштовуємо Zabbix сервер
RUN sed -i 's/# DBPassword=/DBPassword=password/' /etc/zabbix/zabbix_server.conf && \
    sed -i 's/# php_value date.timezone Europe\/Riga/php_value date.timezone Europe\/Kyiv/' /etc/zabbix/apache.conf

# Встановлюємо cron для Zabbix
RUN apt-get install -y cron && \
    echo '* * * * * root /usr/sbin/zabbix_server --check >/dev/null 2>&1' >> /etc/cron.d/zabbix

# Використовуємо порт 80 для веб-інтерфейсу Zabbix
EXPOSE 80

# Запускаємо службу Apache та Zabbix сервер
CMD service apache2 start && service zabbix-server start && tail -f /var/log/apache2/error.log
