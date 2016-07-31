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
/etc/systemd/system/varnish.service.d/customexec.conf:
  file:
    - managed
    - makedirs: true
    - source: salt://zinibu/varnish/files/etc/systemd/system/varnish.service.d/customexec.conf
    - require:
      - pkg: varnish

# The following two have to run as execution modules for systemctl
# changes to work.
# See:
# http://stackoverflow.com/questions/20773400/salt-stack-using-execution-modules-in-sls 
# https://docs.saltstack.com/en/latest/ref/states/all/salt.states.module.html#module-salt.states.module
service.systemctl_reload:
  module.run:
    - require:
      - pkg: varnish
    - watch:
      - file: /etc/systemd/system/varnish.service.d/customexec.conf

service.restart varnish:
  module.run:
    - name: service.restart
    - m_name: varnish
    - require:
      - module: service.systemctl_reload

{% endif %}

# Not sure what this is for. Coming from https://github.com/saltstack-formulas/varnish-formula
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
