{% set zinibu_basic = salt['pillar.get']('zinibu_basic', {}) -%}

# If getting the error "volume create: [VOLUME_NAME]: failed: [VOLUME_PATH] or a prefix of it is already part of a volume"
# Delete volume manually with "gluster volume delete [VOLUME_NAME]" and then do:
# setfattr -x trusted.glusterfs.volume-id /var/exports/static-zinibu_dev/
# setfattr -x trusted.gfid /var/exports/static-zinibu_dev/
# rm -rf /var/exports/static-zinibu_dev/.glusterfs
# Or, if the data can be deleted or moved:
# rm -rf /var/exports/static-zinibu_dev/
# see https://joejulian.name/blog/glusterfs-path-or-a-prefix-of-it-is-already-part-of-a-volume/ 

# I can specify --uid and --gid while creating user on Ubuntu but maybe I need to rethink
# way of creating a user for deployment, or maybe I create a group and put my user and that other
# user there. Review users and groups information.
# TODO fix user and group of mount, how to make sure uid and gid is the same for all clients?
# I can get uid with: id -u username
# I can get gid with: id -g groupname
# use backticks to get id in a command
# echo "the id is `id -u username"
# use cmd.run to set these options
#gluster volume set static-zinibu_dev storage.owner-uid 1000
#gluster volume set static-zinibu_dev storage.owner-gid 1000
# sudo mount /home/vagrant/zinibu_dev/static

glusterfs-volume-static-{{ zinibu_basic.project.name }}:
  cmd.run:
    - user: {{ zinibu_basic.root_user }}
    - name: gluster volume create static-{{ zinibu_basic.project.name }} {% if zinibu_basic.project.glusterfs_nodes|length > 1 %}replica {{ zinibu_basic.project.glusterfs_nodes|length }}{% endif %} transport tcp {% for id, node in salt['pillar.get']('zinibu_basic:project:glusterfs_nodes', {}).iteritems() %} {{ node.private_ip }}:/var/exports/static-{{ zinibu_basic.project.name }}{% endfor %} force
    - shell: /bin/bash
    - unless: "gluster volume info static-{{ zinibu_basic.project.name }}"

glusterfs-volume-static-{{ zinibu_basic.project.name }}-start:
  glusterfs.started:
    - name: static-{{ zinibu_basic.project.name }}
    - require:
      - cmd: glusterfs-volume-static-{{ zinibu_basic.project.name }}

# do this after confirmed connections
#sudo gluster volume set volume1 auth.allow gluster_client1_ip,gluster_client2_ip
# gluster volume set www auth.allow 192.168.56.*
# gluster volume set datastore auth.allow 10.1.1.*,10.5.5.1
