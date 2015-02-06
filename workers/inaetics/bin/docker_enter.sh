#!/bin/bash

[ $# -ne 1 ] && echo "Usage: $0 <container_id>" && exit 1

CONTAINER_ID=$1

CONTAINER_PID=$(docker inspect --format "{{ .State.Pid }}" ${CONTAINER_ID})
sudo nsenter --target ${CONTAINER_PID} --mount --uts --ipc --net --pid
