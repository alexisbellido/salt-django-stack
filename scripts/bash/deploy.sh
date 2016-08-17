#!/bin/bash -e

# TODO pass a list of apps to deploy
# http://stackoverflow.com/questions/255898/how-to-iterate-over-arguments-in-bash-script
# http://stackoverflow.com/questions/1682214/pass-list-of-variables-to-bash-script

if [ -z "$1" -o "$1" == "--all" ]; then
  echo "Deploying project and applications..."
  salt-run state.orchestrate zinibu.deploy pillar="{'deploy_target': 'all'}"
elif [ "$1" == "--project" ]; then
  echo "Deploying project..."
  salt-run state.orchestrate zinibu.deploy pillar="{'deploy_target': 'project'}"
elif [ "$1" == "--apps" ]; then
  echo "Deploying apps..."
  salt-run state.orchestrate zinibu.deploy pillar="{'deploy_target': 'apps'}"
else
  echo "Please provide the correct options: --project, --apps or no options at all."
fi

# TODO make project restart optional
# Restart webheads, which involves nginx and gunicorn as service
# (requires 'webhead' role grains setup in /etc/salt/minion).
echo "Restart project..."
salt -G 'roles:webhead' service.restart zinibu

# TODO make varnish restart optional
echo "Restart Varnish..."
# Restart Varnish servers (requires 'varnish' role grains setup in /etc/salt/minion).
salt -G 'roles:varnish' service.restart varnish
