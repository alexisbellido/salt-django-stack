{% from "zinibu/map.jinja" import python with context %}
{% from "zinibu/map.jinja" import postgres with context %}

{% set pyvenvs_dir = salt['pillar.get']('python:pyvenvs_dir', '/home/user/pyvenvs') %}
{% set pyvenv_name = salt['pillar.get']('python:pyvenv_name', 'venv') %}
{% set user = salt['pillar.get']('zinibu_common:app_user', 'user') %}
{% set group = salt['pillar.get']('zinibu_common:app_group', 'group') %}
{% set root_user = salt['pillar.get']('zinibu_common:root_user', 'root') %}

include:
  # standard absolute include
  #- zinibu.python.python_test
  # and a relative include, note the dot
  - .python_test

pip:
  pkg.installed:
    - name: {{ python.pip_pkg }}

python3-dev:
  pkg.installed:
    - name: {{ python.dev_pkg }}

{% if postgres.pkg_libpq_dev != False %}
install-postgres-libpq-dev:
  pkg.installed:
    - name: {{ postgres.pkg_libpq_dev }}
{% endif %}

testing:
  cmd.run:
    - user: {{ user }}
    - name: echo mkdir -p {{ pyvenvs_dir }}

# See:
# https://bugs.launchpad.net/ubuntu/+source/python3.4/+bug/1290847
# http://rem4me.me/2014/09/fixing-pyvenv-3-4-in-debian-ubuntu-mint-17-etc/
ensurepip:
  cmd.script:
    - name: salt://zinibu/python/files/ensurepip.sh
    - user: {{ root_user }}
    - shell: /bin/bash
    - cwd: {{ python.lib_dir }}
    - unless: test -f /usr/lib/python3.4/ensurepip/_bundled/pip-1.5.4-py2.py3-none-any.whl

mkdir_pyvenv:
  cmd.run:
    - user: {{ user }}
    - name: mkdir -p {{ pyvenvs_dir }}
    - shell: /bin/bash

create_pyvenv:
  cmd.run:
    - cwd: {{ pyvenvs_dir }}
    - user: {{ user }}
    - group: {{ group }}
    - shell: /bin/bash
    - name: {{ python.pyvenv_cmd }} {{ pyvenv_name }} ; source {{ pyvenv_name }}/bin/activate ; pip --version
    - require:
      - cmd: ensurepip
      - cmd: mkdir_pyvenv

# move installation of pip packages to its own sls
{% for pip_package in salt['pillar.get']('python:pip_packages', []) %}
install_pip_package_{{ pip_package }}:
  pip.installed:
    - name: {{ pip_package }}
    - bin_env: {{ pyvenvs_dir }}/{{ pyvenv_name }}
    - user: {{ user }}
    - require:
      - cmd: create_pyvenv
      - pkg: pip
      - pkg: python3-dev
      - pkg: install-postgres-libpq-dev
{% endfor%}
