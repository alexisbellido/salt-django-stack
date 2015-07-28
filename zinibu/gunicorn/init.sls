# need something from map.jinja?
#{% from "zinibu/map.jinja" import gunicorn with context %}

/tmp/file-gunicorn2:
  file.managed:
    - source: salt://zinibu/gunicorn/files/temp-file
