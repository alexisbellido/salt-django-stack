=========
zinibu
=========

Salt formulas to setup Django with Gunicorn, Nginx, Redis and Varnish. This is the stack used by zinibu.

.. note::


    See the full `Salt Formulas installation and usage instructions
    <http://docs.saltstack.com/en/latest/topics/development/conventions/formulas.html>`_.

Overview
========

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

Move pillar.example to your pillar directory (this could be /srv/pillar/zinibu.sls) and set the configuration data for your application.

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
