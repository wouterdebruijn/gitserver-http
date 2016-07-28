#!/bin/bash

main () {
  init_docker_container
  assert_can_clone
}

init_docker_container () {
  cd example && docker-compose up -d
}

assert_can_clone () {
  git clone http://localhost/repos/myrepo.git
  cd myrepo.git
  [[ -f "sample.txt" ]] || exit 1
}

main

