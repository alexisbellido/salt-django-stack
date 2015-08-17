{% from "zinibu/map.jinja" import varnish with context %}

varnish:
  pkg.installed:
    - name: {{ varnish.package }}
  service.running:
    - name: {{ varnish.service }}
    - enable: True
    - reload: True
    - require:
      - pkg: varnish
