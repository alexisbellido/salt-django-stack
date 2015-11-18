keepalived.service:
  service.running:
    - name: keepalived
    - enable: True
    - reload: True
    - watch:
      - file: keepalived.config

keepalived.config:
  file.managed:
    - name: {{ salt['pillar.get']('keepalived:config_file_path', '/etc/keepalived/keepalived.conf') }}
    - source: salt://zinibu/keepalived/files/etc/keepalived/keepalived.conf
    - template: jinja
    - user: root
    - group: root
    - mode: 644

/etc/keepalived/master.sh:
  file.managed:
    - source: salt://zinibu/keepalived/files/etc/keepalived/master.sh
    - template: jinja
    - user: root
    - group: root
    - mode: 755

/usr/local/bin/assign-ip:
  file.managed:
    - source: salt://zinibu/keepalived/files/usr/local/bin/assign-ip
    - template: jinja
    - user: root
    - group: root
    - mode: 755
