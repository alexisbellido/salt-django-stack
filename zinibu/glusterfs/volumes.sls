{% set zinibu_basic = salt['pillar.get']('zinibu_basic', {}) -%}

# TODO run these before creating volume just in case there are remains
# see https://joejulian.name/blog/glusterfs-path-or-a-prefix-of-it-is-already-part-of-a-volume/ 
# just did  gluster volume delete static-zinibu_dev and salt needs to run the following
#setfattr -x trusted.glusterfs.volume-id /var/exports/static-zinibu_dev/
#setfattr -x trusted.gfid /var/exports/static-zinibu_dev/
#rm -rf /var/exports/static-zinibu_dev/.glusterfs
# time sudo salt 'django[5,6]' state.sls zinibu.glusterfs.volumes

install-attr:
  pkg.installed:
    - name: attr

glusterfs-volume-static-{{ zinibu_basic.project.name }}:
  cmd.run:
    - user: {{ zinibu_basic.root_user }}
    - name: echo "TEST"
#    - name: gluster volume create static-{{ zinibu_basic.project.name }} replica {{ zinibu_basic.project.glusterfs_nodes|length }} transport tcp {% for id, node in salt['pillar.get']('zinibu_basic:project:glusterfs_nodes', {}).iteritems() %} {{ node.private_ip }}:/var/exports/static-{{ zinibu_basic.project.name }}{% endfor %} force
    - shell: /bin/bash
    - unless: "gluster volume info static-{{ zinibu_basic.project.name }}"
# TODO move to the attr calls
    - require:
      - pkg: install-attr
