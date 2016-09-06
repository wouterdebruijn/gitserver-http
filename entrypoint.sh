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

set -o errexit
set -o xtrace
set -o verbose

readonly GIT_PROJECT_ROOT="/var/lib/git"
readonly GIT_INITIAL_ROOT="/var/lib/initial"
readonly FCGIPROGRAM=/usr/bin/fcgiwrap
readonly USERID=nginx
readonly SOCKUSERID=$USERID
readonly FCGISOCKET=/var/run/git-http-backend.sock


main () {
  while [ $# != "0" ]; do
    case $1 in
      -start)   initialize_services &
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
  echo $FCGISOCKET $FCGIPROGRAM $USERID
  nginx -g "daemon off;"
  
  /usr/bin/spawn-fcgi -n -s $FCGISOCKET -f 10 -u $USERID -U $USERID -g $USERID -- $FCGIPROGRAM 
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

