{% from "zinibu/map.jinja" import postgres with context %}
{% from "zinibu/map.jinja" import zinibu_basic with context %}

install-postgresql-client:
  pkg.installed:
    - name: {{ postgres.pkg_client }}
    - refresh: {{ postgres.use_upstream_repo }}
