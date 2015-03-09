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
