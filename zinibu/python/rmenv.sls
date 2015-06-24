# Removes a virtual environment.
# salt 'minion_id' state.sls zinibu.python.rmenv pillar='{"zinibu_common": {"app_user": "vagrant", "app_group": "vagrant"}, "python": {"pyvenvs_dir": "/home/vagrant/pyvenvs", "pyvenv_name": "zinibu_dev"}}'
# The command can accept parameters via pillar parameter as shown above or use the pillar information from the master. See how the variables, and their defaults, are defined below.

{% set pyvenvs_dir = salt['pillar.get']('python:pyvenvs_dir', '/home/user/pyvenvs') %}
{% set pyvenv_name = salt['pillar.get']('python:pyvenv_name', 'venv') %}
{% set user = salt['pillar.get']('zinibu_common:app_user', 'user') %}
{% set group = salt['pillar.get']('zinibu_common:app_group', 'group') %}

remove_pyvenv:
  cmd.run:
    - cwd: {{ pyvenvs_dir }}
    - user: {{ user }}
    - group: {{ group }}
    - shell: /bin/bash
    - name: rm -rf {{ pyvenv_name }}
