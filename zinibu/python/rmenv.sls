# Removes a project and its virtual environment.
# salt 'minion_id' state.sls zinibu.python.rmenv pillar='{"zinibu_basic": {"app_user": "vagrant", "app_group": "vagrant", "project": {"name": "zinibu_dev", "pyvenvs_dir": "pyvenvs"}} }'
# The command can accept parameters via pillar parameter as shown above or use the pillar information from the master. See how the variables, and their defaults, are defined below.
#
{% from "zinibu/map.jinja" import zinibu_basic with context %}

{% set pyvenvs_dir = '/home/' + zinibu_basic.app_user + '/' + salt['pillar.get']('zinibu_basic:project:pyvenvs_dir', 'pyvenvs') %}
{% set pyvenv_name = salt['pillar.get']('zinibu_basic:project:name', 'venv') %}
{% set project_dir = '/home/' + zinibu_basic.app_user + '/' + zinibu_basic.project.name %}
{% set run_project_script = '/home/' + zinibu_basic.app_user + '/run-' + zinibu_basic.project.name + '.sh' %}
{% set upstart_job_file = '/etc/init/' + zinibu_basic.project.name + '.conf' %}

nginx_restart:
  service.running:
    - name: nginx
    - watch:
      - file: /etc/nginx/sites-available/{{ zinibu_basic.project.name }}

/etc/nginx/sites-available/{{ zinibu_basic.project.name }}:
  file.absent:
    - require:
        - service: upstart_job_stopped

upstart_job_stopped:
  service.dead:
    - name: {{ zinibu_basic.project.name }}

{{ run_project_script }}:
  file.absent:
    - require:
        - service: upstart_job_stopped

{{ upstart_job_file }}:
  file.absent:
    - require:
        - service: upstart_job_stopped

{{ project_dir }}:
  file.absent:
    - require:
        - service: upstart_job_stopped

remove_pyvenv:
  cmd.run:
    - cwd: {{ pyvenvs_dir }}
    - user: {{ zinibu_basic.app_user }}
    - group: {{ zinibu_basic.app_group }}
    - shell: /bin/bash
    - name: rm -rf {{ pyvenv_name }}
    - require:
        - service: upstart_job_stopped
