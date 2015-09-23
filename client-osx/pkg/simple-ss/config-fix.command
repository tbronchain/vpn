#!/bin/bash

cat > /usr/local/etc/shadowsocks-libev.json <<EOF
{
        "server_port": 443,
        "local_port": 8080,
        "server": "",
        "timeout": 300,
        "password": "",
        "method": "aes-256-cfb"
}
EOF
chown ${USER} /usr/local/etc/shadowsocks-libev.json
