{% from "zinibu/map.jinja" import zinibu_basic with context %}

webupd8team-java-ppa-repo:
  pkgrepo.managed:
    - ppa: webupd8team/java
    - refresh_db: True
    - require_in:
      - pkg: java-install
    - watch_in:
      - pkg: java-install

java-silent-mode:
  cmd.run:
    - runas: {{ zinibu_basic.root_user }}
    - name: echo "oracle-java8-installer shared/accepted-oracle-license-v1-1 select true" | debconf-set-selections
    - shell: /bin/bash
    - require_in:
      - pkg: java-install

java-install:
  pkg.installed:
    - name: oracle-java8-installer
