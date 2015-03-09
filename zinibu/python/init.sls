{% from "zinibu/map.jinja" import python with context %}
{% from "zinibu/map.jinja" import postgres with context %}

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

# create one sls for creating venv and get venv names from pillar

# See:
# https://bugs.launchpad.net/ubuntu/+source/python3.4/+bug/1290847
# http://rem4me.me/2014/09/fixing-pyvenv-3-4-in-debian-ubuntu-mint-17-etc/
ensurepip:
  cmd.script:
    - name: salt://zinibu/python/files/ensurepip.sh
    - user: {{ salt['pillar.get']('zinibu_common:root_user', 'root') }}
    - shell: /bin/bash
    - cwd: /usr/lib/python3.4
    - unless: test -f /usr/lib/python3.4/ensurepip/_bundled/pip-1.5.4-py2.py3-none-any.whl

mkdir_pyvenv:
  cmd.run:
    - user: {{ salt['pillar.get']('zinibu_common:app_user', 'user') }}
    - name: mkdir -p {{ salt['pillar.get']('python:pyvenvs_dir', '/home/user/pyvenvs') }}
    - shell: /bin/bash

create_pyvenv:
  cmd.run:
    - cwd: {{ salt['pillar.get']('python:pyvenvs_dir', '/home/user/pyvenvs') }}
    - user: {{ salt['pillar.get']('zinibu_common:app_user', 'user') }}
    - group: {{ salt['pillar.get']('zinibu_common:app_user', 'group') }}
    - shell: /bin/bash
    - name: pyvenv-3.4 {{ salt['pillar.get']('python:pyvenv_name', 'venv') }} ; source {{ salt['pillar.get']('python:pyvenv_name', 'venv') }}/bin/activate ; pip --version
    - require:
      - cmd: ensurepip
      - cmd: mkdir_pyvenv

# move installation of pip packages to its own sls
{% for pip_package in salt['pillar.get']('python:pip_packages', []) %}
install_pip_package_{{ pip_package }}:
  pip.installed:
    - name: {{ pip_package }}
    - bin_env: {{ salt['pillar.get']('python:pyvenvs_dir', '/home/user/pyvenvs') }}/{{ salt['pillar.get']('python:pyvenv_name', 'venv') }}
    - user: {{ salt['pillar.get']('zinibu_common:app_user', 'user') }}
    - require:
      - cmd: create_pyvenv
      - pkg: pip
      - pkg: python3-dev
      - pkg: install-postgres-libpq-dev
{% endfor%}

#/tmp/file-{{ python.pyvenv_cmd }}:
#  file.managed:
#    - source: salt://zinibu/python/files/temp-file
#
#/tmp/file-python2:
#  file.managed:
#    - source: salt://zinibu/python/files/temp-file
#
#{{ salt['pillar.get']('python:testfilename', '/tmp/some-default-name') }}:
#  file.managed:
#    - source: salt://zinibu/python/files/temp-file
