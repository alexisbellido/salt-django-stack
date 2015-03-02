{% from "zinibu/map.jinja" import varnish with context %}

varnish:
  pkg.installed:
    - name: {{ varnish.package }}
