# necessary to bind haproxy frontend to IPs not configured on this host
net.ipv4.ip_nonlocal_bind:
  sysctl.present:
    - value: 1

haproxy.service:
{% if salt['pillar.get']('haproxy:enable', True) %}
  service.running:
    - name: haproxy
    - enable: True
    - reload: True
    - require:
      - file: haproxy.start_file
      - sysctl: net.ipv4.ip_nonlocal_bind
# to avoid apt-get update from haproxy_ppa_repo
#      - pkg: haproxy
    - watch:
      - file: haproxy.config
{% else %}
  service.dead:
    - name: haproxy
    - enable: False
{% endif %}
  file.replace:
    - name: /etc/default/haproxy
{% if salt['pillar.get']('haproxy:enabled', True) %}
    - pattern: ENABLED=0$
    - repl: ENABLED=1
{% else %}
    - pattern: ENABLED=1$
    - repl: ENABLED=0
{% endif %}
    - show_changes: True

haproxy.start_file:
  file.managed:
    - name: {{ salt['pillar.get']('haproxy:start_file_path', '/etc/default/haproxy') }}
    - source: salt://zinibu/haproxy/files/etc/default/haproxy
    - user: root
    - group: root
    - mode: 644

haproxy.config:
 file.managed:
   - name: {{ salt['pillar.get']('haproxy:config_file_path', '/etc/haproxy/haproxy.cfg') }}
   - source: salt://zinibu/haproxy/files/etc/haproxy/haproxy.cfg
   - template: jinja
   - user: root
   - group: root
   - mode: 644
