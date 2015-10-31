#!/bin/bash -e

# Install git and Salt with basic configuration on Ubuntu (14.04, 14.10)

if [ -z "$1" ]; then

  echo
  echo "Usage (run from the root of this repository):"
  echo "sudo scripts/install-prerequisites-ubuntu.sh master|minion|full git_user_name git_user_email"
  echo
  echo "Example:"
  echo "sudo scripts/install-prerequisites-ubuntu.sh master \"Joe Doe\" name@example.com"
  echo "Use quotes if the name contains spaces."
  echo "Make sure you run apt-get update before running this."
  echo

else

  echo
  echo "Preparing Salt..."
  echo

  apt-get install -y python-software-properties
  apt-get install -y software-properties-common
  apt-get install -y vim-gnome
  add-apt-repository -y ppa:saltstack/salt
  apt-get update
  
  if [ "$1" == "master" -o "$1" == "full" ]; then
    apt-get install -y salt-master
    ROOT_DIR="$(dirname "$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )")"
    TOP_DIR="/srv/salt"
    PILLAR_DIR="/srv/pillar"
    
    if [ ! -d  "$TOP_DIR" ]; then
      echo "Creating $TOP_DIR..."
      mkdir -p $TOP_DIR
      cp $ROOT_DIR/conf/srv/salt/top.sls $TOP_DIR
    fi
    
    if [ ! -d  "$PILLAR_DIR" ]; then
      echo "Creating $PILLAR_DIR..."
      mkdir -p $PILLAR_DIR
      cp $ROOT_DIR/conf/srv/pillar/* $PILLAR_DIR
    fi

    sed -i '/^# Added by install script$/,$d' /etc/salt/master
    cat >> /etc/salt/master << EOL

# Added by install script
file_roots:
  base:
    - /srv/salt
    - ${ROOT_DIR}

pillar_roots:
  base:
    - /srv/pillar
EOL
    service salt-master restart
  fi
  
  if [ "$1" == "minion" -o "$1" == "full" ]; then
    apt-get install -y salt-minion
  fi
  
  git config --global user.name "$2"
  git config --global user.email $3

  echo
  echo "Next steps:"
  echo "1. Setup pillar data starting with zinibu_basic.sls and zinibu_django.sls in $PILLAR_DIR."
  echo "2. Setup /srv/salt/top.sls and restart salt master"
  echo "3. Setup /etc/host to point all hosts to the salt master using the \"salt\" hostname."
  echo "4. Edit /etc/salt/minion in all minions to set an id and restart salt minion."
  echo "5. Accept keys on master using salt-key."
  echo "6. sudo salt '*' state.highstate"
  echo

fi
