#!/bin/sh

source /opt/inaetics/fleet/bin/common.sh
parse_args $*

MY_IP=$(ifconfig ${SUBNET_INTERFACE} | grep inet\ | awk '{print $2}')
#DOCKER_IP=$(ifconfig docker0 | grep inet\  | awk '{print $2}')

ETCDCTL_PEERS=${MY_IP}:${ETCD_CLIENT_PORT}
#DOCKER_HOST=tcp://${DOCKER_IP}:${DOCKER_PORT}

if [ ${COMMAND} = "start" ] 
then
	remove_docker_image "felix-${INSTANCE_ID}"
	/usr/bin/docker pull ${DOCKER_REPOSITORY_HOST}:${DOCKER_REPOSITORY_PORT}/inaetics/felix-agent:latest
	/usr/bin/docker run --rm=true --hostname="felix-${HOSTNAME}" --name="felix-${INSTANCE_ID}" -p 6667:6666 -p 8080:8080 -p 9001:9001 -e ETCDCTL_PEERS=${ETCDCTL_PEERS} ${DOCKER_REPOSITORY_HOST}:${DOCKER_REPOSITORY_PORT}/inaetics/felix-agent:latest /tmp/node-agent.sh felix_${INSTANCE_ID} $MY_IP
else
	/usr/bin/docker stop "felix-${INSTANCE_ID}"
	remove_docker_image "felix-${INSTANCE_ID}"
fi
