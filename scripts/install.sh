#!/bin/bash -e

# Run full install with state.hightstate and state.orchestrate.

# Setup Glusterfs in correct order (requires 'glusterfs_node' role grains setup in /etc/salt/minion).
salt-run state.orchestrate zinibu.bootstrap

# Main setup.
salt '*' state.highstate

# Restart Varnish servers (requires 'varnish' role grains setup in /etc/salt/minion).
salt -G 'roles:varnish' service.restart varnish
