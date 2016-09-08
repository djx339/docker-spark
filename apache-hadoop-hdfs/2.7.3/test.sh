#!/usr/bin/env bash

set -e

nameserver_image="djx339/dnsmasq"
nameserver_container=""
nameserver_ip=""

hadoop_image="djx339/apache-hadoop-hdfs:2.7.3"

container_ip(){
    echo "$(docker inspect --format='{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' $1)"
}

start_nameserver() {
    echo "===> Starting nameserver $nameserver_image"
    nameserver_container="$(docker run -itd -h nameserver $nameserver_image)"
    nameserver_ip="$(container_ip $nameserver_container)"
    echo "===> Nameserver started"
    echo "===> Nameserver Id: $nameserver_container"
    echo "===> Nameserver IP: $nameserver_ip"
}

start_master() {
    master="$(docker run -itd -h master $hadoop_image namenode)"
    master_ip="$(container_ip $master)"
    echo add helloworld master $master_ip | nc $nameserver_ip 1234
}

start_slave() {
    slave_name="$1"
    slave="$(docker run -itd -h slave1 $hadoop_image datanode)"
    slave_ip="$(container_ip $slave)"
    echo add helloworld $slave_name $slave_ip | nc $nameserver_ip 1234
}

start_nameserver
sleep 2
start_master
sleep 2
start_slave "slave1"
