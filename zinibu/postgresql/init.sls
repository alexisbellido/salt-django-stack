{% from "zinibu/map.jinja" import postgres with context %}
{% from "zinibu/map.jinja" import zinibu_basic with context %}

postgresql-test:
  cmd.run:
    - name: echo 'Setting up Postgresql {{ postgres.pkg }} {{ postgres.use_upstream_repo }}'

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

run-postgresql:
  service.running:
    - enable: true
    - name: {{ postgres.service }}
    - require:
      - pkg: {{ postgres.pkg }}
