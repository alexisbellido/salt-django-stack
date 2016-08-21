# base contains pillar data common to all environments
base:
  '*':
    - zinibu_nginx
    - zinibu_python
    - zinibu_gunicorn
    - zinibu_redis
    - zinibu_service
    - zinibu_varnish
    - zinibu_haproxy
    - zinibu_keepalived
    - zinibu_elasticsearch

staging:
  'staging*':
    - zinibu_basic
    - zinibu_postgresql
    - zinibu_django

production:
  'production*':
    - zinibu_basic
    - zinibu_postgresql
    - zinibu_django
