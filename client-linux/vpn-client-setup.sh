#!/bin/bash

# toset variables
VPNHOSTNAME="hostname"
USERNAME="username"
PASSWORD='password'

# variables
SERVICE="vpn"
SERVER_IP="192.168.20.1"

echo "Configuring auto VPN ..."

# install dependencies
apt-get -y install pptp-linux

# set conf
cat > /etc/ppp/peers/$SERVICE <<EOF
pty "pptp $VPNHOSTNAME --nolaunchpppd --debug"
name $USERNAME
password $PASSWORD
remotename PPTP
require-mppe-128
require-mschap-v2
refuse-eap
refuse-pap
refuse-chap
refuse-mschap
noauth
debug
persist
maxfail 100
nodefaultroute
usepeerdns
EOF

# set service
cp vpn.daemon.sh /etc/init.d/vpn
chmod +x /etc/init.d/vpn
update-rc.d vpn defaults

# set cron
CRON=$(crontab -l | grep $SERVER_IP | wc -l)
if [ $CRON -eq 0 ]; then
    cat > /etc/crontab.d/vpn <<EOF
SHELL=/bin/bash
PATH=/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin
* * * * * ping -q -c5 $SERVER_IP || /usr/sbin/service vpn restart
EOF
fi

# restart crontab
service crontab reload

echo "Configuration done."
