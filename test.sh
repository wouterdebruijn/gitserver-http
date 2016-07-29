#!/bin/bash

set -o errexit
set -o xtrace


main () {
  init_docker_container
  # wait_for_server
  # assert_can_clone
}


init_docker_container () {
  docker-compose -f ./example/docker-compose.yml up -d
}


assert_can_clone () {
  git clone http://localhost:8082/initial/repo1.git
  [[ -f "repo1/file.txt" ]] || exit 1

  echo "OK!"
}


wait_for_server () {
  local check_addr=http://localhost/
  
  for i in `seq 1 5`; do
    echo "Trying [$check_addr]"
    if wget -qO- $check_addr > /dev/null;  then
      return 0
    fi
    sleep 1
  done

  echo "Error: address [$check_addr] didn't resolve OK after 5 tries."
  exit 1
}


cleanup () {
  local exit_code=$?

  echo "Exited with [$exit_code]"
  docker-compose -f ./example/docker-compose.yml stop
  rm -r myrepo
}


trap cleanup EXIT
main 

