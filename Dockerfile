FROM ubuntu:22.04

# Установка зависимостей и установка Zabbix
RUN apt-get update && apt-get install -y wget gnupg2 software-properties-common curl
RUN wget https://repo.zabbix.com/zabbix/6.2/ubuntu/pool/main/z/zabbix-release/zabbix-release_6.2-4%2Bubuntu22.04_all.deb
RUN dpkg -i zabbix-release_6.2-4+ubuntu22.04_all.deb
RUN apt-get update && apt-get -y install zabbix-server-mysql zabbix-frontend-php zabbix-apache-conf zabbix-sql-scripts zabbix-agent

# Установка MariaDB
RUN curl -LsS -O https://downloads.mariadb.com/MariaDB/mariadb_repo_setup
RUN bash mariadb_repo_setup --mariadb-server-version=10.6
RUN apt-get update && apt-get -y install mariadb-common mariadb-server-10.6 mariadb-client-10.6
RUN systemctl start mariadb && systemctl enable mariadb

# Создание пользователя и базы данных в MariaDB
ENV USERNAME=myuser
ENV PASSWORD=mypassword
ENV DB=mydatabase
RUN mysql -u root -p -e "CREATE USER '$USERNAME'@'localhost' IDENTIFIED BY '$PASSWORD';"
RUN mysql -u root -p -e "GRANT ALL PRIVILEGES ON *.* TO '$USERNAME'@'localhost';"
RUN mysql -u root -p -e "CREATE DATABASE $DB;"
RUN mysql -u root -p -e "FLUSH PRIVILEGES;"
RUN mysql -u root -p -e "SET GLOBAL log_bin_trust_function_creators = 1;"

# Импорт схемы базы данных Zabbix
RUN zcat /usr/share/zabbix-sql-scripts/mysql/server.sql.gz | mysql --default-character-set=utf8mb4 -u$USERNAME -p$PASSWORD $DB

RUN mysql -u root -p -e "SET GLOBAL log_bin_trust_function_creators = 0;"

# Настройка конфигурационного файла Zabbix
RUN sed -i "s/DBName=.*/DBName=${DB}/" /etc/zabbix/zabbix_server.conf
RUN sed -i "s/DBUser=.*/DBUser=${USERNAME}/" /etc/zabbix/zabbix_server.conf
RUN sed -i "s/#\s*DBPassword=.*/DBPassword=${PASSWORD}/" /etc/zabbix/zabbix_server.conf

# Настройка фаервола
RUN apt-get -y install ufw
RUN ufw enable
RUN ufw allow 10050/tcp
RUN ufw allow 10051/tcp
RUN ufw allow 161/tcp
RUN ufw allow 80/tcp
RUN ufw reload

# Запуск служб Zabbix и Apache
RUN systemctl restart zabbix-server zabbix-agent
RUN systemctl enable zabbix-server zabbix-agent
RUN systemctl restart apache2
RUN systemctl enable apache2

