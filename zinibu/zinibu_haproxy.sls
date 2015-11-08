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
    default-server: "inter 3s fall 2 rise 2 slowstart 60s"
    options:
      - httplog
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
