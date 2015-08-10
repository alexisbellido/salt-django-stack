{% from "zinibu/map.jinja" import django with context %}
{% from "zinibu/map.jinja" import zinibu_basic with context %}

{% set project_dir = '/home/' + zinibu_basic.app_user + '/' + zinibu_basic.project.name %}
{% set run_project_script = '/home/' + zinibu_basic.app_user + '/run-' + zinibu_basic.project.name + '.sh' %}

{{ run_project_script }}:
  file.managed:
    - name: 
    - source: salt://zinibu/django/files/run-project.sh
    - mode: 644
    - user: {{ zinibu_basic.app_user }}
    - group: {{ zinibu_basic.app_group }}
    - template: jinja
    - defaults:
        user: {{ zinibu_basic.app_user }}
        group: {{ zinibu_basic.app_group }}
        project_name: {{ zinibu_basic.project.name }}
  {% for id, webhead in zinibu_basic.project.webheads.iteritems() %}
    {% if grains['id'] == id %}
    - context:
        public_ip: {{ webhead.public_ip }}
        local_ip: {{ webhead.local_ip }}
        nginx_port: {{ webhead.nginx_port }}
        gunicorn_port: {{ webhead.gunicorn_port }}
    {% endif %}
  {% endfor %}

{{ project_dir }}:
  file.directory:
    - user: {{ zinibu_basic.app_user }}
    - group: {{ zinibu_basic.app_group }}
    - mode: 755
    - makedirs: True

clone-git-repo:
  git.latest:
    - name: {{ django.repo }}
    - rev: master
    - user: {{ zinibu_basic.app_user }}
    - target: {{ project_dir }}
    - require:
      - file: {{ project_dir }}
      - git: setup-git-user-name
      - git: setup-git-user-email

collectstatic:
  cmd.script:
    - name: {{ run_project_script }}
    - args: collectstatic
    - user: {{ zinibu_basic.app_user }}
    - shell: /bin/bash
    - cwd: {{ project_dir }}
    - require:
      - git: clone-git-repo
      - file: {{ project_dir }}
      - file: {{ run_project_script }}

setup-git-user-name:
  git.config:
    - name: user.name
    - value: {{ django.user.name }}
    - user: {{ zinibu_basic.app_user }}
    - is_global: True

setup-git-user-email:
  git.config:
    - name: user.email
    - value: {{ django.user.email }}
    - user: {{ zinibu_basic.app_user }}
    - is_global: True

django-test:
  cmd.run:
    - name: echo 'Django project in /home/{{ zinibu_basic.app_user }}/{{ zinibu_basic.project.name }} from repo {{ django.repo }} {{ django.user.name }} {{ django.user.email }}'
    - require:
      - file: {{ project_dir }}
      - git: setup-git-user-name
      - git: setup-git-user-email
