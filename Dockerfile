FROM ubuntu:22.04

# Set the timezone non-interactively
ENV DEBIAN_FRONTEND=noninteractive
ENV TZ=Europe/Paris

# Install dependencies and Zabbix
RUN apt-get update && apt-get install -y wget gnupg2 software-properties-common curl ufw

# Install PostgreSQL
RUN wget --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | apt-key add -
RUN echo "deb http://apt.postgresql.org/pub/repos/apt $(lsb_release -cs)-pgdg main" >> /etc/apt/sources.list.d/pgdg.list
RUN apt-get update && apt-get -y install postgresql-13

# Install Zabbix
RUN wget https://repo.zabbix.com/zabbix/6.2/ubuntu/pool/main/z/zabbix-release/zabbix-release_6.2-4%2Bubuntu22.04_all.deb
RUN dpkg -i zabbix-release_6.2-4+ubuntu22.04_all.deb
RUN apt-get update && apt-get -y install zabbix-server-pgsql zabbix-frontend-php zabbix-apache-conf zabbix-sql-scripts zabbix-agent

# Initialize PostgreSQL database, import Zabbix database schema, and configure Zabbix server
RUN service postgresql start && \
    su - postgres -c "psql --command \"CREATE USER myuser WITH PASSWORD 'mypassword';\"" && \
    su - postgres -c "createdb -O myuser mydatabase" && \
    schema_location=$(find / -type f -name "schema.sql.gz" -print -quit) && \
    cp $schema_location /tmp/schema.sql.gz && \
    su - postgres -c "pg_restore -U myuser -d mydatabase /tmp/schema.sql.gz" && \
    sed -i "s/DBHost=.*/DBHost=localhost/" /etc/zabbix/zabbix_server.conf && \
    sed -i "s/DBName=.*/DBName=mydatabase/" /etc/zabbix/zabbix_server.conf && \
    sed -i "s/DBUser=.*/DBUser=myuser/" /etc/zabbix/zabbix_server.conf && \
    sed -i "s/#\s*DBPassword=.*/DBPassword=mypassword/" /etc/zabbix/zabbix_server.conf

# Configure firewall
RUN ufw enable
RUN ufw allow 10050/tcp
RUN ufw allow 10051/tcp
RUN ufw allow 161/tcp
RUN ufw allow 80/tcp
RUN ufw reload

# Start Zabbix services and Apache
RUN service zabbix-server start && service zabbix-agent start
RUN update-rc.d zabbix-server enable && update-rc.d zabbix-agent enable
RUN service apache2 restart && service apache2 enable

CMD ["/usr/sbin/init"]

