{% set zinibu_basic = salt['pillar.get']('zinibu_basic', {}) -%}
export LINODE_API_KEY='{{ zinibu_basic.linode_api_key }}'
IP='{{ zinibu_basic.project.haproxy_frontend_public_ip }}'
IP_ADDRESS_ID='{{ zinibu_basic.project.haproxy_frontend_ip_address_id }}'
TO_LINODE_ID='{{ zinibu_basic.project.haproxy_frontend_to_linode_id }}'

#python /usr/local/bin/assign-ip $IP $ID && break
#python /usr/local/bin/linode-swap-ip linode.ip.swap 311989 1486208
# TODO linode-swap has to find the IPAddressID and toLinodeID based on $IP
# TODO or better yet, just call linode.ip.list once and put that in pillar, TO_LINODE_ID is the other one
python /usr/local/bin/linode-swap-ip linode.ip.swap $IP 311989 1486208
