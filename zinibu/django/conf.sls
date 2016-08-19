{% from "zinibu/map.jinja" import django with context %}
{% from "zinibu/map.jinja" import zinibu_basic with context %}

include:
  - zinibu.django.git_setup

{% set project_dir = '/home/' + zinibu_basic.app_user + '/' + zinibu_basic.project.name %}
{% set pyvenvs_dir = '/home/' + zinibu_basic.app_user + '/' + salt['pillar.get']('zinibu_basic:project:pyvenvs_dir', 'pyvenvs') %}
{% set pyvenv_name = salt['pillar.get']('zinibu_basic:project:name', 'venv') %}

# This is used with salt-run state.orchestrate zinibu.deploy, see README.rst,
# which is used only after the initial install has been done.
{% set deploy = salt['pillar.get']('deploy', False) %}
{% set apps = salt['pillar.get']('apps', []) %}

# Assume virtual environment was already created in zinibu.python
{%- if 'pip_packages' in django %}
  {%- for pip_package, properties in django.pip_packages.iteritems() %}

    {%- if deploy %}
      {%- if (apps|length and pip_package in apps) or not apps %}
deploying-package-{{ pip_package }} :
  cmd.run:
      {%- if 'branch' in properties %}
        {% set package_branch = properties.branch %}
      {%- else %}
        {% set package_branch = 'master' %}
      {%- endif %}
    - name: echo "Deploy application {{ pip_package }}\nBranch {{ package_branch }} ..."
      {%- endif %} # apps passed or no apps specified
    {%- endif %} # deploy

{%- if 'editable' in properties %}

create_django_app_directory_{{ pip_package }}:
  file.directory:
    - name: {{ pip_package }}
    - user: {{ zinibu_basic.app_user }}
    - group: {{ zinibu_basic.app_group }}
    - mode: 755
    - makedirs: True

{%- if (apps|length and pip_package in apps) or not apps %}
clone-django-app-repo-{{ pip_package }}:
  git.latest:
    - name: {{ properties.repo }}
{%- if 'branch' in properties %}
    - rev: {{ properties.branch }}
    - branch: {{ properties.branch }}
{%- endif %} # branch
    - user: {{ zinibu_basic.app_user }}
    - target: {{ pip_package }}
    - identity: /home/{{ zinibu_basic.app_user }}/.ssh/id_rsa
    - force_checkout: True
    - force_clone: True
    - force_reset: True
{% if not deploy %}
    - require:
      - file: create_django_app_directory_{{ pip_package }}
      - git: setup-git-user-name
      - git: setup-git-user-email
{%- endif %} # not deploy
{%- endif %} # apps passed or no apps specified

{%- endif %} # editable

{%- if (apps|length and pip_package in apps) or not apps %}
django-install-pip-package-{{ pip_package }}:
  pip.installed:
    - name: {{ pip_package }}
    - bin_env: {{ pyvenvs_dir }}/{{ pyvenv_name }}
    - user: {{ zinibu_basic.app_user }}
    - upgrade: True
    {%- if 'editable' in properties %}
    - editable: {{ pip_package }}
    {%- endif %} # editable
    {%- if 'test_pypi' in properties %}
    - index_url: https://testpypi.python.org/pypi
    {%- endif %} # test_pypi
{%- endif %} # apps passed or no apps specified

  {%- endfor %} # loop over pip_packages

{%- endif %} # pip_packages in django
