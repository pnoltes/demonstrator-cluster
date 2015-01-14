#!/bin/sh

DEFAULT_REPOSITORY_DOCKER_HOST=172.17.8.2
DEFAULT_REPOSITORY_DOCKER_PORT=5000

DOCKER_REPOSITORY_HOST=$(etcdctl get /inaetics/docker/repository/host 2> /dev/null || /bin/echo ${DEFAULT_REPOSITORY_DOCKER_HOST})
DOCKER_REPOSITORY_PORT=$(etcdctl get /inaetics/docker/repository/port 2> /dev/null || /bin/echo ${DEFAULT_REPOSITORY_DOCKER_PORT})

# Script configuration
VERBOSE_LOGGING=true
RETRY_INTERVAL=30
UPDATE_INTERVAL=300

# Node configuration
#NODE_ID=
#NODE_IP=172.17.8.1
#NODE_IF=
NODE_SUBNET=192.168.1
SUBNET_INTERFACE=eth1

# Docker repository
#DOCKER_PORT=4243
#DOCKER_REPOSITORY_HOST="192.168.1.183"
#DOCKER_REPOSITORY_PORT=8080

# Etcd config
ETCD_CLIENT_PORT=4001
ETCD_PEER_PORT=7001
#ETCD_STARTUP_IMAGE="coreos/etcd:latest"
#ETCD_STARTUP_PEERS="192.168.1.181"

# External ETCD peer (in case of external ETCD cluster)
#EXTERNAL_ETCD_STARTUP_PEERS="192.168.1.180"

# Node provisioning config
#NODE_PROVISIONING_HOST="192.168.1.181"

#Controller config
#CONTROLLER_IMAGE="inaetics/node-controller:latest"
#CONTROLLER_ENTRY="/var/lib/node-controller/node-controller"
