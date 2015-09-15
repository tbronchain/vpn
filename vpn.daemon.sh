#!/bin/sh

# to set variables
ADDRESS="server_address"

# variables
SUBNET="192.168.20.0"
NETMASK="255.255.255.0"
IFACE="ppp0"
VPN="vpn"
PID_FILE="/tmp/vpn.pid"
# nslookup -q=TXT _spf.google.com 8.8.8.8
# nslookup -q=TXT _netblocks.google.com 8.8.8.8
ROUTES="$SUBNET/$NETMASK 64.18.0.0/255.255.240.0 64.233.160.0/255.255.224.0 66.102.0.0/255.255.240.0 66.249.80.0/255.255.240.0 72.14.192.0/255.255.192.0 74.125.0.0/255.255.0.0 108.177.8.0/255.255.248.0 173.194.0.0/255.255.0.0 207.126.144.0/255.255.240.0 209.85.128.0/255.255.128.0 216.58.192.0/255.255.224.0 216.239.32.0/255.255.224.0"

touch $PID_FILE
OLD_PID=$(cat $PID_FILE)
if [ "$OLD_PID" != "" ]; then
    STATUS=$(ps ax | sed -e 's/^[[:space:]]*//' | cut -d " " -f 1 | grep "^$OLD_PID\$" | wc -l)
    if [ $STATUS -eq 1 ]; then
        echo stop
        exit 0
    fi
fi
echo $$ > $PID_FILE

case "$1" in
  start)
    pon $VPN
    RES=$?
    if [ $RES -eq 0 ]; then
	RESULT=1
        for ROUTE in $ROUTES; do
            CUR_SUBNET=$(echo $ROUTE | cut -d "/" -f 1)
            CUR_NETMASK=$(echo $ROUTE | cut -d "/" -f 2)
	    while [ $RESULT -ne 0 ]; do
	        route add -net $CUR_SUBNET netmask $CUR_NETMASK dev $IFACE
	        RESULT=$?
                if [ $RESULT -ne 0 ]; then
	            sleep 5
                fi
	    done
        done
	echo "PPTP Started."
    else
	echo "PPTP Start failed."
    fi
    rm -f $PID_FILE
    exit $RES
    ;;
  restart)
    poff $VPN
    sleep 1
    for id in `ps ax | grep -e "pptp $ADDRESS" -e "pppd call $VPN" | sed -e 's/^[[:space:]]*//' | cut -d " " -f 1`; do
	kill -9 $id
    done
    sleep 1
    pon $VPN
    RES=$?
    if [ $RES -eq 0 ]; then
	RESULT=1
        for ROUTE in $ROUTES; do
            CUR_SUBNET=$(echo $ROUTE | cut -d "/" -f 1)
            CUR_NETMASK=$(echo $ROUTE | cut -d "/" -f 2)
	    while [ $RESULT -ne 0 ] && [ $RESULT -ne 7 ]; do
	        route add -net $CUR_SUBNET netmask $CUR_NETMASK dev $IFACE
                RESULT=$?
                if [ $RESULT -ne 0 ]; then
	            sleep 5
                fi
	    done
        done
	echo "PPTP Restarted."
    else
	echo "PPTP Restart failed."
    fi
    rm -f $PID_FILE
    exit $RES
    ;;
  stop)
    poff $VPN
    sleep 1
    for id in `ps ax | grep -e "pptp $ADDRESS" -e "pppd call $VPN" | sed -e 's/^[[:space:]]*//' | cut -d " " -f 1`; do
	kill -9 $id
    done
    rm -f $PID_FILE
    echo "PPTP Stopped."
    ;;
  *)
    echo "Usage: /etc/init.d/vpn {start|restart|stop}"
    exit 1
    ;;
esac

exit 0
