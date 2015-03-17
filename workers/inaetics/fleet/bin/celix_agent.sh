#!/bin/sh

source /opt/inaetics/fleet/bin/common.sh
parse_args $*

DOCKER_NAME="celix_${INSTANCE_ID}"
DOCKER_IMG=${DOCKER_REPOSITORY_HOST}:${DOCKER_REPOSITORY_PORT}/inaetics/celix-agent:latest

if [ ${COMMAND} = "start" ] 
then
	remove_docker_image ${DOCKER_NAME}
	/usr/bin/docker pull ${DOCKER_IMG}
	/usr/bin/docker run --rm=true --hostname="celix-${HOSTNAME}" --name="${DOCKER_NAME}" -p 6668:6666 -p 9999:9999 -p 8888:8888 -e ETCDCTL_PEERS=${ETCDCTL_PEERS} ${DOCKER_IMG} /tmp/node-agent.sh ${DOCKER_NAME} $MY_IP
else
	/usr/bin/docker stop ${DOCKER_NAME}
	remove_docker_image ${DOCKER_NAME}
fi

