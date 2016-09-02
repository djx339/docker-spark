#!/bin/bash

_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

IMAGE=dnsmasq

BUILD_ARGS=""
[[ -z "$http_proxy" ]]  || BUILD_ARGS="$BUILD_ARGS --build-arg http_proxy=$http_proxy"
[[ -z "$https_proxy" ]] || BUILD_ARGS="$BUILD_ARGS --build-arg http_proxy=$https_proxy"

build_image() {
	docker build  -t $IMAGE $BUILD_ARGS $_dir
}

cid=""
ip=""

start() {
	cid=$(docker run -itd $IMAGE)
    ip=$(docker inspect --format='{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' $cid)
    echo "IP: $ip"
}

test() {
    echo add helloworld master 192.168.199.199 | nc $ip 1234
    if dig @$ip master | grep 192.168.199.199; then
        echo tests ok.
    else
        echo tests failed.
    fi
}

build_image
start
test
