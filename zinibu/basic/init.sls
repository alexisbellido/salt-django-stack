{% set user = salt['pillar.get']('zinibu_basic:app_user', 'user') %}
{% set group = salt['pillar.get']('zinibu_basic:app_group', 'group') %}

user-test:
  cmd.run:
    - name: echo 'user {{ user }} group {{ group }}'

user_{{ group }}_group:
  group:
  - name: {{ group }}
  - present

user_{{ user }}_user:
  user:
  - name: {{ user }}
  - present
  - remove_groups: False
  - require:
    - group: user_{{ group }}_group
