glusterfs-setup-server:
  salt.state:
    - tgt: 'roles:glusterfs_node'
    - tgt_type: grain
    - sls:
      - zinibu.glusterfs

glusterfs-peer-nodes:
  salt.state:
    - tgt: 'roles:glusterfs_node'
    - tgt_type: grain
    - sls:
      - zinibu.glusterfs.peer
    - require:
      - salt: glusterfs-setup-server

glusterfs-setup-volumes:
  salt.state:
    - tgt: 'roles:first_glusterfs_node'
    - tgt_type: grain
    - sls:
      - zinibu.glusterfs.volumes
    - require:
      - salt: glusterfs-peer-nodes

#test-run-command:
#  salt.function:
#    - name: cmd.run
#    - tgt: '*'
#    - arg:
#      - echo "TEST RUN COMMAND"
