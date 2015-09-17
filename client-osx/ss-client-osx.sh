#!/bin/bash

echo "please input server ip"
read -r IP

echo "please input password"
read -r PW

# install brew
ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"

# install ss
brew install python
brew install shadowsocks-libev

# install rumps
sudo pip install pyobjc
sudo pip install rumps

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
cp homebrew.mxcl.shadowsocks-libev.plist ~/Library/LaunchAgents/homebrew.mxcl.shadowsocks-libev.plist
cp com.almaritech.simpleshadowsocks.plist ~/Library/LaunchAgents/com.almaritech.simpleshadowsocks.plist

launchctl load ${HOME}/Library/LaunchAgents/com.almaritech.simpleshadowsocks.plist
launchctl start com.almaritech.simpleshadowsocks.plist

echo "Done."
