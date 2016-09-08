#!/usr/bin/env bash

set -ex

nameserver_image="djx339/dnsmasq"
nameserver_container=""
nameserver_ip=""

hadoop_image="djx339/apache-hadoop-hdfs:2.7.3"

container_ip(){
    echo "$(docker inspect --format='{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' $1)"
}

start_nameserver() {
    echo
    echo "===> Starting nameserver $nameserver_image"
    nameserver_container="$(docker run -itd -h nameserver $nameserver_image)"
    nameserver_ip="$(container_ip $nameserver_container)"
    echo "===> Nameserver started"
    echo "===> Nameserver Id: $nameserver_container"
    echo "===> Nameserver IP: $nameserver_ip"
}

start_master() {
    echo
    echo "===> Starting master $hadoop_image"
    master="$(docker run -itd -h master --dns $nameserver_ip $hadoop_image namenode)"
    master_ip="$(container_ip $master)"
    echo add helloworld master $master_ip | nc $nameserver_ip 1234
    echo "===> Master started"
    echo "===> Master Id: $master"
    echo "===> Master IP: $master_ip"
}

start_slave() {
    slave_name="$1"
    echo
    echo "===> Starting master $hadoop_image $slave_name"
    slave="$(docker run -itd -h slave1 --dns $nameserver_ip $hadoop_image datanode)"
    slave_ip="$(container_ip $slave)"
    echo add helloworld $slave_name $slave_ip | nc $nameserver_ip 1234
    echo add-slave helloworld $slave_name | nc $master_ip 1234
    echo "===> Slave $slave_name started"
    echo "===> $slave_name Id: $master"
    echo "===> $slave_name IP: $master_ip"
}

start_nameserver
sleep 2
start_master
sleep 2
start_slave "slave1"
