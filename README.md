# INAETICS cluster

This repository containts an INAETICS cluster environment based on fleet preconfigured for vagrant (virtualbox)

## Run the cluster in Vagrant

* Install Git, Docker, VirtualBox & Vagrant;
* Clone this repository;
* Update docker image submodules:
	* Run `git submodule init`
	* Run `git submodule update`
* Run `cd bootstrap && vagrant up`
* Wait until the bootstrap environment is started and the webpage at `http://172.17.8.2:5000/v1/search` will load
* Build and push docker images to the docker repository registry:
    * ssh into the bootstrap VM with `vagrant ssh`
    * Run `sh docker_build.sh docker-images/provisioning localhost:5000 inaetics/provisioning`
    * Run `sh docker_build.sh docker-images/felix-agent localhost:5000 inaetics/felix-agent`
    * Run `sh docker_build.sh docker-images/celix-agent localhost:5000 inaetics/celix-agent`
    * exit the VM and cd back to project root directory
* Run `cd workers && vagrant up && cd -`;
* Wait until are workers are started (default 5);
* Run `cd workers && vagrant ssh worker-1`;
* Run `inaetics_fleet_manager --start`.

## Starting and reconfiguring the demonstrator

The demonstrator will start automatically after running `inaetics_fleet_manager --start` in previous chapter. 
After that you need to manually find which host is running the web ui:

* Login into a worker host by running `vagrant ssh worker-1` in the workers directory;
* Run `inaetics_fleet_manager --status` to see what is running and where everything is running;
* Find the IP address used for the `felix@1.service` and browse to `http://${ip_address}:8080`;
* The web UI should show some statistics about the demo processing running.

The demonstrator can up scale up by running the following command:

* Run `inaetics_fleet_manager --start --celixAgents=4 --felixAgents=4`;
* Check the result on the machine running the `felix@1.service`;
* The web ui should some some additional statistics.

## Restarting the cluster

You can restart the cluster by running from the project directory:

* Restart bootstrap: `cd bootstrap && vagrant halt && vagrant up && cd -`;
* Stop workers: `cd workers && vagrant halt && cd -`;
* Clear cluster discovery: `sh bin/purge_etcd_discovery.sh http://172.17.8.2:4001 inaetics-cluster-1`;
* Start workers: `cd workers && vagrant up && cd-`.

## Update the docker images 

The docker images (*provision*, *celix-agent* and *felix-agent*) used for INAETICS can be updated by building a new docker images with a correct tag and pushing this tag. e.g to update a provisioning image you can do:

* Git clone the project which needs to be updated (node-provisioning-service, node-agent-service, celix-node-agent-service;
* Make the wanted changes (e.g checkout a different branch);
* Build the docker images with a tag using the ip address & port of the docker registry service and name of the images:
	* for node-provisioning-service: `docker build -t 172.17.8.2:5000/inaetics/provisioning .`;
	* for node-agent-service: `docker build -t 172.17.8.2:5000/inaetics/felix-agent .`;
	* for celix-node-agent-service: `docker build -t 172.17.8.2:5000/inaetics/celix-agent .`.
* Push the image:
	* for node-provisioning-service: `docker push 172.17.8.2:5000/inaetics/provisioning`;
	* for node-agent-service: `docker push 172.17.8.2:5000/inaetics/felix-agent`;
	* for celix-node-agent-service: `docker push 172.17.8.2:5000/inaetics/celix-agent`.

## Vagrant host types

### Bootstrap 

The bootstrap host realizes two things:

1. Run an Etcd for cluster discovery. This Etcd instance is not directly part of the cluster, but is used to register and discover peers which are part of the cluster;
2. run a Docker-registry service. For this demonstration, a Docker-registry service is running outside the cluster and is used to pull the images needed for the cluster (provisioning, celix agent, felix agent).

### Workers 

By default, the cluster is configured for 5 "worker" hosts. This can be changed by editing the `workers/Vagrantfile` file, and changing the value of the `num_instances` key, for example, `num_instances=3`.   
The workers are the machines (is this virtual) that join the cluster. Every worker uses Docker to run images doing the actual work. 

## Known shortcomming

* The cluster still needs a external Etcd to be able to bootstrap the cluster;
* The Docker-registry service is still external, this can be moved to the cluster workers;
* On Fedora the disabling the dynamic firewall (` sudo systemctl stop firewalld.service`) is needed to be able to push and download docker images.

## Debug options

In case of problems one of the following options can be used to get additional info

1. check vagrant:             vagrant status shows if the vagrant machines are correctly running
2. enter vagrant machine:     vagrant ssh &lt;name&gt;, e.g. vagrant ssh worker-1
3. check docker registry:     http://172.17.8.2:5000/v1/search
4. check fleet unit jobs:     enter worker-1  machine with vagrant ssh worker-1, then inaetics_fleet_manager --status
    or low level: vagrant ssh worker-1: etcdctl ls /_coreos.com --recursive
5. check services running:    journalctl -u &lt;service name&gt;:	e.g. journalctl -u docker-registry.service
6. check logging of agents:   docker ps, get container id, then docker logs &lt;container_id&gt;
7. enter docker container:    docker ps, note the container ids. sh /home/core/docker_enter.sh &lt;container_id&gt;
8. debugging etcd:            vagrant ssh worker-1:
        a. Request:  curl -l http://172.17.8.101:4001/v2/leader
           Response: http://172.17.8.102:7001
        b. Request:  curl -l http://172.17.8.102:4001/v2/stats/leader
           Response: shows leader election statistics
        c. Request:  curl -l http://172.17.8.101:4002/v2/stats/self (on every worker)
           Response: shows etcd transport statistics
        d. Request:  curl -l http://172.17.8.102:7001/v2/admin/config (check port number!)
           Response: number of nodes participating in leader election
9. debugging ACE:             use telnet to get into the Gogo shell: telnet &lt;ACE_ip&gt; 2019
10. remote debugging felix agents: remote debugging is enabled on port 8000.
 
