{% from "zinibu/map.jinja" import redis with context %}
{% from "zinibu/map.jinja" import zinibu_basic with context %}

redis-server:
  archive.extracted:
    - name: /usr/local/src/redis-server
    - source: http://download.redis.io/releases/{{ redis.version }}.tar.gz
    - source_hash: {{ redis.source_hash }}
    - archive_format: tar
    - tar_options: v

redis-prerequisites:
  pkg.installed:
    - pkgs:
      - build-essential
      - tcl8.5
    - refresh: True

redis-make:
  cmd.run:
    - cwd: /usr/local/src/redis-server/{{ redis.version }}
    - user: {{ zinibu_basic.root_user }}
    - group: {{ zinibu_basic.root_user }}
    - shell: /bin/bash
    - name: make
    - require:
      - pkg: redis-prerequisites
      - archive: redis-server

redis-make-install:
  cmd.run:
    - cwd: /usr/local/src/redis-server/{{ redis.version }}
    - user: {{ zinibu_basic.root_user }}
    - group: {{ zinibu_basic.root_user }}
    - shell: /bin/bash
    - name: make install
    - require:
      - cmd: redis-make

redis-install-script:
  cmd.run:
    - cwd: /usr/local/src/redis-server/{{ redis.version }}/utils
    - user: {{ zinibu_basic.root_user }}
    - group: {{ zinibu_basic.root_user }}
    - shell: /bin/bash
    - name: echo -n | bash install_server.sh
    - require:
      - cmd: redis-make-install

redis_6379:
  service.running:
    - enable: True
    - require:
      - cmd: redis-install-script
