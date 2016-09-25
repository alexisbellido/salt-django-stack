{% set zinibu_basic = salt['pillar.get']('zinibu_basic', {}) -%}

{% if 'glusterfs_nodes' in zinibu_basic.project %}
  {% for id, node in salt['pillar.get']('zinibu_basic:project:glusterfs_nodes', {}).iteritems() %}
    {% if grains['id'] != id %}
glusterfs-peer-{{ id }}:
  glusterfs.peered:
    - name: {{ node.private_ip }}
    {%- endif %}
  {% endfor %}
{% endif %}
