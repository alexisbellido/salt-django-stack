{% from "zinibu/map.jinja" import nginx with context %}

nginx:
  pkg.installed:
    - name: {{ nginx.package }}
  service.running:
    - name: {{ nginx.service }}
