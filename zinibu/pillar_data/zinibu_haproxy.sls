haproxy:
  enabled: True
  start_file_path: /etc/default/haproxy
  config_file_path: /etc/haproxy/haproxy.cfg
  global:
    stats:
      enable: True
      socketpath: /var/lib/haproxy/stats
#    ssl-default-bind-ciphers: "ECDHE-RSA-AES128-GCM-SHA256:ECDHE-RSA-AES256-GCM-SHA384:ECDHE-RSA-AES128-SHA256:ECDHE-RSA-AES256-SHA384"
#    ssl-default-bind-options: "no-sslv3 no-tlsv10 no-tlsv11"

    user: haproxy
    group: haproxy
    chroot:
      enable: True
      path: /var/lib/haproxy

    daemon: True

#  userlists:
#    userlist1:
#      users:
#        john: insecure-password doe
#        sam: insecure-password frodo
#      groups:
#        admins: users john sam
#        guests: users jekyll hyde jane

  defaults:
    log: global
    mode: http
    retries: 3
    options:
      - httplog
      - dontlognull
      - http-server-close
    timeouts:
      - connect         5s
      - client          1m
      - server          1m
      - check           10s
      - http-keep-alive 10s
      - http-request    10s
      - queue           1m

    errorfiles:
      400: /etc/haproxy/errors/400.http
      403: /etc/haproxy/errors/403.http
      408: /etc/haproxy/errors/408.http
      500: /etc/haproxy/errors/500.http
      502: /etc/haproxy/errors/502.http
      503: /etc/haproxy/errors/503.http
      504: /etc/haproxy/errors/504.http

  listens:
    stats:
      bind:
        - "0.0.0.0:8998"
      mode: http
      stats:
        enable: True
        uri: "/admin?stats"
        refresh: "20s"
    myservice:
      bind:
        - "*:8888"
      options:
        - forwardfor
        - http-server-close
      defaultserver:
        slowstart: 60s
        maxconn: 256
        maxqueue: 128
        weight: 100
      servers:
        web1:
          host: web1.example.com
          port: 80
          check: check
        web2:
          host: web2.example.com
          port: 18888
          check: check

  frontends:
    frontend1:
      name: www-http
      bind: "*:80"
      redirects: 
        - scheme https if !{ ssl_fc }
      reqadd:
        - "X-Forwarded-Proto:\\ http"
      default_backend: www-backend

  backends:
    backend1:
      name: www-backend
      balance: roundrobin
#      redirects: 
#        - scheme https if !{ ssl_fc }
      servers:
        server1:
          name: server1-its-name
          host: 192.168.33.15
          port: 81
          check: check
    static-backend:
      balance: roundrobin
#      redirects: 
#        - scheme https if !{ ssl_fc }
      options:
        - http-server-close
        - httpclose
        - forwardfor    except 127.0.0.0/8
        - httplog
      cookie: "pm insert indirect"
      stats:
        enable: True
        uri: /url/to/stats
        realm: LoadBalancer
        auth: "user:password"
      servers:
        some-server:
          host: 192.168.33.16
          port: 81
          check: check
#    api-backend:
#      options:
#        - http-server-close
#        - forwardfor
#      servers:
#        apiserver1:
#          host: apiserver1.example.com
#          port: 80
#          check: check
#        server2:
#          name: apiserver2
#          host: apiserver2.example.com
#          port: 80
#          check: check
#          extra: resolvers local_dns resolve-prefer ipv4
