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
          public_ip: 192.168.33.15
          private_ip: 192.168.33.15
          #local_ip: 127.0.0.1
          local_ip: 192.168.33.15
          nginx_port: 80
          gunicorn_port: 8000
      django6:
          public_ip: 192.168.33.16
          private_ip: 192.168.33.16
          #local_ip: 127.0.0.1
          local_ip: 192.168.33.16
          nginx_port: 80
          gunicorn_port: 8000
      django7:
          public_ip: 192.168.33.17
          private_ip: 192.168.33.17
          #local_ip: 127.0.0.1
          local_ip: 192.168.33.17
          nginx_port: 80
          gunicorn_port: 8000

    # YAML alternative list of objects syntax
    #webheads:
    #  - {public_ip: 192.168.33.15, local_ip: 127.0.0.1, nginx_port: 80, gunicorn_port: 8000}
    #  - {public_ip: 192.168.33.16, local_ip: 127.0.0.1, nginx_port: 80, gunicorn_port: 8000}
    #  - {public_ip: 192.168.33.17, local_ip: 127.0.0.1, nginx_port: 80, gunicorn_port: 8000}
      
