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
SUBNET_INTERFACE=172.17.8


# Etcd config
ETCD_CLIENT_PORT=4001
ETCD_PEER_PORT=7001

HOSTNAME=""
MACHINE_ID=""
INSTANCE_ID=""
COMMAND=""

function parse_args {
	for ARG in $*; do
	  case ${ARG} in
	    --stop)
	      COMMAND="stop"
	    ;;
	    --start)
	      COMMAND="start" 
	    ;;
	    --hostname=*)
	      HOSTNAME=`echo ${ARG} | cut -d"=" -f2`
	    ;;
	    --machineId=*)
	      MACHINE_ID=`echo ${ARG} | cut -d"=" -f2`
	    ;;
	    --instanceId=*)
	      INSTANCE_ID=`echo ${ARG} | cut -d"=" -f2`
	    ;;
	    *)
		echo "Unknown argument ${ARG}"
	    ;;
	  esac
	done

	if [[ -z ${HOSTNAME} || -z ${MACHINE_ID} || -z ${COMMAND} || -z ${INSTANCE_ID} ]] 
	then
		echo "Usage $0 --hostname=<hostname> --machineId=<machineid> --instanceId=<instanceid> (--start | --stop)"
		exit 1
	fi

}


function remove_docker_image {
	IMG_NAME=$1
 	GOT_IMG=$(/usr/bin/docker ps -a | grep ${IMG_NAME})
	if [ -n "${GOT_IMG}" ] 
	then
		/usr/bin/docker rm -f ${IMG_NAME}
	fi
}
