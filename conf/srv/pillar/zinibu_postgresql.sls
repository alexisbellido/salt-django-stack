postgres:
  pg_hba.conf: salt://zinibu/postgresql/files/pg_hba.conf
  service: postgresql

  use_upstream_repo: False

  lookup:
    value: "will overwrite data in map.jinja"

  users:
    user1:
      password: 'secret'
      createdb: False
      createroles: False
      createuser: False
      inherit: True
      replication: False

    user2:
      password: 'supersecret'
      createdb: False
      createroles: False
      createuser: False
      inherit: True
      replication: False

    owner1:
      password: 'secret'
      createdb: True
      createroles: False
      createuser: False
      inherit: True
      replication: False

  databases:
    db1:
      owner: 'owner1'
      user: 'user1'
      template: 'template0'
      lc_ctype: 'C.UTF-8'
      lc_collate: 'C.UTF-8'

    db2:
      owner: 'owner1'
      user: 'user2'
      template: 'template0'
      lc_ctype: 'C.UTF-8'
      lc_collate: 'C.UTF-8'

  # This section will append your configuration to postgresql.conf.
  postgresconf: |
    listen_addresses = '*'

  # This section cover this ACL management of the pg_hba.conf file.
  # <type>, <database>, <user>, [host], <method>
  # Not using this as I prefer having IPs in zinibu_basic pillar
  acls:
    - ['local', 'db1', 'localUser']
    - ['host', 'db2', 'remoteUser', '123.123.0.0/24']
    - ['host', 'db1', 'user1', '192.168.33.15/32']
    - ['host', 'db1', 'user1', '192.168.33.16/32']
    - ['host', 'db1', 'user1', '192.168.33.17/32']

