#!/bin/bash

# Initializes Nginx and the git cgi scripts
# for git http-backend through fcgiwrap.
#
# Usage:
#   entrypoint <commands>
#
# Commands:
#   -start    starts the git server (nginx + fcgi)
#
#   -init     turns directories under `/var/lib/initial`
#             into bare repositories at `/var/lib/git`
# 

set -o errexit
set -o xtrace


readonly GIT_PROJECT_ROOT="/var/lib/git"
readonly GIT_INITIAL_ROOT="/var/lib/initial"
readonly FCGIPROGRAM=/usr/bin/fcgiwrap
readonly USERID=nginx
readonly SOCKUSERID=$USERID
readonly FCGISOCKET=/var/run/fcgiwrap.socket


main () {
  mkdir -p $GIT_PROJECT_ROOT

  while [ $# != "0" ]; do
    case $1 in
      -start)   initialize_services
                ;;
      
      -init)    clean_git_root
                initialize_initial_repositories
                ;;
    esac
    shift
  done

}

clean_git_root () {
  rm -rf $GIT_PROJECT_ROOT/* 
}

initialize_services () {
  /usr/bin/spawn-fcgi -s $FCGISOCKET -F 10 -u $USERID -U $USERID -g $USERID -- $FCGIPROGRAM 
  chown -R nginx $GIT_PROJECT_ROOT

  exec nginx -g "daemon off;"
}


initialize_initial_repositories () {
  cd $GIT_INITIAL_ROOT
  for dir in $(find . -name "*" -type d -maxdepth 1 -mindepth 1); do
    echo "Initializing repository $dir"
    init_and_commit $dir
  done
}


init_and_commit () {
  local dir=$1
  local tmp_dir=`mktemp -d`

  cp -r $dir/* $tmp_dir
  pushd . >/dev/null
  cd $tmp_dir

  if [[ -d "./.git" ]]; then
    rm -rf ./.git
  fi

  git init
  git add --all .
  git commit -m "first commit"

  ls $GIT_PROJECT_ROOT
  git clone --bare $tmp_dir $GIT_PROJECT_ROOT/${dir}.git

  popd >/dev/null
}


main "$@"

