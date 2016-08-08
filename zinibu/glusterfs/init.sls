{% set zinibu_basic = salt['pillar.get']('zinibu_basic', {}) -%}

glusterfs-server:
  pkg.installed

/var/exports/static-{{ zinibu_basic.project.name }}:
  file.directory:
    - user: {{ zinibu_basic.root_user }}
    - group: {{ zinibu_basic.root_user }}
    - mode: 755
    - makedirs: True

/var/exports/media-{{ zinibu_basic.project.name }}:
  file.directory:
    - user: {{ zinibu_basic.root_user }}
    - group: {{ zinibu_basic.root_user }}
    - mode: 755
    - makedirs: True
