# Because on Ubuntu we don't have a current keepalived with unicast support, we add a PPA

# Use this if configuration files need to be reset.
# sudo apt-get -o Dpkg::Options::="--force-confmiss" install --reinstall keepalived

{% if salt['grains.get']('osfullname') == 'Ubuntu' %}
keeepalived_ppa_repo:
  pkgrepo.managed:
    - ppa: keepalived/stable
    - require_in:
      - pkg: keepalived.install
    - watch_in:
      - pkg: keepalived.install
{% endif %}

keepalived.install:
  pkg.installed:
    - name: keepalived

