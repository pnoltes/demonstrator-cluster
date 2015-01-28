#!/bin/bash
# 
# Purges the discovered node information from an Etcd cluster.
#
# Usage: ./purge_etcd_discovery.sh <TOKEN> [<BASE URL>]
#
# Example: ./purge_etcd_discovery.sh my_cluster_token http://localhost:4001/v2/keys/_etcd/registry
# 
# needs both `curl` and `jshon` (http://kmkeen.com/jshon/) in order to work.
# 
# Copyright (C) 2015 - INAETICS <www.inaetics.org> - licensed under Apache Public License v2.

# check whether our preconditions are met...
curl --version 1>/dev/null 2>&1 || { echo "No curl binary found?!"; exit 1; }
jshon --version 1>/dev/null 2>&1 || { echo "No jshon binary found?!"; exit 1; }

ARG=$1
if [ "$ARG" == "" ]; then
    echo "Purge node discovery information from Etcd.

  Usage: $0 <token> [<base URL>]
  
  where:
    <token> is the discovery token to purge (an UUID), and
    <base URL> the base URL of the discovery server (defaults to https://discovery.etcd.io).
"
    exit 1
fi
URL=${2:-https://discovery.etcd.io}

url="$URL/$ARG"

echo "Cleaning discovered nodes for $ARG from $URL..."
# Select all "key" values from "node/nodes" and unescape them; then we cut the key-value and remove the /_etcd/registry/ parts
nodes=$(curl -s $url | jshon -Q -e node -e nodes -a -e key -u | cut -d\/ -f4-)
for node in $nodes; do
    echo "Deleting node '$node'..."
    curl -s -XDELETE "$URL/$node"
done
echo "Deleting '_state'..."
curl -s -XDELETE "$url/_state" -o /dev/null

###EOF###
