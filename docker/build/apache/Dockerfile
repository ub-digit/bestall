FROM ubuntu:14.04

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update \
  && apt-get install -y apache2 vim less

RUN a2enmod proxy proxy_http headers autoindex 

CMD ["apachectl", "-DFOREGROUND", "-e", "debug"]

