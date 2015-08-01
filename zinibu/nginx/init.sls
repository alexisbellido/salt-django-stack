{% from "zinibu/map.jinja" import nginx with context %}
{% from "zinibu/map.jinja" import zinibu_basic with context %}

nginx:
  pkg.installed:
    - name: {{ nginx.package }}
  service.running:
    - name: {{ nginx.service }}

/etc/nginx/sites-enabled/default:
  file.absent

# I may use to check if a file exists
#{% if 0 == salt['cmd.retcode']('test -f /etc/nginx/sites-available/' + zinibu_basic.project.name, template='jinja') %}
# do something here
#{% endif %}

/etc/nginx/sites-enabled/{{ zinibu_basic.project.name }}:
  file.symlink:
    - target: /etc/nginx/sites-available/{{ zinibu_basic.project.name }}
    - mode: 644
    - user: root
    - group: root
    - require:
      - pkg: nginx

# make the symlink a requirement to make sure it's created
/etc/nginx/sites-available/{{ zinibu_basic.project.name }}:
  file.managed:
    - source: salt://zinibu/nginx/files/nginx-server-block
    - mode: 644
    - user: root
    - group: root
    - template: jinja
    - defaults:
        name_var: "Default Name"
        public_ip: {{ grains['ip_interfaces']['eth1'][0] }}
        user: {{ zinibu_basic.app_user }}
        project_name: {{ zinibu_basic.project.name }}
    {% if grains['os'] == 'Ubuntu' %}
    - context:
        name_var: "Context-based Name"
    {% endif %}
    - require:
      - pkg: nginx
      - file: /etc/nginx/sites-enabled/{{ zinibu_basic.project.name }}
