include:
  - zinibu.basic
  - zinibu.python
  - zinibu.django.conf
  - zinibu.django
  - zinibu.nginx
{% if salt['grains.get']('osfullname') == 'Ubuntu' and salt['grains.get']('lsb_distrib_release') == '14.10' %}
  - zinibu.upstart
{% else %}
  - zinibu.systemd
{% endif %}
  - zinibu.postgresql.client
