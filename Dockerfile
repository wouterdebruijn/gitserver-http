FROM nginx:1.10.1-alpine
MAINTAINER Ciro S. Costa <ciro.costa@liferay.com>


RUN set -x && \
  apk --update upgrade                                  &&  \
  apk add  \
    git bash fcgiwrap spawn-fcgi

RUN set -x && \
  # git config
  git config --system http.receivepack true             &&  \
  git config --global user.email "gitserver@git.com"    &&  \
  git config --global user.name "Git Server"


ADD ./etc /etc
ADD ./entrypoint.sh /usr/local/bin/entrypoint


EXPOSE 80 443
ENTRYPOINT [ "entrypoint" ]
CMD [ "-start" ]
