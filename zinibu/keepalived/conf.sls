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
