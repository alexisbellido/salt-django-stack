zinibu_basic:
  app_user: vagrant
  app_group: vagrant
  root_user: root
  project:
    name: zinibu_dev
    # just for testing YAML alternative list of objects syntax. We will get IP addresses with grains
    # or maybe I do need this because grains in zinibu.nginx is not that good using public_ip: {{ grains['ip_interfaces']['eth1'][0] }}
    # and somehow assign ids to minions and map those ids to the public IP addresses.
    webheads:
      - {ip: 1.1.1.1, nginx_port: 80, gunicorn_port: 8001}
      - {ip: 2.2.2.2, nginx_port: 81, gunicorn_port: 8002}
      
