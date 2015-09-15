#!/bin/bash

apt-get update
apt-get install python-pip

pip install shadowsocks

echo "please input password"
read -r PW

cat >> /etc/shadowsocks.json <<EOF
{
        "server":"0.0.0.0",
        "server_port":443,
        "local_address":"127.0.0.1",
        "local_port":8080,
        "password":"$PW",
        "timeout":300,
        "method":"aes-256-cfb",
        "fast_open":false,
        "workers":1
}
EOF

cat >> /etc/security/limits.conf <<EOF
* soft nofile 51200
* hard nofile 51200
EOF

ulimit -n 51200

cat >> /etc/sysctl.conf <<EOF
fs.file-max = 51200

net.core.rmem_max = 67108864
net.core.wmem_max = 67108864
net.core.netdev_max_backlog = 250000
net.core.somaxconn = 4096

net.ipv4.tcp_syncookies = 1
net.ipv4.tcp_tw_reuse = 1
net.ipv4.tcp_tw_recycle = 0
net.ipv4.tcp_fin_timeout = 30
net.ipv4.tcp_keepalive_time = 1200
net.ipv4.ip_local_port_range = 10000 65000
net.ipv4.tcp_max_syn_backlog = 8192
net.ipv4.tcp_max_tw_buckets = 5000
net.ipv4.tcp_fastopen = 3
net.ipv4.tcp_mem = 25600 51200 102400
net.ipv4.tcp_rmem = 4096 87380 67108864
net.ipv4.tcp_wmem = 4096 65536 67108864
net.ipv4.tcp_mtu_probing = 1
net.ipv4.tcp_congestion_control = hybla
EOF

sysctl -p

echo "Install supervisord"

pip install supervisor
echo_supervisord_conf > /etc/supervisord.conf

cat >> /etc/supervisor/conf.d/shadowsocks.conf <<EOF
[program:shadowsocks]
command=ssserver -c /etc/shadowsocks.json
autorestart=true
user=root
EOF

echo "ulimit -n 51200" >> /etc/default/supervisor

service supervisor start
supervisorctl reload

sleep 5

supervisorctl tail -100 shadowsocks stderr

echo "Done."
