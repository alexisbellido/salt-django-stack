=========
zinibu
=========

This Salt formula will setup a stack of one or more servers to run a Django project with some high availability and scalability features. The stack includes:

* Gunicorn and Nginx webheads running * Django 1.9.x with Python 3.x and venv.
* Gunicorn process managed via Upstart.
* Varnish 3.x to cache static files and dynamic pages for non-logged in users.
* HAProxy 1.5x load balancing inspired by `Baptiste Assmann`_.
* HAProxy high availability support via Keepalived and floating IPs on Digital Ocean.
* Redis.
* PostgreSQL.
* GlusterFS cluster for managing and sharing a volume for Django's static directory. Replica support is automatic if the number of hosts used as GlusterFS nodes is a multiple of two.
* vim-gnome on the host used as a Salt master. Just because I love vim.

The states are designed to be run together but you could take what you need and reuse in your own formulas.

So far, I have tested with Ubuntu 14.04 and 14.10 on both Linode and Digital Ocean hosts.

.. note::


    See the full `Salt Formulas installation and usage instructions
    <http://docs.saltstack.com/en/latest/topics/development/conventions/formulas.html>`_.

Start Here
============

SSH to your server as root and make sure to create a user with sudo permissions and the same uid on all servers involved, this is specially important if you will used GlusterFS, one way to do it is with Ubuntu's adduser --uid, for example:

  ``$ adduser --uid 1003 exampleuser``

  ``$ usermod -a -G sudo exampleuser``

Now logout and ssh with this new user to continue.

Add public key to the repositories you will need. This is how to easily create your private and public keys locally without a prompt or passphrase:

  ``echo -e 'y\n' | ssh-keygen -f ~/.ssh/id_rsa -t rsa -N ''``

Your public key, which you should add to Github, should be in:

  ``cat ~/.ssh/id_rsa.pub`` 

Optionally, if you want avoid the prompt when cloning this repository from Github (which happens when running the quick install script), you can add the fingerprint like this:

  ``ssh-keyscan github.com >> ~/.ssh/known_hosts``

You can use sed to quickly make changes in zinibu_basic.sls:

  ``sed -i -e s/django5/django8/g -e s/95/98/g -e s/15/18/g /srv/pillar/zinibu_basic.sls``

Quick Install
===============

**Step 1**: Add your public key to Github and then run this from, ideally, your home directory (although the script should be smart enough to work from any directory):

  ``\curl -sSL https://raw.githubusercontent.com/alexisbellido/salt-django-stack/master/scripts/install-prerequisites-ubuntu.sh | sudo bash -s full|master|minion "Joe Doe" name@example.com``

You need three arguments:

The first one defines the type of installation: "full" to install both salt-master and salt-minion, "master" to install only salt-master, or "minion" to install only salt-minion.
The second and third arguments are used to setup git --global user.name and user.email.

An installation of type full or master will also copy basic top.sls to /srv/salt/top.sls and /srv/pillar/* and files and point to them from /etc/salt/master.

**Step 2**: Pay attention to the next steps displayed after the script finishes running and customize your settings before proceeding to run salt states.

You shouldn't worry about overwriting your settings if running the script more than once; files won't be touched if they already exist.

**Step 3**: Run all the states with:

  ``sudo scripts/install.sh``

Alternative Prerequisites Install
===================================

You can clone this project to any directory and then cd to it and run it with:

  ``sudo scripts/install-prerequisites-ubuntu.sh master|minion|full "Joe Doe" name@example.com``

The end result will be the same as using curl call from the quick install.

Overview
========

See the conf directory for sample top.sls and pillar configuration.

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

GlusterFS client is required by collectstatic in zinibu.django if glusterfs_nodes are defined in zinibu_basic.

GlusterFS is optional if you will use just one webhead, which is the case for most development situations. Don't include glusterfs_nodes in zinibu_basic and zinibu.django won't run operations related to GlusterFS.

This is another example, more complete, /etc/salt/top.sls, with the correct execution order:

  base:
    'django5':
      - zinibu.postgresql
      - zinibu.varnish
      - zinibu.varnish.conf
      - zinibu.haproxy
      - zinibu.haproxy.conf
    'django6':
      - zinibu.varnish
      - zinibu.varnish.conf
      - zinibu.haproxy
      - zinibu.haproxy.conf
    'django*':
      - zinibu

If some states are running in the same server they all should be under the same minion id in top.sls.

See http://docs.saltstack.com/en/latest/ref/states/top.html

To make testing easier, run commands locally with salt-call, this way you don't need a target and can use just one server. This means a command like:
  ``sudo salt '*' test.ping``

becomes:
  ``sudo salt-call test.ping``


Pillar parameters can be passed from the command line. This is done, for example, to override the Django settings module:
  ``sudo salt '*' state.sls zinibu.django pillar='{"zinibu_django_env": "staging"}'``


Minions Setup
================

Set minions' ids and the roles as appropiate:

  id: my_minion_id

  grains:
    roles:
      - first_glusterfs_node
      - glusterfs_node
      - varnish

The available roles are:

* first_glusterfs_node (this is the one that will setup the volume and should be set just for one minion)
* haproxy_master (used by Keepalived for HAProxy's high availability)
* haproxy_backup (used by Keepalived for HAProxy's high availability)
* glusterfs_node
* varnish
* webhead (which includes nginx and gunicorn)
* redis
* postgresql
* haproxy

A host may play more than one of these roles.

Restart salt-minion to activate changes:

  ``sudo service salt-minion restart``

HAProxy and high availability
=================================

frontend ft_web and www-https (if using SSL) use public IP or, if using Keepalived with Digital Ocean's floating IPs, an anchor IP.
frontend ft_web_static uses a private IP and it's used by Varnish servers to update their cache.

To enable SSL termination obtain an SSL certificate or create a self-signed one (see instructions below), we're using .pem for this example, and put it in a directory for each of your HAProxy servers, like /etc/haproxy/ssl, then add the following pillar data to zinibu_basic.sls:

  ``haproxy_ssl_cert: /etc/haproxy/ssl/haproxy.pem``

  
To create a self-signed SSL certificate
========================================

When asked for a fully qualified domain name (FQDN) you can enter subdomain.example.com or *.example.com

  ``$ mkdir /etc/haproxy/ssl``
  ``$ openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout /etc/haproxy/ssl/haproxy.key -out /etc/haproxy/ssl/haproxy.crt``
  ``$ cd /etc/haproxy/ssl/``
  ``$ cat haproxy.crt haproxy.key > haproxy.pem``


Create .pem to use with HAProxy from Comodo PositiveSSL
=========================================================

For this example we're creating a new file at /etc/haproxy/ssl/haproxy.pem using the key file generated when requesting the certificate and the bundle and crt files provided by Comodo.

  ``$ cd /etc/haproxy/ssl``
  ``$ rm haproxy.pem``
  ``$ cat zinibu.com.key >> haproxy.pem``
  ``$ cat zinibu_com.crt >> haproxy.pem``
  ``$ cat zinibu_com.ca-bundle >> haproxy.pem``

  
Keepalived and high availability
=================================

Currently, high availability for HAProxy with Keepalived only works with floating IPs as provided by `Digital Ocean`_, so you need to setup pillar data for zinibu_basic.do_token and anchor_ip for each haproxy_server to be used instead of zinibu_basic.project.haproxy_frontend_public_ip.

Get anchor with:
  ``curl 169.254.169.254/metadata/v1/interfaces/public/0/anchor_ipv4/address && echo``

You should setup the roles grain in one and only one minion as haproxy_master and another as haproxy_backup.

Also, the keepalived states should run before varnish and haproxy states to make sure ip addresses are bound. The states are zinibu.keepalived and zinibu.keepalived.conf, in that order.

Note that the priority value in keepalived.conf for the master and backup hosts has to be changed to 101 and 100 because the weight is 2 or the track script won't run.

In progress: See linode/conf/etc/network/interfaces for an example of how to configure an extra public IP and private IP for a Linode to use with IP swapping.


Pillar Setup
================

Create the pillar directory and point /etc/salt/master to it:

  pillar_roots:
    base:
      - /srv/pillar

Copy the files from zinibu/pillar_data to /srv/pillar and now you can use the pillar data for your configuration. As you make changes to the pillar files in /srv/pillar, copy the changes to pillar_data the repository. Avoid keeping credentials and any other private data in the repository.

The goal is to keep separate pillar SLS files for each state.

Make it All Run
=================

To run all states in the correct order, run from the salt master, this is what scripts/install.sh:

  ``sudo salt-run state.orchestrate zinibu.bootstrap``

  ``sudo salt '*' state.highstate``

  ``salt -G 'roles:varnish' service.restart varnish``

state.orchestrate is important to make sure the GlusterFS volumes are setup in the correct order.

Run remotely with Fabric
==========================

Install Fabric locally (via pip, just for Python 2.5-2.7) and change to the scripts directory to run commands against the master host like this:

  ``fab -H host salt_ping``

This will probably be the preferred method to deploy.



Troubleshooting
================

*HAProxy shows the cache servers not running*

It seems Varnish needs to be restarted manually at the end of the first state.highstate. You can target the appropiate hosts to do it with just one command:

   ``sudo salt 'hostname' service.restart varnish``

*TypeError encountered executing state.highstate: cannot concatenate 'str' and 'ConstructorError' objects. See debug log for more info.*

You have a duplicate selector in your top.sls. See https://github.com/saltstack/salt/issues/16753.


Testing
================

Run some state on some host for testing, for example:

  ``sudo salt 'hostname' state.sls zinibu.python``


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

  ``sudo salt-call state.sls zinibu.python.python_test``

``zinibu.django``
----------------

zinibu.python installed the Python packages and zinibu.django will install a Django project and related applications. 

To install Python packages in the webheads, including the latest version of Django, which needs to be set in /srv/pillar/zinibu_python.sls, run:

  ``sudo salt '*' state.sls zinibu.python``

Logged in as the user who owns the project (app_user in zinibu_basic pillar) you can activate the Python environment like this:

  ``$ source ~/pyvenvs/zinibu_dev/bin/activate``

then change to the directory of the project, e.g. /home/user/zinibu_dev, and manage it with django-admin.py:
  ``$ django-admin.py help --pythonpath=`pwd` --settings=zinibu_dev.settings``

Instead of django-admin.py, you can also use manage.py, a thin wrapper, from the directory of the project and may require to call it with python:
  ``$ python manage.py help``

or without:
  ``$ ./manage.py  help``

And easier way of setting the Python environment is using the bash script created by Salt, which we call the runner. For a project of name zinibu this would be:

    ``source ~/run-zinibu.sh setenv``

This will point DJANGO_SETTINGS_MODULE to the correct settings module so that you can just change directory to the project and run:

    ``django-admin help --pythonpath=$(pwd)``



Additional Resources
====================

* `Django Zinibu Skeleton`_ application.


Future Plans
============

* HAProxy high availability with Keepalived for Linode.
* Control Gunicorn with systemd, the new services manager by Ubuntu 15.04.
* Varnish 4 support. It's the default starting with Ubuntu 14.10.
* High availability Redis.
* High availability PostgreSQL.

Some test commands
====================

  ``sudo salt-key -L``

  ``sudo salt-key -a django*``

  ``sudo salt '*' test.ping``

  ``sudo salt '*' pillar.items``

  ``sudo salt '*' grains.item lsb_distrib_release``

  ``sudo salt '*' state.highstate``

  ``sudo salt django5 pillar.items``

  ``sudo salt '*' pillar.items``

  ``sudo salt django5 state.sls zinibu.python``

  ``history | grep "sudo salt"``

  ``sudo salt-call test.ping``

  ``sudo salt-call state.sls zinibu.python``

.. _`Digital Ocean`: https://www.digitalocean.com/community/tutorials/how-to-set-up-highly-available-haproxy-servers-with-keepalived-and-floating-ips-on-ubuntu-14-04
.. _`Baptiste Assmann`: http://blog.haproxy.com/2012/08/25/haproxy-varnish-and-the-single-hostname-website/
.. _`Django Zinibu Skeleton`: https://github.com/alexisbellido/django-zinibu-skeleton
