# upstart
# need something from map.jinja?
#{% from "zinibu/map.jinja" import upstart with context %}
#
# this first and required by upstart job configuration file below
/tmp/file-django-script:
  file.managed:
    - source: salt://zinibu/upstart/files/run-project.sh

# job configuration file should be copied to /etc/init/project_name.conf and configured correctly with jinja and pillar data
# then it should be started
/tmp/file-upstart:
  file.managed:
    - source: salt://zinibu/upstart/files/django-gunicorn.conf

