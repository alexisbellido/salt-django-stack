# Because on Ubuntu we don't have a current HAProxy in the usual repo, we add a PPA
# Use this is configuration files need to be reset.
# sudo apt-get -o Dpkg::Options::="--force-confmiss" install --reinstall haproxy
{% if salt['grains.get']('osfullname') == 'Ubuntu' %}
haproxy_ppa_repo:
  pkgrepo.managed:
    - ppa: vbernat/haproxy-1.5
    - require_in:
      - pkg: haproxy.install
    - watch_in:
      - pkg: haproxy.install
{% endif %}

haproxy.install:
  pkg.installed:
    - name: haproxy

haproxy.service:
{% if salt['pillar.get']('haproxy:enable', True) %}
  service.running:
    - name: haproxy
    - enable: True
    - reload: True
    - require:
      - pkg: haproxy
      - file: haproxy.service
    - watch:
      - file: haproxy.config
{% else %}
  service.dead:
    - name: haproxy
    - enable: False
{% endif %}
  file.replace:
    - name: /etc/default/haproxy
    - require:
      - file: haproxy.start_file
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

haproxy-test:
  cmd.run:
    - name: echo {{ salt['pillar.get']('haproxy:config_file_path', '/etc/haproxy/haproxy.cfg') }}
