# Removes a virtual environment.
# salt 'minion_id' state.sls zinibu.python.rmenv pillar='{"zinibu_basic": {"app_user": "vagrant", "app_group": "vagrant"}, "python": {"pyvenvs_dir": "pyvenvs", "pyvenv_name": "zinibu_dev"}}'
# The command can accept parameters via pillar parameter as shown above or use the pillar information from the master. See how the variables, and their defaults, are defined below.

{% set user = salt['pillar.get']('zinibu_basic:app_user', 'user') %}
{% set group = salt['pillar.get']('zinibu_basic:app_group', 'group') %}
{% set pyvenvs_dir = '/home/' + user + '/' + salt['pillar.get']('python:pyvenvs_dir', 'pyvenvs') %}
{% set pyvenv_name = salt['pillar.get']('python:pyvenv_name', 'venv') %}

remove_pyvenv:
  cmd.run:
    - cwd: {{ pyvenvs_dir }}
    - user: {{ user }}
    - group: {{ group }}
    - shell: /bin/bash
    - name: rm -rf {{ pyvenv_name }}
