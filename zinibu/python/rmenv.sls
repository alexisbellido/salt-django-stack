# Removes a virtual environment.
# salt 'minion_id' state.sls zinibu.python.rmenv pillar='{"zinibu_basic": {"app_user": "vagrant", "app_group": "vagrant", "project": {"pyvenvs_dir": "pyvenvs", "pyvenv_name": "zinibu_dev"}} }'
# The command can accept parameters via pillar parameter as shown above or use the pillar information from the master. See how the variables, and their defaults, are defined below.
#
{% from "zinibu/map.jinja" import zinibu_basic with context %}

{% set pyvenvs_dir = '/home/' + zinibu_basic.app_user + '/' + salt['pillar.get']('zinibu_basic:project:pyvenvs_dir', 'pyvenvs') %}
{% set pyvenv_name = salt['pillar.get']('zinibu_basic:project:name', 'venv') %}

remove_pyvenv:
  cmd.run:
    - cwd: {{ pyvenvs_dir }}
    - user: {{ zinibu_basic.app_user }}
    - group: {{ zinibu_basic.app_group }}
    - shell: /bin/bash
    - name: rm -rf {{ pyvenv_name }}
