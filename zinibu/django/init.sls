{% from "zinibu/map.jinja" import django with context %}
{% from "zinibu/map.jinja" import zinibu_basic with context %}

{% set project_dir = '/home/' + zinibu_basic.app_user + '/' + zinibu_basic.project.name %}
{% set run_project_script = '/home/' + zinibu_basic.app_user + '/run-' + zinibu_basic.project.name + '.sh' %}
{% set project_static_dir = '/home/' + zinibu_basic.app_user + '/' + zinibu_basic.project.name + '/static' %}

# GlusterFS related operations only run if there are 'glusterfs_nodes' defined
# in zinibu_basic.project

{{ run_project_script }}:
  file.managed:
    - name: 
    - source: salt://zinibu/django/files/run-project.sh
    - mode: 744
    - user: {{ zinibu_basic.app_user }}
    - group: {{ zinibu_basic.app_group }}
    - template: jinja
    - defaults:
        user: {{ zinibu_basic.app_user }}
        group: {{ zinibu_basic.app_group }}
        project_name: {{ zinibu_basic.project.name }}
  {% for id, webhead in zinibu_basic.project.webheads.iteritems() %}
    {% if grains['id'] == id %}
    - context:
        public_ip: {{ webhead.public_ip }}
        private_ip: {{ webhead.private_ip }}
        nginx_port: {{ webhead.nginx_port }}
        gunicorn_port: {{ webhead.gunicorn_port }}
    {% endif %}
  {% endfor %}

{{ project_dir }}:
  file.directory:
    - user: {{ zinibu_basic.app_user }}
    - group: {{ zinibu_basic.app_group }}
    - mode: 755
    - makedirs: True

clone-git-repo:
  git.latest:
    - name: {{ django.repo }}
    - rev: master
    - user: {{ zinibu_basic.app_user }}
    - target: {{ project_dir }}
    - identity: /home/{{ zinibu_basic.app_user }}/.ssh/id_rsa
    - force: True # Deprecated since version 2015.8.0: Use force_clone instead.
    - require:
      - file: {{ project_dir }}
      - git: setup-git-user-name
      - git: setup-git-user-email

# GlusterFS directories are mounted before this.
collectstatic:
  cmd.script:
    - name: {{ run_project_script }}
    - args: collectstatic
    - user: {{ zinibu_basic.app_user }}
    - shell: /bin/bash
    - cwd: {{ project_dir }}
    - require:
      - git: clone-git-repo
      - file: {{ project_dir }}
      - file: {{ run_project_script }}
      - file: {{ project_static_dir }}
{%- if 'glusterfs_nodes' in zinibu_basic.project %}
      - cmd: glusterfs-mount-static
{%- endif %}

{%- if 'glusterfs_nodes' in zinibu_basic.project %}
glusterfs-client:
  pkg.installed
{%- endif %}

{{ project_static_dir }}:
  file.directory:
    - user: {{ zinibu_basic.app_user }}
    - group: {{ zinibu_basic.app_group }}
    - mode: 755
    - makedirs: True

# Just need to mount one of the nodes from each client to get to the volume.
{%- if 'glusterfs_nodes' in zinibu_basic.project %}
  {%- for id, node in zinibu_basic.project.glusterfs_nodes.iteritems() %}
    {%- if loop.index == 1 %}
glusterfs-fstab-static:
  file.append:
    - name: /etc/fstab
    - text: |
        # GlusterFS mount
        {{ node.private_ip }}:static-{{ zinibu_basic.project.name }} {{ project_static_dir }} glusterfs defaults,_netdev 0 0
    - require:
      - file: {{ project_static_dir }}
    {%- endif %}
  {%- endfor %}
{%- endif %}

{%- if 'glusterfs_nodes' in zinibu_basic.project %}
glusterfs-mount-static:
  cmd.run:
    - user: {{ zinibu_basic.root_user }}
    - name: mount {{ project_static_dir }}
    - shell: /bin/bash
    - unless: mount | grep static-{{ zinibu_basic.project.name }}
    - require:
      - pkg: glusterfs-client
      - file: glusterfs-fstab-static
{%- endif %}

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
