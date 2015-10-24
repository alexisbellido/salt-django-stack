# Because on Ubuntu we don't have a current HAProxy in the usual repo, we add a PPA

# Use this if configuration files need to be reset.
# sudo apt-get -o Dpkg::Options::="--force-confmiss" install --reinstall haproxy

{% if salt['grains.get']('osfullname') == 'Ubuntu' %}
haproxy_ppa_repo:
  pkgrepo.managed:
    - ppa: vbernat/haproxy-1.5
    - refresh_db: True
    - require_in:
      - pkg: haproxy.install
#    - watch_in:
#      - pkg: haproxy.install
{% endif %}

haproxy.install:
  pkg.installed:
    - name: haproxy
