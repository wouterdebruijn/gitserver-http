#!/bin/bash

# Installs the latest docker and docker-compose releases
# according to the official apt repository.
# ps.:	it's required to be run as root

set -o errexit


main () {
  bootstrap_apt
  install_docker
  install_compose
	service docker restart
  check_installation
}


bootstrap_apt () {
	sh -c 'echo "deb https://apt.dockerproject.org/repo ubuntu-precise main" > /etc/apt/sources.list.d/docker.list'
	apt-key adv --keyserver hkp://p80.pool.sks-keyservers.net:80 --recv-keys 58118E89F3A912897C070ADBF76221572C52609D
	apt-get update
	apt-key update
}


install_docker () {
	apt-get -qqy \
    -o Dpkg::Options::="--force-confdef" \
    -o Dpkg::Options::="--force-confold" \
    install docker-engine=1.11.2-0~precise
}


install_compose () {
	rm /usr/local/bin/docker-compose
	curl -L \
    https://github.com/docker/compose/releases/download/1.8.0-rc2/docker-compose-`uname -s`-`uname -m` > \
    /usr/local/bin/docker-compose
	chmod +x /usr/local/bin/docker-compose
}


check_installation () {
	docker-compose -v
	docker info
	curl localhost:2375/_ping
}


main

