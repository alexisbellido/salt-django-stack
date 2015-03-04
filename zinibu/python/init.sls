{% from "zinibu/map.jinja" import python with context %}

pip:
  pkg.installed:
    - name: {{ python.pip_pkg }}

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
    - name: mkdir -p /home/vagrant/pyvenvs
    - shell: /bin/bash

create_pyvenv:
  cmd.run:
    - cwd: /home/vagrant/pyvenvs
    - user: {{ salt['pillar.get']('zinibu_common:app_user', 'user') }}
    - group: {{ salt['pillar.get']('zinibu_common:app_user', 'group') }}
    - shell: /bin/bash
    - name: pyvenv-3.4 venv2 ; source venv2/bin/activate ; pip --version
    - require:
      - cmd: ensurepip
      - cmd: mkdir_pyvenv

# create state, probably in its own sls, to delete venv

# move installation of pip packages to its own sls and use pillar to list them
install_pip_packages:
  pip.installed:
    - names:
      - requests
      - Jinja2
    - bin_env: /home/vagrant/pyvenvs/venv2
    - user: {{ salt['pillar.get']('zinibu_common:app_user', 'user') }}
    - require:
      - cmd: create_pyvenv
      - pkg: pip

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
