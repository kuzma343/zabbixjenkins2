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

# Initialize PostgreSQL database
USER postgres
RUN /etc/init.d/postgresql start && \
    psql --command "CREATE USER myuser WITH PASSWORD 'mypassword';" && \
    createdb -O myuser mydatabase && \
    psql --command "ALTER USER myuser CREATEDB;"
USER root

# Import Zabbix database schema into PostgreSQL
RUN schema_location=$(find / -name "schema.sql.gz" -print -quit) && \
    su - postgres -c "pg_restore -U myuser -d mydatabase $schema_location"

# Configure Zabbix server to use PostgreSQL
RUN sed -i "s/DBHost=.*/DBHost=localhost/" /etc/zabbix/zabbix_server.conf
RUN sed -i "s/DBName=.*/DBName=mydatabase/" /etc/zabbix/zabbix_server.conf
RUN sed -i "s/DBUser=.*/DBUser=myuser/" /etc/zabbix/zabbix_server.conf
RUN sed -i "s/#\s*DBPassword=.*/DBPassword=mypassword/" /etc/zabbix/zabbix_server.conf

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

