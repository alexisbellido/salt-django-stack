{% from "zinibu/map.jinja" import python with context %}
{% from "zinibu/map.jinja" import postgres with context %}
{% from "zinibu/map.jinja" import zinibu_basic with context %}

{% set pyvenvs_dir = '/home/' + zinibu_basic.app_user + '/' + salt['pillar.get']('zinibu_basic:project:pyvenvs_dir', 'pyvenvs') %}
{% set pyvenv_name = salt['pillar.get']('zinibu_basic:project:name', 'venv') %}

include:
  - zinibu.basic
  # standard absolute include
  #- zinibu.python.python_test
  # and a relative include, note the dot
  #- .python_test

pip:
  pkg.installed:
    - name: {{ python.pip_pkg }}

pip_up_to_date:
  pip.installed:
    - name: pip
    - user: {{ zinibu_basic.app_user }}
    - upgrade: True
    - require:
      - pkg: pip
      - pkg: python3-dev
      - user: user_{{ zinibu_basic.app_user }}_user

pillow-prerequisites:
  pkg.installed:
    - pkgs:
      - libtiff5-dev
      - libjpeg8-dev 
      - zlib1g-dev 
      - libfreetype6-dev 
      - liblcms2-dev 
      - libwebp-dev 
      - tcl8.6-dev 
      - tk8.6-dev 
      - python-tk

python3-dev:
  pkg.installed:
    - name: {{ python.dev_pkg }}

python-venv:
  pkg.installed:
    - name: {{ python.venv_pkg }}
    - refresh: True
    - require:
      - pkg: python3-dev

{% if postgres.pkg_libpq_dev != False %}
install-postgres-libpq-dev:
  pkg.installed:
    - name: {{ postgres.pkg_libpq_dev }}
{% endif %}

# no longer needed since python3.4-venv
## See:
## https://bugs.launchpad.net/ubuntu/+source/python3.4/+bug/1290847
## http://rem4me.me/2014/09/fixing-pyvenv-3-4-in-debian-ubuntu-mint-17-etc/
#ensurepip:
#  cmd.script:
#    - name: salt://zinibu/python/files/ensurepip.sh
#    - user: {{ zinibu_basic.root_user }}
#    - shell: /bin/bash
#    - cwd: {{ python.lib_dir }}
#    - unless: test -f /usr/lib/python3.4/ensurepip/_bundled/pip-1.5.4-py2.py3-none-any.whl

mkdir_pyvenv:
  cmd.run:
    - runas: {{ zinibu_basic.app_user }}
    - name: mkdir -p {{ pyvenvs_dir }}
    - shell: /bin/bash
    - require:
      - user: user_{{ zinibu_basic.app_user }}_user

create_pyvenv:
  cmd.run:
    - cwd: {{ pyvenvs_dir }}
    - runas: {{ zinibu_basic.app_user }}
    - shell: /bin/bash
    - name: {{ python.pyvenv_cmd }} {{ pyvenv_name }} ; source {{ pyvenv_name }}/bin/activate ; pip --version
    - require:
      - pkg: python-venv
      - cmd: mkdir_pyvenv
      - user: user_{{ zinibu_basic.app_user }}_user
# no longer needed since python3.4-venv
#      - cmd: ensurepip

# move installation of pip packages to its own sls
{% for pip_package in salt['pillar.get']('pip_packages', []) %}
install_pip_package_{{ pip_package }}:
  pip.installed:
    - name: {{ pip_package }}
    - bin_env: {{ pyvenvs_dir }}/{{ pyvenv_name }}
    - user: {{ zinibu_basic.app_user }}
    - upgrade: True
    - require:
      - cmd: create_pyvenv
      - pkg: pip
      - pkg: python3-dev
      - pkg: install-postgres-libpq-dev
      - pkg: pillow-prerequisites
      - user: user_{{ zinibu_basic.app_user }}_user
{% endfor%}
