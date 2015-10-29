#!/bin/bash -e

# Install Salt on Ubuntu 14.04

add-apt-repository ppa:saltstack/salt
apt-get update

if [ "$1" == "master" ]; then
  apt-get install salt-master
  echo "$1 for master"
elif [ "$1" == "minion" ]; then
  apt-get install salt-minion
  echo "$1 for minion"
elif [ "$1" == "full" ]; then
  apt-get install salt-master
  apt-get install salt-minion
  echo "$1 for full"
fi
