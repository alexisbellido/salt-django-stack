#!/bin/bash -e

# Install git and Salt with basic configuration on Ubuntu (14.04, 14.10, 16.04)

if [ -z "$1" ]; then

  echo
  echo "Usage (run from the root of this repository):"
  echo "sudo scripts/install-prerequisites-ubuntu.sh master|minion|full git_user_name git_user_email"
  echo 
  echo "Alternatively, just to get next steps:"
  echo "sudo scripts/install-prerequisites-ubuntu.sh steps"
  echo
  echo "Example:"
  echo "sudo scripts/install-prerequisites-ubuntu.sh master \"Joe Doe\" name@example.com"
  echo "Use quotes if the name contains spaces."
  echo
  echo "Run it remotely:"
  echo "\curl -sSL https://raw.githubusercontent.com/alexisbellido/salt-django-stack/master/scripts/install-prerequisites-ubuntu.sh | sudo bash -s full \"Joe Doe\" name@example.com"
  echo

else
  TOP_DIR="/srv/salt"
  PILLAR_DIR="/srv/pillar"
  # sets $DISTRIB_ID and $DISTRIB_RELEASE
  source /etc/lsb-release
  ARCH=`uname -m`

  if [ "$1" == "minion" -o "$1" == "master" -o "$1" == "full" ]; then

    echo
    echo "Preparing Salt..."
    echo

    apt-get update
    apt-get install -y git

    apt-get install -y python-software-properties
    apt-get install -y software-properties-common
    apt-get install -y vim-gnome

#   Install a specific version of Salt for this version of Ubuntu
#   See https://repo.saltstack.com/#ubuntu
    if [ "$ARCH" == "x86_64" -a "$DISTRIB_ID" == "Ubuntu" -a "$DISTRIB_RELEASE" == "16.04" ]; then
      wget -O - https://repo.saltstack.com/apt/ubuntu/16.04/amd64/2016.3/SALTSTACK-GPG-KEY.pub | sudo apt-key add -
      cat >> /etc/apt/sources.list.d/saltstack.list << EOL
deb http://repo.saltstack.com/apt/ubuntu/16.04/amd64/2016.3 xenial main
EOL
    elif [ "$ARCH" == "x86_64" -a "$DISTRIB_ID" == "Ubuntu" -a "$DISTRIB_RELEASE" == "14.04" ]; then
      wget -O - https://repo.saltstack.com/apt/ubuntu/14.04/amd64/2016.3/SALTSTACK-GPG-KEY.pub | sudo apt-key add -
      cat >> /etc/apt/sources.list.d/saltstack.list << EOL
deb http://repo.saltstack.com/apt/ubuntu/14.04/amd64/2016.3 trusty main
EOL
    fi
    apt-get update

  fi
  
  if [ "$1" == "master" -o "$1" == "full" ]; then

    apt-get install -y salt-master

    if [[ $SUDO_COMMAND == "/bin/bash -s"* ]]; then
      ROOT_DIR="$PWD/salt-django-stack"
    else
      ROOT_DIR="$(dirname "$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )")"
    fi

    if [ ! -d  "$ROOT_DIR" ]; then
      sudo -u $SUDO_USER git clone git@github.com:alexisbellido/salt-django-stack.git
    fi
    
    if [ ! -d  "$TOP_DIR" ]; then
      echo "Creating $TOP_DIR..."
      mkdir -p $TOP_DIR
      cp $ROOT_DIR/conf/srv/salt/top.sls $TOP_DIR
    fi
    
    if [ ! -d  "$PILLAR_DIR" ]; then
      echo "Creating $PILLAR_DIR..."
      mkdir -p $PILLAR_DIR
      cp -r $ROOT_DIR/conf/srv/pillar/* $PILLAR_DIR
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
    - ${PILLAR_DIR}
  staging:
    - ${PILLAR_DIR}/staging
  production:
    - ${PILLAR_DIR}/production
EOL

    service salt-master restart

  fi
  
  if [ "$1" == "minion" -o "$1" == "full" ]; then
    apt-get install -y salt-minion
  fi
  
  if [ "$1" == "minion" -o "$1" == "master" -o "$1" == "full" ]; then
    git config --global user.name "$2"
    git config --global user.email $3
  fi

  if [ "$1" == "minion" -o "$1" == "master" -o "$1" == "full" -o "$1" == "steps" ]; then
  echo
  echo "====================================================================================================="
  echo
  echo "Next steps:"
  echo
  echo "1. Setup pillar data starting with zinibu_basic.sls and zinibu_django.sls in $PILLAR_DIR."
  echo "   Check production and staging subdirectories for environment-specific data."
  echo "   You can use sed to quickly make changes in zinibu_basic.sls:"
  echo "   sed -i -e s/django5/django8/g -e s/95/98/g -e s/15/18/g /srv/pillar/staging/zinibu_basic.sls"
  echo
  echo "2. Edit /etc/salt/minion in all minions to set id for targeting and roles and restart salt minion."
  echo
  echo "3. Setup /srv/salt/top.sls and /srv/pillar/top.sls with the corresponding targets and restart salt master"
  echo
  echo "4. Setup /etc/hosts to point all minions to the salt master using the \"salt\" hostname and"
  echo "   assign correct private IPs to each minion."
  echo
  echo "5. Accept keys on master using salt-key."
  echo
  echo "6. Change to the salt-django-stack directory and make magic start:"
  echo "   sudo scripts/install"
  echo
  echo "   Check out the README for more details."
  echo
  echo "====================================================================================================="
  fi

fi
