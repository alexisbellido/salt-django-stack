{% set zinibu_basic = salt['pillar.get']('zinibu_basic', {}) -%}

glusterfs-server:
  pkg.installed

{% if 'glusterfs_nodes' in zinibu_basic.project %}
{% for id, node in salt['pillar.get']('zinibu_basic:project:glusterfs_nodes', {}).iteritems() %}
glusterfs-peer-{{ id }}:
  glusterfs.peered:
    - name: {{ node.private_ip }}
    - require:
      - pkg: glusterfs-server
{% endfor %}
{% endif %}

/var/exports/static-{{ zinibu_basic.project.name }}:
  file.directory:
    - user: {{ zinibu_basic.root_user }}
    - group: {{ zinibu_basic.root_user }}
    - mode: 755
    - makedirs: True