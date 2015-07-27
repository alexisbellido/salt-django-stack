{% from "zinibu/map.jinja" import nginx with context %}

nginx:
  pkg.installed:
    - name: {{ nginx.package }}
  service.running:
    - name: {{ nginx.service }}

# create new virtual host, first create configuration in sites-available and then symlink it to sites-enabled
# sudo ln -s /etc/nginx/sites-available/django-project /etc/nginx/sites-enabled/django-project

# the file above should be based on a template managed by this state and modified with jinja, see how to reuse project name (zinibu_dev in examples)

# remove default nginx virtual host
#sudo rm /etc/nginx/sites-enabled/default 

