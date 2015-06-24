{% set user = salt['pillar.get']('zinibu_common:app_user', 'user') %}

python-test:
  cmd.run:
    - name: echo 'Python testing. This is the user variable passed via pillar {{ user }}'
