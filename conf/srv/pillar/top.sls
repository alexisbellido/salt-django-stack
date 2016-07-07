# base contains pillar data common to all environments
base:
  '*':
    - zinibu_nginx
    - zinibu_python
    - zinibu_gunicorn
    - zinibu_redis
    - zinibu_upstart
    - zinibu_varnish
    - zinibu_haproxy
    - zinibu_keepalived

staging:
  'django[5-6]':
    - zinibu_basic
    - zinibu_postgresql
    - zinibu_django

production:
  'django[8-9]':
    - zinibu_basic
    - zinibu_postgresql
    - zinibu_django
