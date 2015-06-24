{% set user = salt['pillar.get']('zinibu_common:app_user', 'user') %}

python-test:
  cmd.run:
    - name: echo 'Python testing. This is the user variable passed via pillar {{ user }}'

# See pillar.get() vs salt['pillar.get']() at http://docs.saltstack.com/en/latest/topics/pillar/index.html
{% for pip_package in salt['pillar.get']('python:pip_packages', []) %}
pillar-test-{{ pip_package }}:
  cmd.run:
    - name: echo 'Pillar testing, pip_package - {{ pip_package }}'
{% endfor %}
