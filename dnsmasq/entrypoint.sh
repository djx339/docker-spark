#!/bin/sh

# linster configurations.
LINSTER=${LINSTER:-/usr/bin/linster}
LINSTER_CONF=${LINSTER_CONF:-/etc/linster.conf}
LINSTER_PORT=${LINSTER_PORT:-1234}
PASSWORD=${PASSWORD:-helloworld}

HOSTSDIR=${HOSTSDIR:-/tmp/hosts}
mkdir -p $HOSTSDIR

SERVER_IP=$(ifconfig | grep -A1 eth0 | grep inet | awk '{print $2}' | cut -d":" -f2)
SERVER_NAME=${SERVER_NAME:-$HOSTNAME}

configure_dnsmasq() {
    local conf=/etc/dnsmasq.conf
    sed -i 's#{{HOSTSDIR}}#'"$HOSTSDIR"'#g' $conf
}

start_dnsmasq() {
    if [ "$1" == "-d" ]; then
        dnsmasq
    else
        exec dnsmasq -k
    fi
}

configure_linster() {
    sed -i 's#{{LINSTER_CONF}}#'"$LINSTER_CONF"'#g' $LINSTER

    sed -i 's#{{PASSWORD}}#'"$PASSWORD"'#g' $LINSTER_CONF
    sed -i 's#{{HOSTSDIR}}#'"$HOSTSDIR"'#g' $LINSTER_CONF
}

start_linster() {
    nohup nc -lkp $LINSTER_PORT -e $LINSTER &
}

initial_dns_records() {
    echo $SERVER_IP  $SERVER_NAME > $HOSTSDIR/$SERVER_NAME
}

configure_dnsmasq
configure_linster
initial_dns_records

case $1 in
    start)
        start_linster
        start_dnsmasq
        ;;
    *)
        exec "$@"
esac
