{% from "zinibu/map.jinja" import django with context %}
{% from "zinibu/map.jinja" import zinibu_basic with context %}

{% set pyvenvs_dir = '/home/' + zinibu_basic.app_user + '/' + salt['pillar.get']('zinibu_basic:project:pyvenvs_dir', 'pyvenvs') %}
{% set pyvenv_name = salt['pillar.get']('zinibu_basic:project:name', 'venv') %}

# Assume virtual environment was already created in zinibu.python
{%- if 'pip_packages' in django %}
  {%- for pip_package, properties in django.pip_packages.iteritems() %}
django_install_pip_package_{{ pip_package }}:
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
