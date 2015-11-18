zinibu_basic:
  app_user: exampleuser
  app_group: examplegroup
  do_token: xyz
  root_user: root
  project:
    name: zinibu_dev
    pyvenvs_dir: pyvenvs

    # keys of webheads must match minion ids
    webheads:
      django5:
          public_ip: pub1
          private_ip: priv1
          nginx_port: 81
          gunicorn_port: 8000
          maxconn_dynamic: 250
          maxconn_static: 50
          slowstart: 10s
      django6:
          public_ip: pub2
          private_ip: priv2
          nginx_port: 81
          gunicorn_port: 8000
          maxconn_dynamic: 250
          maxconn_static: 50
          slowstart: 10s

    varnish_check: '/varnishcheck'

    # keys must match minion ids
    varnish_servers:
      django5:
          public_ip: pub1
          private_ip: priv1
          port: 83
          maxconn_cache: 1000
      django6:
          public_ip: pub2
          private_ip: priv2
          port: 83
          maxconn_cache: 1000

    # if using keepalived, put the floating IP here
    haproxy_frontend_public_ip: pub1
    haproxy_frontend_port: 80
    haproxy_check: '/haproxycheck'
    haproxy_app_check_url: '/myapp/appcheck/'
    haproxy_app_check_expect: '[oO][kK]'
    haproxy_static_check_url: '/static/myapp/staticcheck.txt'

    # keys must match minion ids
    haproxy_servers:
      django5:
          public_ip: pub1
          private_ip: priv1
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
      django6:
          public_ip: pub2
          private_ip: priv2
          port: 80
          keepalived_priority: 101
          stats_port: 8998
          stats:
            enable: True
            hide-version: ""
            uri: "/admin?stats"
            show-desc: "Secondary load balancer"
            refresh: "20s"
            realm: "HAProxyStatistics1"
            auth: 'admin:admin'

    # keys must match minion ids
    glusterfs_nodes:
      django5:
          private_ip: priv1
      django6:
          private_ip: priv2

    # keys must match minion ids
    redis_nodes:
      django5:
          private_ip: priv1

    postgresql_servers:
      django5:
          public_ip: pub1
          private_ip: priv1
          port: 5432
