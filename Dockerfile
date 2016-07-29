# Thanks to MAINTAINER anyakichi@sopht.jp for the initial
# work on the image

FROM debian:jessie
MAINTAINER Ciro S. Costa <ciro.costa@liferay.com>

RUN set -x && \
  apt-get update                                        &&  \
  apt-get install -y fcgiwrap git gitweb nginx          &&  \

  rm -rf /var/lib/apt/lists/*                           &&  \
  rm -f /etc/nginx/sites-enabled/default                &&  \
  echo "\ndaemon off;" >> /etc/nginx/nginx.conf         &&  \
  chown -R www-data:www-data /var/lib/nginx             &&  \
  git config --system http.receivepack true             &&  \
  git config --global user.email "gitserver@git.com"    &&  \
  git config --global user.name "Git Server"

ADD ./entrypoint.sh /usr/local/bin/entrypoint
ADD nginx /etc/nginx/

EXPOSE 80 443
ENTRYPOINT [ "entrypoint" ]
CMD [ "-start" ]
