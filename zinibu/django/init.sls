# need something from map.jinja?
#{% from "zinibu/map.jinja" import django with context %}
#
# django
#
#- Create Django project, two ways:
#
#  - Creating directory and passing it as target to startproject:
#
#    mkdir /home/vagrant/mysite5; django-admin startproject mysite5 /home/vagrant/mysite5
#    django-admin runserver --pythonpath=/home/vagrant/mysite5 --settings=mysite5.settings 192.168.50.11:8000
#
#  - Changing to the project's parent directory first:
#
#    cd /home/vagrant/
#    django-admin startproject mysite6
#    django-admin runserver --pythonpath=/home/vagrant/mysite6 --settings=mysite6.settings 192.168.50.11:8000
#
#
