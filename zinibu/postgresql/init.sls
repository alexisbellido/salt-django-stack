{% from "zinibu/map.jinja" import postgres with context %}
{% from "zinibu/map.jinja" import zinibu_basic with context %}

install-postgresql-client:
  pkg.installed:
    - name: {{ postgres.pkg_client }}
    - refresh: {{ postgres.use_upstream_repo }}

install-postgresql:
  pkg.installed:
    - name: {{ postgres.pkg }}
    - refresh: {{ postgres.use_upstream_repo }}

pg_hba.conf:
  file.managed:
    - name: {{ postgres.conf_dir }}/pg_hba.conf
    - source: {{ postgres['pg_hba.conf'] }}
    - template: jinja
    - user: postgres
    - group: postgres
    - mode: 644
    - require:
      - pkg: {{ postgres.pkg }}
    - watch_in:
      - service: {{ postgres.service }}

{% if postgres.postgresconf %}
postgresql-conf:
  file.blockreplace:
    - name: {{ postgres.conf_dir }}/postgresql.conf
    - marker_start: "# Managed by SaltStack: listen_addresses: please do not edit"
    - marker_end: "# Managed by SaltStack: end of salt managed zone --"
    - content: |
        {{ postgres.postgresconf|indent(8) }}
    - show_changes: True
    - append_if_not_found: True
    - watch_in:
      - service: {{ postgres.service }}
{% endif %}

run-postgresql:
  service.running:
    - enable: true
    - name: {{ postgres.service }}
    - require:
      - pkg: {{ postgres.pkg }}
