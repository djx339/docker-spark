#!/bin/sh

# linster configurations.
LINSTER=${LINSTER:-/hadoop_assets/runtime/linster}
LINSTER_PORT=${LINSTER_PORT:-1234}

IP=$(ifconfig | grep -A1 eth0 | grep inet | awk '{print $2}' | cut -d":" -f2)


start_linster() {
    nc -lkp $LINSTER_PORT -e $LINSTER
}

hadoop_configure_common() {
    chmod go-rx /root/.ssh
    chmod go-rwx /root/.ssh/id_rsa
    chmod go-wx /root/.ssh/authorized_keys
}

hadoop_configure_hdfs() {
    sed -i 's/{{master}}/'"${MASTER}"'/g' $HADOOP_CONF_DIR/core-site.xml
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


# basic configure for all node
hadoop_configure_common
hadoop_configure_hdfs

# main menu
case $1 in
    namenode)
        hadoop_start_namenode
        ;;
    datanode)
        hadoop_start_datanode
        ;;
    all)
        hadoop_start_dfs
        ;;
    *)
        exec "$@"
esac

# start a linster to dynimic modify hodoop slave file
start_linster
