{% from "zinibu/map.jinja" import zinibu_basic with context %}

git:
  pkg.installed

user_{{ zinibu_basic.app_group }}_group:
  group:
  - name: {{ zinibu_basic.app_group }}
  - present

user_{{ zinibu_basic.app_user }}_user:
  user:
  - name: {{ zinibu_basic.app_user }}
  - present
  - remove_groups: False
  - require:
    - group: user_{{ zinibu_basic.app_group }}_group
