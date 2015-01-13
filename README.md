#INAETICS cluster

This repository containts an INAETICS cluster environment based on fleet preconfigured for vagrant (virtualbox)

#Run the cluster in Vagrant

* Install Git, Docker, VirtualBox & Vagrant
* Clone this repository
* Run `cd bootstrap && vagrant up`
* Wait until the boottrap environment is started and the webpage at http://172.17.8.2:5000/v1/search will load
* Build & Push docker images to the docker repository registry
	* Create a workspace to build the docker images
	* `git clone https://github.com/INAETICS/node-provisioning-service.git && cd node-provisioning-service && docker build -t 172.17.8.2:5000/inaetics/provisioning .`
	* `git clone https://github.com/INAETICS/node-agent-service.git && cd node-agent-service && docker build -t 172.17.8.2:5000/inaetics/felix-agent .`
	* `git clone https://github.com/INAETICS/celix-node-provisioning-service.git && cd celix-node-provisioning-service && docker build -t 172.17.8.2:5000/inaetics/celix-agent .`
* Run `cd workers && vagrant up`
* Wait until are workers are started (default 10). 
* Run `cd workers && vagrant ssh worker-1`
* Run `/opt/inaetics/bin/inaetics_fleet_manager.sh --start`

#Starting and reconfiguring the demonstrator
TODO

#Bootstrap 
TODO explain the etcd discovery cluster & explain the docker service registry

#Workers 
TODO explain the workers (fleet configuration)

#Update the docker images 
TODO explain how the the docker images in the docker registry can be updated

#Known shortcomming
* The cluster still needs a external etcd to be able to bootstrap the cluster
* The docker registry service is still external, this can be moved to the cluster workers

