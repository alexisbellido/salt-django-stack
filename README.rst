=========
zinibu
=========

Salt formulas to setup Django with Gunicorn, Nginx, Redis and Varnish. This is the stack used by zinibu.

.. note::


    See the full `Salt Formulas installation and usage instructions
    <http://docs.saltstack.com/en/latest/topics/development/conventions/formulas.html>`_.

Overview
========

Add formulas to /etc/salt/master like this:

file_roots:
  base:
    - /srv/salt
    - /home/user/salt-django-stack

The first directory, /srv/salt, is the default used by Salt on Ubuntu.

Include zinibu in your top.sls (which may be in /srv/salt/top.sls) to setup a standard webhead (Nginx, Gunicorn, and Django). To setup other servers include individual state files, like this:

base:
  'webhead':
    - zinibu
  'load-balancer':
    - zinibu.varnish
  'redis-server':
    - zinibu.redis
  'database':
    - zinibu.postgresql

Pillar setup
================

Create a directory for pillar and point /etc/salt/master to it:

pillar_roots:
  base:
    - /srv/pillar

Create /srv/pillar/top.sls, for example:

base:
  '*':
    - zinibu

Move pillar.example from the root of this repository to the pillar directory. For the top.sls above pillar.example should be moved /srv/pillar/zinibu.sls

Now you can use the pillar data for your configuration.

Testing
================

Run some state on some host for testing, for example:


sudo salt hostname state.sls zinibu.python


Available states
================

.. contents::
    :local:

``zinibu``
---------

Installs the needed packages and services for a Django webhead.

``zinibu.varnish``
----------------

Setups Varnish to load balance and cache the webheads.

``zinibu.python``
----------------

Installs the required Python software and creates a virtual environment.

salt 'minion_id' state.sls zinibu.python

The default name for the virtual environment is provided by pillar as pyvenv_name but
can be overriden like this:

salt 'minion_id' state.sls zinibu.python pillar='{"python": {"pyvenv_name": "zinibu_stage"}}'

A virtual environment can be manually activated like this on each minion:
source /home/vagrant/pyvenvs/zinibu_dev/bin/activate

``zinibu.python.rmenv``
-----------------------

Remove a virtual environment. Note how pillar data can be passed at the command line to override pyvenv_name.

salt 'minion_id' state.sls zinibu.python.rmenv pillar='{"python": {"pyvenv_name": "zinibu_dev"}}'
