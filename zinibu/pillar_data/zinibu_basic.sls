zinibu_basic:
  app_user: vagrant
  app_group: vagrant
  root_user: root
  project:
    name: zinibu_dev
    pyvenvs_dir: pyvenvs

    # just for testing YAML alternative list of objects syntax. We will get IP addresses with grains
    webheads:
      - {ip: 1.1.1.1, nginx_port: 80, gunicorn_port: 8001}
      - {ip: 2.2.2.2, nginx_port: 81, gunicorn_port: 8002}
      
