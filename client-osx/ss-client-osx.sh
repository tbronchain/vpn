#!/bin/bash

echo "please input server ip"
read -r IP

echo "please input password"
read -r PW

# install brew
ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"

# install ss
brew install shadowsocks-libev

cat > /usr/local/etc/shadowsocks-libev.json <<EOF
{
        "server_port": 443,
        "local_port": 8080,
        "server": "$IP",
        "timeout": 300,
        "password": "$PW",
        "method": "aes-256-cfb"
}
EOF

mkdir -p /usr/local/opt/
cp SimpleShadowSocks.py /usr/local/opt/SimpleShadowSocks.py

mkdir -p ~/Library/LaunchAgents/
cp net.almaritech.simpleshadowsocks ~/Library/LaunchAgents/net.almaritech.simpleshadowsocks

launchctl load ~/Library/LaunchAgents/net.almaritech.simpleshadowsocks
launchctl start net.almaritech.simpleshadowsocks

echo "Done."
