{% from "zinibu/map.jinja" import zinibu_basic with context %}

{% set run_project_script = '/home/' + zinibu_basic.app_user + '/run-' + zinibu_basic.project.name + '.sh' %}

{% if zinibu_basic.systemd %}
{% set systemd_unit_file = '/etc/systemd/system/' + zinibu_basic.project.name + '.service' %}

{{ systemd_unit_file }}:
  file.managed:
    - source: salt://zinibu/service/files/django-gunicorn.service
    - mode: 644
    - user: root
    - group: root
    - template: jinja
    - defaults:
        project_name: {{ zinibu_basic.project.name }}
        run_project_script: {{ run_project_script }}

service.systemctl_reload service-{{ zinibu_basic.project.name }}:
  module.run:
    - name: service.systemctl_reload
    - watch:
      - file: {{ systemd_unit_file }}

service.enable service-{{ zinibu_basic.project.name }}:
  module.run:
    - name: service.enable
    - m_name: {{ zinibu_basic.project.name }}
    - require:
      - module: service.systemctl_reload

service.restart service-{{ zinibu_basic.project.name }}:
  module.run:
    - name: service.restart
    - m_name: {{ zinibu_basic.project.name }}
    - require:
      - module: service.systemctl_reload service-{{ zinibu_basic.project.name }}
      - module: service.enable service-{{ zinibu_basic.project.name }}

{% else %}
{% set upstart_job_file = '/etc/init/' + zinibu_basic.project.name + '.conf' %}

upstart_job_running:
  service.running:
    - name: {{ zinibu_basic.project.name }}
    - watch:
      - file: {{ upstart_job_file }}

{{ upstart_job_file }}:
  file.managed:
    - source: salt://zinibu/service/files/django-gunicorn.conf
    - mode: 644
    - user: root
    - group: root
    - template: jinja
    - defaults:
        project_name: {{ zinibu_basic.project.name }}
        run_project_script: {{ run_project_script }}
{% endif %}

nginx-stopped:
  service.dead:
    - name: nginx

nginx-running:
  service.running:
    - name: nginx
    - require:
      - service: nginx-stopped
{% if zinibu_basic.systemd %}
{% else %}
      - service: upstart_job_running
      - file: {{ upstart_job_file }}
{% endif %}
