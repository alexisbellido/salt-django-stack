base:
  'staging1':
    - zinibu.postgresql
    - zinibu.redis
    - zinibu.varnish
    - zinibu.varnish.conf
    - zinibu.haproxy
    - zinibu.haproxy.conf
  'staging*':
    - zinibu
