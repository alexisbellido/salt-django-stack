{% from "zinibu/map.jinja" import elasticsearch with context %}
{% from "zinibu/map.jinja" import zinibu_basic with context %}

include:
  - zinibu.java

elasticsearch_install:
  pkg.installed:
    - sources:
      - elasticsearch: {{ elasticsearch.source }}

{% if 'elasticsearch_servers' in zinibu_basic.project %}
  {%- for id, elasticsearch_server in zinibu_basic.project.elasticsearch_servers.iteritems() %}
    {%- if grains['id'] == id %}

elasticsearch_host_configuration_{{ id }}:
  file.append:
    - name: {{ elasticsearch.config }}
    - text: |
        # configured by SaltStack
        network.host: {{ elasticsearch_server.private_ip }}
        http.port: {{ elasticsearch_server.port }}
    - require:
      - pkg: elasticsearch_install

elasticsearch_running_{{ id }}:
  service.running:
    - name: {{ elasticsearch.service }}
    - require:
      - file: elasticsearch_host_configuration_{{ id }}
    - watch:
      - file: elasticsearch_host_configuration_{{ id }}

    {%- endif %}
  {%- endfor %}
{% endif %} # elasticsearch_servers loop
