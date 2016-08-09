#!/bin/bash -e

# Run full install with state.hightstate and state.orchestrate.

# Setup Glusterfs in correct order (requires 'glusterfs_node' role grains setup in /etc/salt/minion).
# Disable exit immediately option then re-enable it.
set +e
salt-run state.orchestrate zinibu.bootstrap
set -e

# Main setup.
salt '*' state.highstate

# Restart Varnish servers (requires 'varnish' role grains setup in /etc/salt/minion).
salt -G 'roles:varnish' service.restart varnish

# Restart HAProxy servers (requires 'haproxy' role grains setup in /etc/salt/minion).
salt -G 'roles:haproxy' service.restart haproxy
