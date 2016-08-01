{% from "zinibu/map.jinja" import django with context %}
{% from "zinibu/map.jinja" import zinibu_basic with context %}

# Examples passing pillar data as a dictionary parameter. See how the variables and their defaults are defined following pillar's structure:
# sudo salt '*' state.sls zinibu.python.python_test pillar='{"django": {"lookup": {"env": "staging"}}, "zinibu_basic": {"app_user": "joe", "app_group": "his_group", "project": {"name": "zinibu_dev", "pyvenvs_dir": "pyvenvs", "webheads": {}}} }'

#test-params-1:
#  cmd.run:
#    - name: echo 'Parameters zinibu_basic.app_user {{ zinibu_basic.app_user }} and zinibu_basic.project.name {{ zinibu_basic.project.name }}'
#
#test-params-2:
#  cmd.run:
#    - name: echo 'Parameters django.env {{ django.env }}'
#
#python-test:
#  cmd.run:
#    - name: echo 'Python testing. zinibu_basic.app_user {{ zinibu_basic.app_user }} and zinibu_basic.project.name {{ zinibu_basic.project.name }}'
#
## See pillar.get() vs salt['pillar.get']() at https://docs.saltstack.com/en/latest/topics/pillar/
#
#pillar-get:
#  cmd.run:
#    - name: echo 'pillar.get [ {% for pip_package in salt['pillar.get']('pip_packages', []) %}{{ pip_package }} {% endfor %}]'
#
#pillar-dict:
#  cmd.run:
#    - name: echo 'pillar as dictionary [ {% for pip_package in pillar['pip_packages'] %}{{ pip_package }} {% endfor %}]'
#
#pillar-dict-names:
#  cmd.run:
#    - names:
#{% for pip_package in pillar['pip_packages'] %}
#      - echo "pillar as dictionary using names - {{ pip_package }}"
#{% endfor %}
#
#python-test-webheads:
#  cmd.run:
#    - name: echo 'webheads ips [ {% for id, webhead in zinibu_basic.project.webheads.iteritems() %}{{ id }} {{ webhead.public_ip }} {% endfor %}]'
#
#{% for id, webhead in zinibu_basic.project.webheads.iteritems() %}
#{% if grains['id'] == id %}
#webhead-{{ id }}-test:
#  cmd.run:
#    - name: echo "{{ id }} {{ webhead.public_ip }}"
#{% endif %}
#{% endfor %}

{% set deploy = salt['pillar.get']('deploy', False) %}
{% if deploy %}
pillar-test-2:
  cmd.run:
    - name: echo "DEPLOY IS"
{% endif %}

# There has to be at least one other state for this to run
pillar-test-3:
  cmd.run:
    - name: echo "PRIVATE IP {{ zinibu_basic.app_user }} - {{ zinibu_basic.project.webheads.staging1.private_ip }} "

pillar-test-4:
  cmd.run:
    - name: echo "PUBLIC IP {{ zinibu_basic.app_user }} - {{ zinibu_basic.project.webheads.staging1.public_ip }} "
