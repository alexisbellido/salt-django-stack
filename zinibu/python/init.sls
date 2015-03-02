/tmp/file-python2:
  file.managed:
    - source: salt://zinibu/python/files/temp-file

{{ salt['pillar.get']('python:testfilename', '/tmp/some-default-name') }}:
  file.managed:
    - source: salt://zinibu/python/files/temp-file

