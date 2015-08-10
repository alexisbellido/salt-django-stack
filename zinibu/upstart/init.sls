{% from "zinibu/map.jinja" import zinibu_basic with context %}

{% set run_project_script = '/home/' + zinibu_basic.app_user + '/run-' + zinibu_basic.project.name + '.sh' %}
{% set upstart_job_file = '/etc/init/' + zinibu_basic.project.name + '.conf' %}

upstart_job_running:
  service.running:
    - name: {{ zinibu_basic.project.name }}
    - watch:
      - file: {{ upstart_job_file }}

{{ upstart_job_file }}:
  file.managed:
    - source: salt://zinibu/upstart/files/django-gunicorn.conf
    - mode: 644
    - user: root
    - group: root
    - template: jinja
    - defaults:
        project_name: {{ zinibu_basic.project.name }}
        run_project_script: {{ run_project_script }}
