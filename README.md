INAETICS cluster

This repository containts an INAETICS cluster environment based on fleet preconfigured for vagrant (virtualbox)

##Run the cluster in Vagrant

* Install Git, Docker, VirtualBox & Vagrant
* Clone this repository
* Update docker image submodules
	* Run `git submodule init`
	* Run `git submodule update`
* Run `cd bootstrap && vagrant up`
* Wait until the boottrap environment is started and the webpage at http://172.17.8.2:5000/v1/search will load
* Build & Push docker images to the docker repository registry
	* Configure docker for a insecure registry (private registry) 
		* For Fedora: add `--insecure-registry 172.17.8.2:5000` to `/etc/sysconfig/docker` 
	* If needed start docker, generally
		* For Fedora: `systemctl start docker.service`
	* Build, tag, and push the docker images
		* Run `sh bin/docker_build.sh docker-images/provisioning 172.17.8.2:5000 inaetics/provisioning`
		* Run `sh bin/docker_build.sh docker-images/felix-agent 172.17.8.2:5000 inaetics/felix-agent`
		* Run `sh bin/docker_build.sh docker-images/celix-agent 172.17.8.2:5000 inaetics/celix-agent`
* Run `cd workers && vagrant up && cd -`
* Wait until are workers are started (default 5). 
* Run `cd workers && vagrant ssh worker-1`
* Run `inaetics_fleet_manager --start`

##Starting and reconfiguring the demonstrator
The demonstrator will start automatically after running `inaetics_fleet_manager --start` in previous chapter. 
After that you need to manually find which host is running the web ui:
* Login into a worker host by running `vagrant ssh worker-1` in the workers directory
* Run `inaetics_fleet_manager --status` to see what is running and where everything is running
* Find the ip used for the felix@1.service and browse to http://${ip_address}:8080
* The web ui should show some stastictics about the demo processing running

The demonstrator can up scale up by running the following command :
* Run `inaetics_fleet_manager --start --celixAgents=4 --felixAgents=4`
* Check the result on the machine running the felix@1.service 
* The web ui should some some additional stastictics.

##Restarting the cluster
You can restart the cluster by running from the project directory :
* Restart bootstrap: `cd bootstrap && vagrant halt && vagrant up && cd -`
* Stop workers: `cd workers && vagrant halt && cd -`
* Clear cluster discovery: `sh bin/purge_etcd_discovery.sh http://172.17.8.2:4001 inaetics-cluster-1
* Start workers: `cd workers && vagrant up && cd-`


##Update the docker images 
The docker images (provision,celix-agent & felix-agent) used for INAETICS can be updated by building a new docker images with a correct tag and pushing this tag. e.g to update a provisioning image you can do:

* Git clone the project which needs to be updated (node-provisioning-service, node-agent-service, celix-node-agent-service`.
* Make the wanted changes (e.g checkout a different branch)
* Build the docker images with a tag using the ip address & port of the docker registry service and name of the images
	* (For node-provisioning-service) `docker build -t 172.17.8.2:5000/inaetics/provisioning .`
	* (For node-agent-service) `docker build -t 172.17.8.2:5000/inaetics/felix-agent .`
	* (For celix-node-agent-service) `docker build -t 172.17.8.2:5000/inaetics/celix-agent .`
* Push the image 
	* (For node-provisioning-service) `docker push 172.17.8.2:5000/inaetics/provisioning` 
	* (For node-agent-service) `docker push 172.17.8.2:5000/inaetics/felix-agent` 
	* (For celix-node-agent-service) `docker push 172.17.8.2:5000/inaetics/celix-agent` 

##Vagrant host types
###Bootstrap 
The bootstrap host realizes two things:

* Run an etcd for cluster discovery. This etcd is not directly part of the cluster, but is used to register and discover peers which are of the cluster
* Run a docker registry service. For now a docker registry service is runned outside the cluster. This docker registry is used to pull the images needed for the cluster (provisioning, celix agent, felix agen)

###Workers 
Default the cluster is configured for 5 "worker" hosts. This can be changed by editing the file `workers/Vagrantfile` and updating the following line `num_instances=5`. 
The workers are the machines (is this virtual) which join the cluster. Every worker will use docker to run images doing the actual work. 

##Known shortcomming
* The cluster still needs a external etcd to be able to bootstrap the cluster.
* The docker registry service is still external, this can be moved to the cluster workers.
* On Fedora the disableling the dynamic firewall (` sudo systemctl stop firewalld.service`) is needed to be able to push and download docker images.
