zinibu_basic:
  app_user: vagrant
  app_group: vagrant
  root_user: root
  project:
    name: zinibu_dev
    pyvenvs_dir: pyvenvs

    # keys of webheads must match minion ids
    webheads:
      django5:
          public_ip: 192.168.1.95
          private_ip: 192.168.33.15
          nginx_port: 81
          gunicorn_port: 8000
          maxconn_dynamic: 250
          maxconn_static: 50
          slowstart: 10s
      django6:
          public_ip: 192.168.1.96
          private_ip: 192.168.33.16
          nginx_port: 81
          gunicorn_port: 8000
          maxconn_dynamic: 250
          maxconn_static: 50
          slowstart: 10s
      django7:
          public_ip: 192.168.1.97
          private_ip: 192.168.33.17
          nginx_port: 81
          gunicorn_port: 8000
          maxconn_dynamic: 250
          maxconn_static: 50
          slowstart: 10s

    varnish_check: '/varnishcheck'

    # keys must match minion ids
    varnish_servers:
      django5:
          public_ip: 192.168.1.95
          private_ip: 192.168.33.15
          port: 83
          maxconn_cache: 1000
#      django6:
#          public_ip: 192.168.1.96
#          private_ip: 192.168.33.16
#          port: 83
#          maxconn_cache: 1000

    # if using keepalived, put the virtual IPs in the next two lines
    haproxy_frontend_public_ip: 192.168.1.95
    haproxy_frontend_private_ip: 192.168.33.15
    haproxy_frontend_port: 80
    haproxy_check: '/haproxycheck'
    haproxy_app_check_url: '/myapp/appcheck/'
    haproxy_app_check_expect: '[oO][kK]'
    haproxy_static_check_url: '/static/myapp/staticcheck.txt'

    # keys must match minion ids
    haproxy_servers:
      django5:
          public_ip: 192.168.1.95
          private_ip: 192.168.33.15
          port: 80
          keepalived_priority: 101
          stats_ip: 192.168.1.95
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
          public_ip: 192.168.1.96
          private_ip: 192.168.33.16
          port: 80
          keepalived_priority: 100
          stats_ip: 192.168.1.96
          stats_port: 8998
          stats:
            enable: True
            hide-version: ""
            uri: "/admin?stats"
            show-desc: "Secondary load balancer"
            refresh: "20s"
            realm: "HAProxyStatistics2"
            auth: 'admin2:admin2'

    # keys must match minion ids
    glusterfs_nodes:
      django5:
          private_ip: 192.168.33.15
      django6:
          private_ip: 192.168.33.16

    # YAML alternative list of objects syntax
    #webheads:
    #  - {public_ip: 192.168.33.15, nginx_port: 80, gunicorn_port: 8000}
    #  - {public_ip: 192.168.33.16, nginx_port: 80, gunicorn_port: 8000}
    #  - {public_ip: 192.168.33.17, nginx_port: 80, gunicorn_port: 8000}
      
