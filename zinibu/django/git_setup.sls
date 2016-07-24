{% from "zinibu/map.jinja" import django with context %}
{% from "zinibu/map.jinja" import zinibu_basic with context %}

setup-git-user-name:
  git.config_set:
    - name: user.name
    - value: {{ django.user.name }}
    - user: {{ zinibu_basic.app_user }}
    - global: True

setup-git-user-email:
  git.config_set:
    - name: user.email
    - value: {{ django.user.email }}
    - user: {{ zinibu_basic.app_user }}
    - global: True

