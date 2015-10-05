

# INAETICS demonstrator cluster 

This repository containts the INAETICS demonstrator environment based on CoreOS preconfigured for Vagrant and VirtualBox.

**Note: Due to the further development based on kubernetes, this demonstrator setup might not work any more. Hence, it is recommended to use the kubenetes-demo-cluster**

## Run the demonstrator in Vagrant

See also the `user_guide.pdf` for more detailed instructions and information on running this demonstrator on your own machine.

* Install Git, VirtualBox & Vagrant;
* Clone this repository;
* Make sure the sub modules are initialized and updated:
    * run `git submodule init`;
    * run `git submodule update`;
* Start the bootstrap VM:
    * go to the `bootstrap` directory;
    * run `vagrant up`;
* Wait until the bootstrap VM is started and the URL `http://172.17.8.2:5000/v1/search` returns a valid JSON result;
* Build and push docker images to the docker repository registry:
    * SSH into the bootstrap VM with `vagrant ssh`
    * run `sh docker_build.sh docker-images/provisioning localhost:5000 inaetics/provisioning`
    * run `sh docker_build.sh docker-images/felix-agent localhost:5000 inaetics/felix-agent`
    * run `sh docker_build.sh docker-images/celix-agent localhost:5000 inaetics/celix-agent`
    * exit the VM and go back to project root directory;
* Start the 5 compute resources (workers):
    * go to the `workers` directory;
    * run `vagrant up`;
* Wait until all workers are started;
* Start the INAETICS demonstrator application:
    * run `vagrant ssh worker-1`;
    * run `inaetics_fleet_manager --start`.

## Starting and reconfiguring the demonstrator

The demonstrator application will start automatically after running `inaetics_fleet_manager --start` in previous
section. After this, you need to determine what host is running the web UI:

* In the first worker VM (*worker-1*):
    * run `inaetics_fleet_manager --status` to see what and where everything is running;
    * find the IPv4 address of the node that runs the `felix@1.service`;
    * point your web browser to `http://${ip_address}:8080/`.
* The web UI should show a single page with the statistics of the various parts of the INAETICS demonstrator
  application.

You can scale-out the demonstrator application by running:

* Run `inaetics_fleet_manager --start --celixAgents=3 --felixAgents=3`;
* After a little while, the web UI should display two additional graphs with statistics.

## Running more or fewer workers

By default, the cluster is configured for five(5) compute resources, or workers. To run more or fewer workers, edit the
`workers/Vagrantfile` file, and change the value of the `$num_instances` variable to, for example, `$num_instances=3`.
After saving this change, you need to run `vagrant up` from the `workers` directory.

## Known issues

* Scaling up and down in the demonstrator application takes a long time;
* The compute resources cannot be restarted directly without purging some state information:
    * go to the project root directory;
    * run `sh bin/purge_etcd_discovery.sh inaetics-cluster-1 http://172.17.8.2:4001/v2/keys/_etcd/registry`.

## Debug options

In case of problems one of the following options can be used to get additional info

1. check Vagrant: `vagrant status` shows if the Vagrant machines are correctly running;
2. enter Vagrant machine: `vagrant ssh <name>`, where &lt;name&gt; is the name of the Vagrant machine, for example
   `vagrant ssh worker-1`;
3. check docker registry: `curl http://172.17.8.2:5000/v1/search` should output a valid JSON string;
4. check fleet unit jobs: from the first worker machine (`vagrant ssh worker-1`) use `inaetics_fleet_manager --status`
   or `fleetctl list-units` and `fleetctl list-unit-files`. Use `etcdctl ls /_coreos.com/fleet --recursive` to see what
   is stored in Etcd by Fleet;
5. check services running: `journalctl -u <service name>`, where &lt;service name&gt; is the name of the unit you want
   to check on. For example: `journalctl -u docker-registry.service` will output the logs of the Docker registry;
6. check logging of agents: `docker ps`, get the container ID (first column), then run `docker logs <container_id>`;
7. enter docker container: `docker ps`, get the container ID (first column), then run `sh /home/core/docker_enter.sh
   <container_id>`;
8. debugging etcd: from the first worker machine (`vagrant ssh worker-1`):
    - `curl -l http://172.17.8.101:4001/v2/leader` should return the current leader: `http://172.17.8.102:7001`;
    - `curl -l http://172.17.8.102:4001/v2/stats/leader` shows the leader election statistics;
    - `curl -l http://172.17.8.101:4002/v2/stats/self` (on every worker) shows etcd transport statistics
    - `curl -l http://172.17.8.102:7001/v2/admin/config` (check port number!) shows the number of nodes participating in
      leader election.
9. debugging provisioning server: use telnet to get into the Gogo shell: `telnet <IP address of provisioning service>
   2020`;
10. debugging the Felix agents:
    - use the Felix webconsole on `http://<IP address of Felix agent>:8080/system/console/` and enter the credentials:
      `admin`/`admin`;
    - use telnet to get into the Gogo shell: `telnet <IP address of Felix agent> 2019`;
    - attach your Java debugger to port 8000 of the Felix agent.
 
