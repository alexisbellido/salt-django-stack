{% from "zinibu/map.jinja" import django with context %}
{% from "zinibu/map.jinja" import zinibu_basic with context %}

include:
  - zinibu.django.git_setup

{% set project_dir = '/home/' + zinibu_basic.app_user + '/' + zinibu_basic.project.name %}
{% set pyvenvs_dir = '/home/' + zinibu_basic.app_user + '/' + salt['pillar.get']('zinibu_basic:project:pyvenvs_dir', 'pyvenvs') %}
{% set pyvenv_name = salt['pillar.get']('zinibu_basic:project:name', 'venv') %}

# Assume virtual environment was already created in zinibu.python
{%- if 'pip_packages' in django %}
  {%- for pip_package, properties in django.pip_packages.iteritems() %}

{%- if 'editable' in properties %}

create_django_app_directory_{{ pip_package }}:
  file.directory:
    - name: {{ pip_package }}
    - user: {{ zinibu_basic.app_user }}
    - group: {{ zinibu_basic.app_group }}
    - mode: 755
    - makedirs: True

clone-django-app-repo-{{ pip_package }}:
  git.latest:
    - name: {{ properties.repo }}
    - rev: master
    - user: {{ zinibu_basic.app_user }}
    - target: {{ pip_package }}
    - identity: /home/{{ zinibu_basic.app_user }}/.ssh/id_rsa
    - force_clone: True
    - require:
      - file: create_django_app_directory_{{ pip_package }}
      - git: setup-git-user-name
      - git: setup-git-user-email

{%- endif %}

django-install-pip-package-{{ pip_package }}:
  pip.installed:
    - name: {{ pip_package }}
    - bin_env: {{ pyvenvs_dir }}/{{ pyvenv_name }}
    - user: {{ zinibu_basic.app_user }}
    - upgrade: True
    {%- if 'editable' in properties %}
    - editable: {{ pip_package }}
    {%- endif %}
    {%- if 'test_pypi' in properties %}
    - index_url: https://testpypi.python.org/pypi
    {%- endif %}
  {%- endfor %}

{%- endif %}
