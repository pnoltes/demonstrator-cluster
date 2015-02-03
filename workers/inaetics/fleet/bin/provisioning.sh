#!/bin/sh

source /opt/inaetics/fleet/bin/common.sh
parse_args $*

MY_IP=$(ifconfig ${SUBNET_INTERFACE} | grep inet\ | awk '{print $2}')
#DOCKER_IP=$(ifconfig docker0 | grep inet\  | awk '{print $2}')

ETCDCTL_PEERS=${MY_IP}:${ETCD_CLIENT_PORT}
#DOCKER_HOST=tcp://${DOCKER_IP}:${DOCKER_PORT}

if [ ${COMMAND} = "start" ]
then	
	remove_docker_image "ace-${HOSTNAME}"
	/usr/bin/docker pull ${DOCKER_REPOSITORY_HOST}:${DOCKER_REPOSITORY_PORT}/inaetics/provisioning:latest
	/usr/bin/docker run --rm=true --hostname="ace-${HOSTNAME}" --name="ace-${HOSTNAME}" -p 8080:8080 -e ETCDCTL_PEERS=${ETCDCTL_PEERS} ${DOCKER_REPOSITORY_HOST}:${DOCKER_REPOSITORY_PORT}/inaetics/provisioning:latest /tmp/node-provisioning.sh node-provisioning-${MY_IP} ${MY_IP}
else 
	/usr/bin/docker stop "ace-${HOSTNAME}"
	remove_docker_image "ace-${HOSTNAME}"
fi
