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

    # keys must match minion ids
    varnish_servers:
      django5:
          public_ip: 192.168.1.95
          private_ip: 192.168.33.15
          port: 83
          maxconn_cache: 1000
      django6:
          public_ip: 192.168.1.96
          private_ip: 192.168.33.16
          port: 83
          maxconn_cache: 1000

    haproxy_frontend_public_ip: 192.168.1.95
    haproxy_frontend_private_ip: 192.168.33.15
    haproxy_frontend_port: 80
    haproxy_app_check_url: '/myapp/appcheck/'
    haproxy_app_check_expect: '[oO][kK]'
    haproxy_static_check_url: '/static/myapp/staticcheck.txt'

    # keys must match minion ids
    haproxy_servers:
      django5:
          public_ip: 192.168.1.95
          private_ip: 192.168.33.15
          port: 80
          stats_ip: 192.168.1.95
          stats_port: 8998
          stats:
            enable: True
            hide-version: ""
            uri: "/admin?stats"
            refresh: "20s"
            realm: "HAProxyStatistics1"
            auth: 'admin:admin'
      django6:
          public_ip: 192.168.1.96
          private_ip: 192.168.33.16
          port: 80
          stats_ip: 192.168.1.96
          stats_port: 8998
          stats:
            enable: True
            hide-version: ""
            uri: "/admin?stats"
            refresh: "20s"
            realm: "HAProxyStatistics2"
            auth: 'admin2:admin2'

    # YAML alternative list of objects syntax
    #webheads:
    #  - {public_ip: 192.168.33.15, nginx_port: 80, gunicorn_port: 8000}
    #  - {public_ip: 192.168.33.16, nginx_port: 80, gunicorn_port: 8000}
    #  - {public_ip: 192.168.33.17, nginx_port: 80, gunicorn_port: 8000}
      
