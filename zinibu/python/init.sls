{% from "zinibu/map.jinja" import python with context %}

pip:
  pkg.installed:
    - name: {{ python.pip_pkg }}

# create one sls for creating venv and get venv names from pillar

create_pyvenv:
  cmd.run:
    - cwd: /home/vagrant/pyenvs
    - user: vagrant
    - group: vagrant
    - shell: /bin/bash
    - name: pyvenv-3.4 venv2 ; source venv2/bin/activate ; pip --version

# create state, probably in its own sls, to delete venv

# move installation of pip packages to its own sls and use pillar to list them
install_pip_packages:
  pip.installed:
    - names:
      - requests
      - Jinja2
    - bin_env: /home/vagrant/pyenvs/venv2
    - user: vagrant
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
