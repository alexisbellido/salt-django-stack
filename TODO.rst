TODO

====

- elasticsearch install for different server, see haproxy.init.sls for adding repo and check these commands and URLs

sudo add-apt-repository ppa:webupd8team/java -y
sudo apt-get update
echo "oracle-java8-installer shared/accepted-oracle-license-v1-1 select true" | sudo debconf-set-selections
sudo vim /etc/hosts
udo apt-get install oracle-java8-installer -y

https://www.digitalocean.com/community/tutorials/how-to-install-and-configure-elasticsearch-on-ubuntu-16-04
https://www.digitalocean.com/community/tutorials/how-to-install-java-with-apt-get-on-ubuntu-16-04
http://askubuntu.com/questions/190582/installing-java-automatically-with-silent-option

wget https://download.elastic.co/elasticsearch/release/org/elasticsearch/distribution/deb/elasticsearch/2.3.5/elasticsearch-2.3.5.deb
sudo dpkg -i elasticsearch-2.3.5.deb 
sudo systemctl start elasticsearch.service
by default elasticsearch lists on localhost:9200
curl 127.0.0.1:9200

I can just insert at the end of /etc/elasticsearch/elasticsearch.yml
network.host: 192.168.33.19
sudo systemctl stop elasticsearch.service
sudo systemctl start elasticsearch.service
curl 192.168.33.19:9200


====


- salt state to setup postgresql for running django tests locally, something like this needs to be added to pg_hba.conf:
host   test_db1      user1   192.168.1.203/32     md5
host   postgres      user1   192.168.1.203/32     md5

where the user1 and db1 parts are the ones setup from pillar

- move postgres-related lines from zinibu.python.init to postgres specific states, add include to zinibu.python.init.
- don't worry about high availability for redis and postgresql yet
- most destructive operations (umount, removing directories, uninstalls, etc) should be handled manually to avoid errors
- modifying settings.py in django to connect to db and dbsync/migrate as needed, see django formula for ideas
- logrotate to keep all logs under control (syslog-ng for something else?)


===
- I may continue without the keepalived part. If I shut down the keepalived service, it works. The problem is that backup is not becoming master as it should. The check script is working and priority is changing but still master remains master.

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

