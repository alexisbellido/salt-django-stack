base:
  'django5':
    - zinibu.glusterfs
    - zinibu.glusterfs.volumes
    - zinibu.postgresql
    - zinibu.redis
    - zinibu.varnish
    - zinibu.varnish.conf
    - zinibu.haproxy
    - zinibu.haproxy.conf
  'django6':
    - zinibu.glusterfs
    - zinibu.glusterfs.volumes
    - zinibu.varnish
    - zinibu.varnish.conf
    - zinibu.haproxy
    - zinibu.haproxy.conf
  'django*':
    - zinibu
