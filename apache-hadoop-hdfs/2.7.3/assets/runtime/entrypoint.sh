#!/bin/bash

set -ex

# linster configurations.
LINSTER=${LINSTER:-/hadoop_assets/runtime/linster}
LINSTER_PORT=${LINSTER_PORT:-1234}

IP=$(ifconfig | grep -A1 eth0 | grep inet | awk '{print $2}' | cut -d":" -f2)

start_sshd() {
    /usr/sbin/sshd
}


start_linster() {
    dnc -l -k -p $LINSTER_PORT -e $LINSTER
}

hadoop_configure_common() {
    chmod go-rx /root/.ssh
    chmod go-rwx /root/.ssh/id_rsa
    chmod go-wx /root/.ssh/authorized_keys
    
    sed -i 's#^export JAVA_HOME.*$#export JAVA_HOME="'"${JAVA_HOME}"'"#g' $HADOOP_CONF_DIR/hadoop-env.sh
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

register_dns() {
    if [[ -n "DNSSERVER" ]]; then
        echo add helloworld $HOSTNAME $IP | nc $DNSSERVER 1234
    fi
}

register_slave() {
    if [[ -n "MASTER" ]]; then
        echo add-slave helloworld $HOSTNAME | nc $MASTER 1234
    fi
}

forground() {
    while :;
    do
        echo `date`
        sleep 60
    done
}


# basic configure for all node
hadoop_configure_common
hadoop_configure_hdfs

register_dns
start_sshd

# main menu
case $1 in
    namenode)
        hadoop_format_namenode
        hadoop_start_namenode
        start_linster
        ;;
    datanode)
        hadoop_start_datanode
        register_slave
        forground
        ;;
    all)
        hadoop_start_dfs
        forground
        ;;
    *)
        exec "$@"
esac
