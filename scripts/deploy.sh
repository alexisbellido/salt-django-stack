#!/bin/bash -e

salt-run state.orchestrate zinibu.deploy

# Restart webheads, which involves nginx and gunicorn as service
# (requires 'webhead' role grains setup in /etc/salt/minion).
salt -G 'roles:webhead' service.restart zinibu

# Restart Varnish servers (requires 'varnish' role grains setup in /etc/salt/minion).
salt -G 'roles:varnish' service.restart varnish

# Restart HAProxy servers (requires 'haproxy' role grains setup in /etc/salt/minion).
salt -G 'roles:haproxy' service.restart haproxy

