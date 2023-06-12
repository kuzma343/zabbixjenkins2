FROM ubuntu:22.04

RUN apt-get update && apt-get install -y docker-compose
CMD docker-compose up
