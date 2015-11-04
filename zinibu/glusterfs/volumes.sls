{% set zinibu_basic = salt['pillar.get']('zinibu_basic', {}) -%}

# If getting the error "volume create: [VOLUME_NAME]: failed: [VOLUME_PATH] or a prefix of it is already part of a volume"
# Delete volume manually with "gluster volume delete [VOLUME_NAME]" and then do:
# setfattr -x trusted.glusterfs.volume-id /var/exports/static-zinibu_dev/
# setfattr -x trusted.gfid /var/exports/static-zinibu_dev/
# rm -rf /var/exports/static-zinibu_dev/.glusterfs
# Or, if the data can be deleted or moved:
# rm -rf /var/exports/static-zinibu_dev/
# see https://joejulian.name/blog/glusterfs-path-or-a-prefix-of-it-is-already-part-of-a-volume/ 

glusterfs-volume-static-{{ zinibu_basic.project.name }}-set-user:
  cmd.run:
    - user: {{ zinibu_basic.root_user }}
    - name: gluster volume set static-{{ zinibu_basic.project.name }} storage.owner-uid `id -u {{ zinibu_basic.app_user }}`
    - shell: /bin/bash
    - require:
      - cmd: glusterfs-volume-static-{{ zinibu_basic.project.name }}

glusterfs-volume-static-{{ zinibu_basic.project.name }}-set-group:
  cmd.run:
    - user: {{ zinibu_basic.root_user }}
    - name: gluster volume set static-{{ zinibu_basic.project.name }} storage.owner-gid `id -g {{ zinibu_basic.app_user }}`
    - shell: /bin/bash
    - require:
      - cmd: glusterfs-volume-static-{{ zinibu_basic.project.name }}

{%- if 'webheads' in zinibu_basic.project %}
  {% for id, webhead in zinibu_basic.project.webheads.iteritems() %}
glusterfs-volume-static-{{ zinibu_basic.project.name }}-allow-{{ id }}:
  cmd.run:
    - user: {{ zinibu_basic.root_user }}
    - name: gluster volume set static-{{ zinibu_basic.project.name }} auth.allow {{ webhead.private_ip }}
    - shell: /bin/bash
    - require:
      - cmd: glusterfs-volume-static-{{ zinibu_basic.project.name }}
  {%- endfor %}
{%- endif %}

glusterfs-volume-static-{{ zinibu_basic.project.name }}:
  cmd.run:
    - user: {{ zinibu_basic.root_user }}
    - name: gluster volume create static-{{ zinibu_basic.project.name }} {% if zinibu_basic.project.glusterfs_nodes|length > 1 %}replica {{ zinibu_basic.project.glusterfs_nodes|length }}{% endif %} transport tcp {% for id, node in salt['pillar.get']('zinibu_basic:project:glusterfs_nodes', {}).iteritems() %} {{ node.private_ip }}:/var/exports/static-{{ zinibu_basic.project.name }}{% endfor %} force
    - shell: /bin/bash
    - unless: "gluster volume info static-{{ zinibu_basic.project.name }}"

glusterfs-volume-static-{{ zinibu_basic.project.name }}-start:
  cmd.run:
    - name: gluster volume start static-{{ zinibu_basic.project.name }}
    - require:
      - cmd: glusterfs-volume-static-{{ zinibu_basic.project.name }}
      # A stop before starting to make sure user and group stick
      - cmd: glusterfs-volume-static-{{ zinibu_basic.project.name }}-stop

glusterfs-volume-static-{{ zinibu_basic.project.name }}-stop:
  cmd.run:
    - user: {{ zinibu_basic.root_user }}
    - name: echo -e 'y\n' | gluster volume stop static-{{ zinibu_basic.project.name }}
    - shell: /bin/bash
    - onlyif: "gluster volume start static-{{ zinibu_basic.project.name }}"
    - require:
      - cmd: glusterfs-volume-static-{{ zinibu_basic.project.name }}-set-user
      - cmd: glusterfs-volume-static-{{ zinibu_basic.project.name }}-set-group
