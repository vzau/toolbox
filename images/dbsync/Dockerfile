FROM ubuntu:18.04

RUN apt update && apt install -y mysql-client bash

WORKDIR /
COPY . /
RUN ls -l /

ENTRYPOINT ["bash", "/script.sh"]