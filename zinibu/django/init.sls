{% from "zinibu/map.jinja" import django with context %}
{% from "zinibu/map.jinja" import zinibu_basic with context %}

{% set project_dir = '/home/' + zinibu_basic.app_user + '/' + zinibu_basic.project.name %}

{{ project_dir}}:
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
    - name: /home/{{ zinibu_basic.app_user }}/run-project.sh
    - args: collectstatic
    - user: {{ zinibu_basic.app_user }}
    - shell: /bin/bash
    - cwd: {{ project_dir }}
    - require:
      - git: clone-git-repo

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
