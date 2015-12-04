{% from "zinibu/map.jinja" import django with context %}
{% from "zinibu/map.jinja" import zinibu_basic with context %}

{% set pyvenvs_dir = '/home/' + zinibu_basic.app_user + '/' + salt['pillar.get']('zinibu_basic:project:pyvenvs_dir', 'pyvenvs') %}
{% set pyvenv_name = salt['pillar.get']('zinibu_basic:project:name', 'venv') %}

# Assume virtual environment was already created in zinibu.python
{%- if 'pip_packages' in django %}
{% for pip_package in django.pip_packages %}
django_install_pip_package_{{ pip_package }}:
  pip.installed:
    - name: {{ pip_package }}
    - bin_env: {{ pyvenvs_dir }}/{{ pyvenv_name }}
    - user: {{ zinibu_basic.app_user }}
    - upgrade: True
{% endfor%}
{%- endif %}

{%- if 'pip_editable_packages' in django %}
{% for pip_package in django.pip_editable_packages %}
django_install_pip_editable_package_{{ pip_package }}:
  pip.installed:
    - name: {{ pip_package }}
    - editable: {{ pip_package }}
    - bin_env: {{ pyvenvs_dir }}/{{ pyvenv_name }}
    - user: {{ zinibu_basic.app_user }}
    - upgrade: True
{% endfor%}
{%- endif %}

{%- if 'pip_test_packages' in django %}
{% for pip_package in django.pip_test_packages %}
django_install_pip_test_package_{{ pip_package }}:
  pip.installed:
    - name: {{ pip_package }}
    - bin_env: {{ pyvenvs_dir }}/{{ pyvenv_name }}
    - user: {{ zinibu_basic.app_user }}
    - upgrade: True
    - index_url: https://testpypi.python.org/pypi
{% endfor%}
{%- endif %}
