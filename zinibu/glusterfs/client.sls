{% from "zinibu/map.jinja" import zinibu_basic with context %}
{% set project_static_dir = '/home/' + zinibu_basic.app_user + '/' + zinibu_basic.project.name + '/shared-static' %}

glusterfs-client:
  pkg.installed

{{ project_static_dir }}:
  file.directory:
    - user: {{ zinibu_basic.app_user }}
    - group: {{ zinibu_basic.app_group }}
    - mode: 755
    - makedirs: True

# only need to do this for one server to get to the volume, use loop.index
#/etc/fstab
#192.168.33.15:static-zinibu_dev /home/vagrant/zinibu_dev/shared-static glusterfs defaults,_netdev 0 0
# sudo mount /home/vagrant/zinibu_dev/shared-static

{%- if 'webheads' in zinibu_basic.project %}
  {%- for id, webhead in zinibu_basic.project.webheads.iteritems() %}
    {% if loop.index == 1 %}
test-webhead-{{ id }}:
  cmd.run:
    - user: {{ zinibu_basic.root_user }}
    - name: echo "WEBHEAD TEST {{ id }} {{ webhead.private_ip }}"
    {%- endif %}
  {%- endfor %}
{%- endif %}
