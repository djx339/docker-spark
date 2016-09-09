#!/bin/bash

set -ex

_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

DNS_WATCHER="$_dir/dns_watcher"
SLAVE_WATCHER="$_dir/slave_watcher"

MASTER_KEY=hadoop/master
SLAVE_KEY_DIR=hadoop/slaves
HOSTS_KEY_DIR=hosts

IP=$(ifconfig | grep -A1 eth0 | grep inet | awk '{print $2}' | cut -d":" -f2)

start_sshd() {
    /usr/sbin/sshd
}

get_master() {
    master="$(curl --noproxy $ETCD_HOST -sSL http://$ETCD_HOST:$ETCD_PORT/v2/keys/$MASTER_KEY | jq --raw-output '.node.value')"
    export MASTER=$master
}

hadoop_configure_common() {
    chmod go-rx /root/.ssh
    chmod go-rwx /root/.ssh/id_rsa
    chmod go-wx /root/.ssh/authorized_keys
    touch /root/.ssh/known_hosts
    
    sed -i 's#^export JAVA_HOME.*$#export JAVA_HOME="'"${JAVA_HOME}"'"#g' $HADOOP_CONF_DIR/hadoop-env.sh
    
    echo "    StrictHostKeyChecking no" >> /etc/ssh/ssh_config
    echo "    UserKnownHostsFile /dev/null" >> /etc/ssh/ssh_config
}

hadoop_configure_hdfs() {
    sed -i 's/{{master}}/'"${MASTER:-master}"'/g' $HADOOP_CONF_DIR/core-site.xml
}

hadoop_format_namenode() {
    $HADOOP_PREFIX/bin/hdfs namenode -format
}

hadoop_start_namenode() {
    $HADOOP_PREFIX/sbin/hadoop-daemon.sh --config $HADOOP_CONF_DIR --script hdfs start namenode
}

hadoop_start_datanode() {
    $HADOOP_PREFIX/sbin/hadoop-daemons.sh --config $HADOOP_CONF_DIR --script hdfs start datanode
}

hadoop_start_dfs() {
    $HADOOP_PREFIX/sbin/start-dfs.sh
}

hadoop_wait_for_master() {
    timeout=120
    until curl --noproxy $MASTER $MASTER:9000 > /dev/null 2>/dev/null; do
        echo "Hadoop master is unavailable - sleeping"
        sleep 1
        timeout="$(( $timeout - 1))"
        if [[ "$timeout" == "0" ]]; then
            echo "Hadoop master is unavailable - timeout !"
            exit 1
        fi
    done
}

wait_for_confserver() {
    timeout=120
    until curl --noproxy $ETCD_HOST $ETCD_HOST:$ETCD_PORT/version > /dev/null 2>/dev/null; do
        echo "confserver is unavailable - sleeping"
        sleep 1
        timeout="$(( $timeout - 1))"
        if [[ "$timeout" == "0" ]]; then
            echo "Confserver is unavailable - timeout !"
            exit 1
        fi
    done
}

register_dns() {
    if [[ -n "$ETCD_HOST" && -n "$ETCD_PORT" ]]; then
        curl --noproxy $ETCD_HOST -sSL http://$ETCD_HOST:$ETCD_PORT/v2/keys/$HOSTS_KEY_DIR/$HOSTNAME -XPUT -d value="$IP"
    fi
}

register_master() {
    if [[ -n "$ETCD_HOST" && -n "$ETCD_PORT" ]]; then
        curl --noproxy $ETCD_HOST -sSL http://$ETCD_HOST:$ETCD_PORT/v2/keys/$MASTER_KEY -XPUT -d value="$IP"
    fi
}

register_slave() {
    if [[ -n "$ETCD_HOST" && -n "$ETCD_PORT" ]]; then
        curl --noproxy $ETCD_HOST -sSL http://$ETCD_HOST:$ETCD_PORT/v2/keys/$SLAVE_KEY_DIR/$HOSTNAME -XPUT -d value="$IP"
    fi
}

start_dns_watcher() {
    nohup $DNS_WATCHER &
}

start_slave_watcher() {
    nohup $SLAVE_WATCHER &
}

forground() {
    while :;
    do
        echo `date`
        sleep 60
    done
}

# main menu
case $1 in
    namenode)
        wait_for_confserver
        start_dns_watcher
        register_dns
        register_master
        get_master
        start_slave_watcher
        hadoop_configure_common
        hadoop_configure_hdfs
        start_sshd
        hadoop_format_namenode
        hadoop_start_namenode
        forground
        ;;
    datanode)
        wait_for_confserver
        start_dns_watcher
        register_dns
        register_slave
        get_master
        hadoop_wait_for_master
        hadoop_configure_common
        hadoop_configure_hdfs
        start_sshd
        hadoop_start_datanode
        forground
        ;;
    *)
        exec "$@"
esac
