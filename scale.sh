#!/usr/bin/env bash
# Script to query Mesos for slave count, and then scale all input services 
# to the same count.  

# Just stop the script if any errors occur
set -e

mesos=$1
marathon=$2
services=$3

if [ -z "$mesos" ] || [ -z "$marathon" ] || [ -z "$services" ]; then
    echo "Usage: ./scale.sh http://my.mesos.address:5050 http://my.marathon.address:8080 list,of,scaled,services"
    exit 1
fi

echo "Querying Mesos for slave count"