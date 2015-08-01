{% from "zinibu/map.jinja" import nginx with context %}
{% from "zinibu/map.jinja" import zinibu_basic with context %}

nginx:
  pkg.installed:
    - name: {{ nginx.package }}
  service.running:
    - name: {{ nginx.service }}

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
    {% if grains['os'] == 'Ubuntu' %}
    - context:
        name_var: "Context-based Name"
    {% endif %}
    - require:
      - pkg: nginx

# create new virtual host, first create configuration in sites-available and then symlink it to sites-enabled
# sudo ln -s /etc/nginx/sites-available/django-project /etc/nginx/sites-enabled/django-project

# the file above should be based on a template managed by this state and modified with jinja, see how to reuse project name (zinibu_dev in examples)

# remove default nginx virtual host
#sudo rm /etc/nginx/sites-enabled/default 

