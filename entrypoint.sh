#!/bin/bash

# Initializes Nginx and the git cgi scripts
# through fast cgi wrap.
#
# Usage:
#   entrypoint <commands>
#
# Commands:
#   -start    initialize the git server
#
#   -init     turn directories under `/var/lib/git/`
#             into bare repositories
# 

set -ex

readonly GIT_PROJECT_ROOT="/var/lib/git"
readonly GIT_INITIAL_ROOT="/var/lib/initial"


main () {
  while [ $# != "0" ]; do
    case $1 in
      -start)   configure_nginx
                initialize_services &
                ;;
      
      -init)    initialize_initial_repositories
                ;;
    esac
    shift
  done

  tail_logs
}


configure_nginx () {
  mkdir -p /etc/gitweb
  cp /etc/nginx/sites-available/git-http /etc/nginx/sites-enabled/
  cp /etc/gitweb.conf /etc/gitweb/
}


initialize_services () {
  echo "FCGI_GROUP=www-data" > /etc/default/fcgiwrap 
  service fcgiwrap start
  service nginx start
  echo "Started!"
}


initialize_initial_repositories () {
  cd $GIT_INITIAL_ROOT
  for dir in ./*; do 
    echo "Initializing repository $dir"
    init_and_commit $dir
    git clone --bare $dir $GIT_PROJECT_ROOT/${dir}.git
    rm -rf ${dir}/.git
  done
}


init_and_commit () {
  cd $dir

  if [[ -d "./.git" ]]; then
    rm -rf ./.git
  fi

  git init
  git add --all .
  git commit -m "first commit"
  cd ..
}


tail_logs () {
  echo "'tail'ing logs"
  sleep 3
  tail -f /var/log/nginx/error.log /var/log/nginx/access.log
}


main "$@"


