{% from "zinibu/map.jinja" import django with context %}
{% from "zinibu/map.jinja" import zinibu_basic with context %}

test-params-1:
  cmd.run:
    - name: echo 'Parameters zinibu_basic.app_user IS {{ zinibu_basic.app_user }} and zinibu_basic.project.name IS {{ zinibu_basic.project.name }}'
