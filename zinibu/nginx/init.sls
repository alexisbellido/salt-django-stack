{% from "zinibu/map.jinja" import nginx with context %}
{% from "zinibu/map.jinja" import zinibu_basic with context %}

nginx:
  pkg.installed:
    - name: {{ nginx.package }}
  service.running:
    - name: {{ nginx.service }}
    - watch:
      - file: /etc/nginx/sites-available/{{ zinibu_basic.project.name }}

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
        public_ip: 0.0.0.0
        user: {{ zinibu_basic.app_user }}
        project_name: {{ zinibu_basic.project.name }}
        haproxy_app_check_url: {{ zinibu_basic.project.haproxy_app_check_url }}
        haproxy_static_check_url: {{ zinibu_basic.project.haproxy_static_check_url }}
  {% for id, webhead in zinibu_basic.project.webheads.iteritems() %}
    {% if grains['id'] == id %}
    - context:
        public_ip: {{ webhead.public_ip }}
        private_ip: {{ webhead.private_ip }}
        nginx_port: {{ webhead.nginx_port }}
        gunicorn_port: {{ webhead.gunicorn_port }}
    {% endif %}
  {% endfor %}
    - require:
      - pkg: nginx
      - file: /etc/nginx/sites-enabled/{{ zinibu_basic.project.name }}
