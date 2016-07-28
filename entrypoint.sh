#!/bin/sh

set -ex

# If not passed the default start command, just execute what the
# user wants.
[ "$1" = "-start" ] || {
  exec "$@"
}

cp /etc/nginx/sites-available/git-http /etc/nginx/sites-enabled/ ;
mkdir -p /etc/gitweb
cp /etc/nginx/git-http/gitweb.conf /etc/gitweb/ ; 

echo "FCGI_GROUP=www-data" > /etc/default/fcgiwrap 
service fcgiwrap start
service nginx start

tail -f /var/log/nginx/*.log
