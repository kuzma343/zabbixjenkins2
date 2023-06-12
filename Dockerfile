FROM ubuntu:22.04

RUN apt-get update
RUN apt-get install -y docker-compose

WORKDIR /main
COPY docker-compose.yml 

CMD ["docker-compose", "up"]

