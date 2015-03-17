#!/bin/sh

source /opt/inaetics/fleet/bin/common.sh
parse_args $*

DOCKER_NAME="felix_${INSTANCE_ID}"
DOCKER_IMG=${DOCKER_REPOSITORY_HOST}:${DOCKER_REPOSITORY_PORT}/inaetics/felix-agent:latest

if [ ${COMMAND} = "start" ] 
then
	remove_docker_image ${DOCKER_NAME}
	/usr/bin/docker pull ${DOCKER_IMG}
	/usr/bin/docker run --rm=true --hostname="felix-${HOSTNAME}" --name="${DOCKER_NAME}" -p 6667:6666 -p 8080:8080 -p 9001:9001 -p 8000:8000 -p 2019:2019 -e ETCDCTL_PEERS=${ETCDCTL_PEERS} ${DOCKER_IMG} /tmp/node-agent.sh ${DOCKER_NAME} $MY_IP
else
	/usr/bin/docker stop ${DOCKER_NAME}
	remove_docker_image ${DOCKER_NAME}
fi

