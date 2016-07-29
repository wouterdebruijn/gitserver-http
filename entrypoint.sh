#!/bin/sh

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
  cd $GIT_PROJECT_ROOT
  for dir in ./*; do 
    echo "Initializing repository $dir"

    cd $dir
    perform_first_commit
    transform_to_bare_repo
  done
}


perform_first_commit () {
  git init
  git add --all .
  git commit -m "first commit"
}


transform_to_bare_repo () {
  local repo_name=$(basename $(pwd))
  pushd . >/dev/null

	mv .git .. && rm -fr *
	mv ../.git .
	mv .git/* .
	rmdir .git
	git config --bool core.bare true
  mv $repo_name ${repo_name}.git

  popd >/dev/null
}


tail_logs () {
  echo "'tail'ing logs"
  sleep 3
  tail -f /var/log/nginx/error.log /var/log/nginx/access.log
}


# If not passed the default start command, just execute what the
# user wants.

[ "${1%${1#?}}"x = '-x' ] && {
  exec "$@"
}

main "$@"


