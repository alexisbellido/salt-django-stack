glusterfs-setup-server:
  salt.state:
    - tgt: 'roles:glusterfs_node'
    - tgt_type: grain
    - sls:
      - zinibu.glusterfs

glusterfs-setup-volumes:
  salt.state:
    - tgt: 'roles:glusterfs_node'
    - tgt_type: grain
    - sls:
      - zinibu.glusterfs.volumes
    - require:
      - salt: glusterfs-setup-server
