#!/bin/bash -e

# Install git and Salt on Ubuntu 14.04
echo "Usage:"
echo "./install-prerequisites-ubuntu.sh master|minion|full git_user_name git_user_email"
echo "Example:"
echo "./install-prerequisites-ubuntu.sh master \"Joe Doe\" name@example.com"
echo "Use quotes if the name contains spaces"
echo "=====================================================================================\n"

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

apt-get install git-core
git config --global user.name "$2"
git config --global user.email $3

