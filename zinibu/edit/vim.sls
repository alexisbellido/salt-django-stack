vim:
  pkg.installed

/tmp/test:
  file.managed:
    - source: salt://edit/test
    - mode: 644
    - user: root
    - group: root

{% set owner = 'vagrant' %}
{% for test_file in ['file1', 'file2'] %}
/tmp/{{ test_file }}:
  file.managed:
    - source: salt://edit/{{ test_file }}
    - mode: 644
    - user: {{ owner }}
    - group: {{ owner }}
    - template: jinja
    - defaults:
        name_var: "Default Name"
        public_ip: {{ grains['ip_interfaces']['eth1'] }}
    {% if grains['os'] == 'Ubuntu' %}
    - context:
        name_var: "Context-based Name"
    {% endif %}
{% endfor %}

/tmp/test_dir:
  file.recurse:
    - source: salt://edit/test_dir
    - user: root
    - group: root
    - dir_mode: 755
    - file_mode: 644
