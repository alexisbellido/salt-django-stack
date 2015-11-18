{% set zinibu_basic = salt['pillar.get']('zinibu_basic', {}) -%}
export DO_TOKEN='{{ zinibu_basic.do_token }}'
IP='{{ zinibu_basic.project.haproxy_frontend_public_ip }}'
ID=$(curl -s http://169.254.169.254/metadata/v1/id)
HAS_FLOATING_IP=$(curl -s http://169.254.169.254/metadata/v1/floating_ip/ipv4/active)

if [ $HAS_FLOATING_IP = "false" ]; then
    n=0
    while [ $n -lt 10 ]
    do
        python /usr/local/bin/assign-ip $IP $ID && break
        n=$((n+1))
        sleep 3
    done
fi
