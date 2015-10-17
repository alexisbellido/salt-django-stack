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

Include zinibu in your top.sls (which may be in /srv/salt/top.sls) to setup a standard webhead (this is zinibu/init.sls including state files to setup the web stack). To setup other servers include individual state files, like this:

base:
  'webhead*':
    - zinibu
  'cache':
    - zinibu.varnish
    - zinibu.varnish.conf
  'load-balancer':
    - zinibu.keepalived
    - zinibu.keepalived.conf
    - zinibu.haproxy
    - zinibu.haproxy.conf
  'redis-server':
    - zinibu.redis
  'database':
    - zinibu.postgresql

Keepalived should run before haproxy to bind ip addresses.

If some states are running in the same server they all should be under the same minion id in top.sls.

See http://docs.saltstack.com/en/latest/ref/states/top.html

To make testing easier, run commands locally with salt-call, this way you don't need a target and can use just one server. This means a command like:
sudo salt '*' test.ping

becomes:
sudo salt-call test.ping

To run all states use:
sudo salt '*' state.highstate


Pillar setup
================

Create the pillar directory and point /etc/salt/master to it:

pillar_roots:
  base:
    - /srv/pillar

Copy the files from zinibu/pillar_data to /srv/pillar and now you can use the pillar data for your configuration. As you make changes to the pillar files in /srv/pillar, copy the changes to pillar_data the repository. Avoid keeping credentials and any other private data in the repository.

The goal is to keep separate pillar SLS files for each state.

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

salt 'minion_id' state.sls zinibu.python pillar='{"zinibu_basic": {"project": {"name": "zinibu_stage"}}}'

A virtual environment can be manually activated like this on each minion:
source /home/vagrant/pyvenvs/zinibu_dev/bin/activate

``zinibu.python.rmenv``
-----------------------

Remove a virtual environment. Note how pillar data can be passed at the command line to override pyvenv_name.

Note the pyvenvs_dir key refers to the part of the path after /home/user, for example, in /home/user/some_dir, pyvenvs would be "some_dir".

salt 'minion_id' state.sls zinibu.python.rmenv pillar='{"zinibu_basic": {"app_user": "vagrant", "app_group": "vagrant", "project": {"name": "zinibu_dev", "pyvenvs_dir": "pyvenvs"}} }'

To pass a list, use something like:

salt '*' state.highstate pillar='["cheese", "milk", "bread"]'

``zinibu.python.python_test``
-----------------------

sudo salt-call state.sls zinibu.python.python_test

``zinibu.django``
----------------

zinibu.python installed the Python packages and zinibu.django will install a Django project and related applications. Logged in as the user who owns the project (app_user in zinibu_basic pillar) you can activate the Python environment like this:

$ source ~/pyvenvs/zinibu_dev/bin/activate

then change to the directory of the project, e.g. /home/user/zinibu_dev, and manage it with django-admin.py:
$ django-admin.py help --pythonpath=`pwd` --settings=zinibu_dev.settings

Instead of django-admin.py, you can also use manage.py, a thin wrapper, from the directory of the project and may require to call it with python:
$ python manage.py  help

or without:
$ ./manage.py  help

Some test commands
====================

sudo salt-key -L
sudo salt-key -a django*
sudo salt '*' test.ping
sudo salt '*' pillar.items
sudo salt '*' state.highstate
sudo salt django5 pillar.items
sudo salt '*' pillar.items
sudo salt django5 state.sls zinibu.python
history | grep "sudo salt"

sudo salt-call test.ping
sudo salt-call state.sls zinibu.python
