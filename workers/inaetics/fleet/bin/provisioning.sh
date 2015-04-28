#!/bin/sh

source /opt/inaetics/fleet/bin/common.sh
parse_args $*

DOCKER_NAME="provisioning"
DOCKER_IMG=${DOCKER_REPOSITORY_HOST}:${DOCKER_REPOSITORY_PORT}/inaetics/provisioning:latest

if [ ${COMMAND} = "start" ]
then	
	remove_docker_image ${DOCKER_NAME}
   	/usr/bin/docker pull ${DOCKER_IMG}
	/usr/bin/docker run --rm=true --hostname="${DOCKER_NAME}" --name="${DOCKER_NAME}" -p 8090:8080 -p 2020:2019 -e HOSTPORT=8090 -e ETCDCTL_PEERS=${ETCDCTL_PEERS} ${DOCKER_IMG} /tmp/node-provisioning.sh node-provisioning-${MY_IP} ${MY_IP}
else 
    /usr/bin/docker stop ${DOCKER_NAME}
	remove_docker_image ${DOCKER_NAME}
fi
