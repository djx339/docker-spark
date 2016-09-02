#!/bin/bash

_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

IMAGE=dnsmasq

BUILD_ARGS=
[[ -z "$http_proxy" ]]  || BUILD_ARGS="$BUILD_ARGS --build-arg http_proxy=$http_proxy"
[[ -z "$https_proxy" ]] || BUILD_ARGS="$BUILD_ARGS --build-arg http_proxy=$https_proxy"

build_image() {
	docker build  -t $IMAGE $BUILD_ARGS $_dir
}

start() {
	docker run -itd $IMAGE
}

build_image
start
