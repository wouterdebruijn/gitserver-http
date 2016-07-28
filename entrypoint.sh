#!/bin/sh

set -ex

# If not passed the default start command, just execute what the
# user wants.
[ "$1" = "-start" ] || {
  exec "$@"
}

[ ! -f /etc/nginx/sites-enabled/git-http ] && {
  cp /etc/nginx/sites-available/git-http /etc/nginx/sites-enabled/ ;
}

[ ! -f /etc/gitweb/gitweb.conf ] && {
  cp /etc/gitweb.conf /etc/gitweb/ ; 
}

echo "FCGI_GROUP=${GIT_GROUP}" > /etc/default/fcgiwrap 
service fcgiwrap start
service nginx start
