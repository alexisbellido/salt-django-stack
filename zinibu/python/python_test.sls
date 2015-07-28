{% from "zinibu/map.jinja" import project with context %}
{% set user = salt['pillar.get']('zinibu_basic:app_user', 'user') %}

python-test:
  cmd.run:
    - name: echo 'Python testing. This is the user variable passed via pillar {{ user }} and project.name {{ project.name }}'

python-test-webheads:
  cmd.run:
    - name: echo 'webheads ips [ {% for webhead in project.webheads %}{{ webhead.ip }} {% endfor %}]'

# See pillar.get() vs salt['pillar.get']() at http://docs.saltstack.com/en/latest/topics/pillar/index.html

pillar-get:
  cmd.run:
    - name: echo 'pillar.get [ {% for pip_package in salt['pillar.get']('pip_packages', []) %}{{ pip_package }} {% endfor %}]'

pillar-dict:
  cmd.run:
    - name: echo 'pillar as dictionary [ {% for pip_package in pillar['pip_packages'] %}{{ pip_package }} {% endfor %}]'

pillar-dict-names:
  cmd.run:
    - names:
{% for pip_package in pillar['pip_packages'] %}
      - echo "pillar as dictionary using names - {{ pip_package }}"
{% endfor %}

