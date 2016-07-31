{% from "zinibu/map.jinja" import varnish with context %}
{% set zinibu_basic = salt['pillar.get']('zinibu_basic', {}) -%}
{% set settings = salt['pillar.get']('varnish', {}) -%}

include:
  - zinibu.varnish

# This state ID is going to have just a "require" instead of a "watch"
# statement because of:
#
# a) the varnish service is defined as reload=true and to actually apply changes
#    in this config file it's necessary a restart
# b) restart is potentially dangerous because it deletes the cache, so it's
#    preferrable to trigger an explicit and controlled restart after changing
#    this file
#
# As you probably know, to run a restart of the service you could use something
# like: salt 'varnish-node*' service.varnish restart.
{{ varnish.config }}:
  file:
    - managed
    - source: salt://zinibu/varnish/files/etc/default/varnish
    - template: jinja
    - require:
      - pkg: varnish
    - require_in:
      - service: varnish

# verify configuration with "varnishd -C -f /etc/varnish/default.vcl"
# deploy the vcl file and trigger a reload of varnish
/etc/varnish/default.vcl:
  file:
    - managed
    - makedirs: true
    - source: salt://zinibu/varnish/files/etc/varnish/default-{{ varnish.version }}.vcl
    - template: jinja
    - require:
      - pkg: varnish
    - watch_in:
      - service: varnish

{% if varnish.version == '4' %}
test-params-1:
  cmd.run:
    - name: echo 'TEST VARNISH 4'

/etc/systemd/system/varnish.service.d/customexec.conf:
  file:
    - managed
    - makedirs: true
    - source: salt://zinibu/varnish/files/etc/systemd/system/varnish.service.d/customexec.conf
    - require:
      - pkg: varnish
      #- module: service.systemctl_reload
      - cmd: service.systemctl_reload

service.systemctl_reload:
#  module.run:
  cmd.run:   
    - name: systemctl daemon-reload
    - runas: {{ zinibu_basic.root_user }}
    - shell: /bin/bash
    - require:
      - pkg: varnish
    #- watch:
    #  - file: /etc/systemd/system/varnish.service.d/customexec.conf
    - watch_in:
      - service: varnish
{% endif %}

# Below we delete the "absent" vcl files and we trigger a reload of varnish
#{% for file in settings.get('vcl', {}).get('files_absent', []) %}
#/etc/varnish/{{ file }}:
#  file:
#    - absent
#    - require:
#      - pkg: varnish
#    - watch_in:
#      - service: varnish
#{% endfor %}

