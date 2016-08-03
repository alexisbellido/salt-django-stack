TODO

- scenarios to test with pillar data from staging/zinibu_basic.sls:
1. only staging1, no glusterfs_nodes
2. only staging1, one glusterfs_nodes
3. staging1 and staging2 (all of them webheads, just staging1 runs haproxy), two glusterfs_nodes
4. staging1, staging2, staging3, staging4 (all of them webheads, just staging1 runs haproxy), two glusterfs_nodes
5. staging1, staging2, staging3, staging4 (all of them webheads, just staging1 runs haproxy), four glusterfs_nodes

- check env in /srv/pillar/staging/zinibu_django.sls to try with correct local domain
- try the whole thing from the beginning new virtual box
- how expensive is to test all of this running with digitalocean? try for a couple of days and let's see

- how to extend existing gluster peer nodes and volume as an option when starting a new webhead or as a separate task
- keep an option to avoid extending glusterfs and use the existing volume when adding webhead
- make sure haproxy, varnish, nginx and gunicorn are correctly updated when a new webhead is added
- try running with just one webhead, which means no gluster should be set
- keep staging and production separate; each of them should have its own salt master to avoid potential issues on production when running salt commands from staging. Adapt top.sls and pillar files accordingly.

- new tests starting with these configurations:
1. staging1
- revisit pushing new code and deploying it at this point, include something in static and media to see how gluster will work
2. staging1, staging2
3. adding staging3 and staging4 to running staging1 and staging2
4. try all of the above on digitalocean


- create new settings files as collectatic is not finding python module?

- run
sudo salt '*' state.highstate | tee /tmp/test

- for some big changes, I should be able to launch and terminate a staging setup mimicking production on DO

- continue testing pillar per environmetn with:
sudo salt '*' state.sls zinibu.python.test_env

- complete zinibu.deploy to work with apps to update
- follow https://repo.saltstack.com/#ubuntu to update saltstack (salt-master and salt-minion) to salt-master 2016.3.1 (Boron) 
- start from scratch with latest salt versions and see that force_clone for git.latest in zinibu.django
- zinibu.deploy should be able to tell which branch to git pull for the project and which apps and branch for each app should be used. We can assume master is the default in most cases but see how git.latest work with branches

- django skeleton app doing common Django stuff to use as inspiration for specific apps
- investigate git hooks (standard and managed by github) for some deploy operations, see Jenkins too for testing but only for the dev box (jenkins and continuous integration)

- salt state to setup postgresql for running django tests locally, something like this needs to be added to pg_hba.conf:
host   test_db1      user1   192.168.1.203/32     md5
host   postgres      user1   192.168.1.203/32     md5

where the user1 and db1 parts are the ones setup from pillar

- edit scripts/fabric.py to run salt commands, use for inspiration: https://github.com/alexisbellido/The-Django-gunicorn-fabfile-project/blob/master/fabfile.py, this should accept parameters
- install redis and change settings to use it
- move postgres-related lines from zinibu.python.init to postgres specific states, add include to zinibu.python.init.

- don't worry about high availability for redis and postgresql yet
- most destructive operations (umount, removing directories, uninstalls, etc) should be handled manually to avoid errors
- modifying settings.py in django to connect to db and dbsync/migrate as needed, see django formula for ideas

- logrotate to keep all logs under control (syslog-ng for something else?)

- I want to run the whole thing with:
sudo salt '*' state.highstate


- upgrade to varnish 4?

- I may continue without the keepalived shit. If I shutdown the keepalived service, it works. The problem is that backup is not becoming master as it shoud. The check script is working and priority is changing but still master remains master.

- Check about multicast, unicast, firewall and communicating between hosts with keepalived

http://serverfault.com/questions/512153/both-servers-running-keepalived-become-master-and-have-a-same-virtual-ip
http://www.cyberciti.biz/faq/linux-unix-verify-keepalived-working-or-not/

ping vrrp.mcast.net
iptables -L
sudo iptables -L
sudo tcpdump -vvv -n -i eth0 host 224.0.0.18
sudo iptables -I INPUT -i eth0 -d 224.0.0.0/8 -j ACCEPT
sudo iptables -L
sudo iptables -A INPUT -p 112 -i eth0 -j ACCEPT
sudo iptables -L
sudo iptables -A OUTPUT -p 112 -o eth0 -j ACCEPT
sudo iptables -L
sudo tcpdump -vvv -n -i eth0 host 224.0.0.18
sudo tcpdump -v -i eth0 host 224.0.0.18
sudo service keepalived restart
sudo service haproxy status


- check connections
netstat -ctnup | grep "192.168.1.95"

===
Linode tests

10/26/15 After Linode test 2:
- fix settings to use correct user, db info and more from pillar, see zinibu_dev/settings.py:STATIC_ROOT = '/home/vagrant/zinibu_dev/static'

10/25/15 After Linode test 1 ($ 0.33):
- focus on 14.04 LTS, 15.04 has replaced upstart with systemd and I don't want to mess with that for now, eventually I'll update these salt formulas to make a Django project run with systemd
====

