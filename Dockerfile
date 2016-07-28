FROM debian:jessie
MAINTAINER anyakichi@sopht.jp

ENV GIT_GROUP="-www-data"

RUN set -x && \
  apt-get update                                && \
  apt-get install -y fcgiwrap git gitweb nginx  && \
  rm -rf /var/lib/apt/lists/*                   && \
  echo "\ndaemon off;" >> /etc/nginx/nginx.conf && \
  chown -R www-data:www-data /var/lib/nginx

ADD ./entrypoint.sh /usr/local/bin/entrypoint
ADD nginx /etc/nginx/

RUN mkdir /etc/gitweb &&  \
    rm -f /etc/nginx/sites-enabled/default

EXPOSE 80 443
ENTRYPOINT [ "entrypoint" ]
CMD [ "-start" ]
