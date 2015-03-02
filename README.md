Salt formulas to setup Django with Gunicorn, Nginx, Redis and Varnish.

This is a Salt formula for the software stack used by zinibu.

Include zinibu in your top.sls to setup a standard webhead (Nginx, Gunicorn, and Django). To setup other servers include individual state files, like this:

base:
  'webhead':
    - zinibu
  'load-balancer':
    - zinibu.varnish
  'redis-server':
    - zinibu.redis
  'database':
    - zinibu.postgresql
