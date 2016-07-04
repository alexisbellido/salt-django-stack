{% from "zinibu/map.jinja" import django with context %}
{% from "zinibu/map.jinja" import zinibu_basic with context %}

setup-git-user-name:
  git.config:
    - name: user.name
    - value: {{ django.user.name }}
    - user: {{ zinibu_basic.app_user }}
    - is_global: True

setup-git-user-email:
  git.config:
    - name: user.email
    - value: {{ django.user.email }}
    - user: {{ zinibu_basic.app_user }}
    - is_global: True

