{% set user = 'exampleuser' %}
{% set group = 'examplegroup' %}
{% set private_ips = { 1: '192.168.33.17', 2: '192.168.33.18', 3: '192.168.33.19' } %} 
{% set public_ips = { 1: '192.168.1.97', 2: '192.168.1.98' } %} 

zinibu_basic:
  app_user: {{ user }}
  app_group: {{ group }}
  do_token: xyz
  root_user: root
  project:
    name: zinibu
    pyvenvs_dir: pyvenvs

    # keys of webheads must match minion ids
    webheads:
      production1:
          public_ip: {{ public_ips[1] }}
          private_ip: {{ private_ips[1] }}
          nginx_port: 81
          gunicorn_port: 8000
          maxconn_dynamic: 250
          maxconn_static: 50
          slowstart: 10s
      production2:
          public_ip: {{ public_ips[2] }}
          private_ip: {{ private_ips[2] }}
          nginx_port: 81
          gunicorn_port: 8000
          maxconn_dynamic: 250
          maxconn_static: 50
          slowstart: 10s

    varnish_check: '/varnishcheck'

    # keys must match minion ids
    varnish_servers:
      production1:
          public_ip: {{ public_ips[1] }}
          private_ip: {{ private_ips[1] }}
          port: 83
          maxconn_cache: 1000
      production2:
          public_ip: {{ public_ips[2] }}
          private_ip: {{ private_ips[2] }}
          port: 83
          maxconn_cache: 1000

    # if using keepalived, put the floating IP here
    haproxy_frontend_public_ip: pub1
    # optional ssl certificate, must be created and copied here beforehand, see README
    #haproxy_ssl_cert: /srv/haproxy/ssl/example_com.pem
    haproxy_frontend_port: 80
    haproxy_frontend_secure_port: 443
    haproxy_check: '/haproxycheck'
    haproxy_app_check_url: '/app-check/'
    haproxy_app_check_expect: '[oO][kK]'
    haproxy_static_check_url: '/static/znbmain/static-check.txt'

    # keys must match minion ids
    # set anchor_ip when using floating IPs with Digital Ocean
    haproxy_servers:
      production1:
          anchor_ip: 0.0.0.0
          public_ip: {{ public_ips[1] }}
          private_ip: {{ private_ips[1] }}
          port: 80
          keepalived_priority: 101
          stats_port: 8998
          stats:
            enable: True
            hide-version: ""
            uri: "/admin?stats"
            show-desc: "Primary load balancer"
            refresh: "20s"
            realm: "HAProxyStatistics1"
            auth: 'admin:admin'
      production2:
          anchor_ip: 0.0.0.0
          public_ip: {{ public_ips[2] }}
          private_ip: {{ private_ips[2] }}
          port: 80
          keepalived_priority: 101
          stats_port: 8998
          stats:
            enable: True
            hide-version: ""
            uri: "/admin?stats"
            show-desc: "Secondary load balancer"
            refresh: "20s"
            realm: "HAProxyStatistics2"
            auth: 'admin:admin'

    # keys must match minion ids
    glusterfs_nodes:
      production1:
          private_ip: {{ private_ips[1] }}
      production2:
          private_ip: {{ private_ips[2] }}

    # keys must match minion ids
    redis_nodes:
      production1:
          private_ip: {{ private_ips[1] }}

    # keys must match minion ids
    elasticsearch_servers:
      production3:
          private_ip: {{ private_ips[3] }}
          port: 9200

    postgresql_servers:
      production1:
          public_ip: {{ public_ips[1] }}
          private_ip: {{ private_ips[1] }}
          port: 5432

    # YAML alternative list of objects syntax
    #webheads:
    #  - {public_ip: 192.168.33.15, nginx_port: 80, gunicorn_port: 8000}
    #  - {public_ip: 192.168.33.16, nginx_port: 80, gunicorn_port: 8000}
    #  - {public_ip: 192.168.33.17, nginx_port: 80, gunicorn_port: 8000}
