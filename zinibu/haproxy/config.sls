haproxy.config:
 file.managed:
   - name: {{ salt['pillar.get']('haproxy:config_file_path', '/etc/haproxy/haproxy.cfg') }}
   - source: salt://zinibu/haproxy/files/haproxy.jinja
   - template: jinja
   - user: root
   - group: root
   - mode: 644

haproxy-test:
  cmd.run:
    - name: echo {{ salt['pillar.get']('haproxy:config_file_path', '/etc/haproxy/haproxy.cfg') }}
