#!/bin/sh

HOSTNAME=""
MACHINE_ID=""
COMMAND=""

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
    *)
	echo "Unknown argument ${ARG}"
    ;;
  esac
done

if [[ -z ${HOSTNAME} || -z ${MACHINE_ID} || -z ${COMMAND} ]] 
then
	echo "Usage $0 --hostname=<hostname> --machineId=<machineid> (--start | --stop)"
	exit 1
fi

source /opt/inaetics/fleet/bin/settings.sh

MY_IP=$(ifconfig ${SUBNET_INTERFACE} | grep inet\ | awk '{print $2}')
#DOCKER_IP=$(ifconfig docker0 | grep inet\  | awk '{print $2}')

ETCDCTL_PEERS=${MY_IP}:${ETCD_CLIENT_PORT}
#DOCKER_HOST=tcp://${DOCKER_IP}:${DOCKER_PORT}

if [ ${COMMAND} = "start" ] 
then
	/usr/bin/docker run --rm=true --hostname="felix-${HOSTNAME}" --name="felix-${HOSTNAME}" -p 6667:6666 -p 8080:8080 -p 9001:9001 -e ETCDCTL_PEERS=${ETCDCTL_PEERS} ${DOCKER_REPOSITORY_HOST}:${DOCKER_REPOSITORY_PORT}/inaetics/felix-agent:latest /tmp/node-agent.sh felix_${MACHINE_ID} $MY_IP
else
	/usr/bin/docker stop "felix-${HOSTNAME}"
	#/usr/bin/docker rm "felix-${HOSTNAME}"
fi
