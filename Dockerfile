FROM ubuntu:22.04

RUN apt-get update
RUN apt-get install -y docker-compose

WORKDIR /app
COPY docker-compose.yml /app/docker-compose.yml

CMD ["docker-compose", "up"]

