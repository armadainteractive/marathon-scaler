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

# If jq exists locally, use that. Otherwise try to use it from path.
if [ -f "jq" ]; then
    echo "Using local copy of jq"
    JQ="./jq" 
else 
    echo "Using JQ from path"
    JQ="jq"
fi 

url="$mesos/metrics/snapshot"

echo "Querying Mesos for slave count"
echo "GET $url"
slaves=$(curl -s "$url" | $JQ -Mcr '.["master/slaves_active"]')

if [ -z "$slaves" ] ; then 
    echo "ERROR: Could not query Mesos slave count, exiting."
    exit 1
fi

echo "There are $slaves slaves active."
echo "Iterating the following services and scaling each (if necessary): $services"

payload="{ \"instances\": $slaves }"

for i in ${services//,/ }
do
    appUrl="$marathon/v2/apps/$i"
    # echo "GET $appUrl"
    current=$(curl -s "$appUrl" | $JQ '.app.instances')
    if [ "$current" == null ]; then
        echo "WARNING: $i: Service does not exist, ignoring."
    else
        if [ "$current" -eq "$slaves" ]; then
            echo "$i: Instance count is already $current, ignoring."
        else 
            echo "$i: Scaling service to $slaves instances - this might fail if there is an ongoing deployment."
            # echo "PUT $appUrl 
            # echo "$payload"
            deploymentId=$(curl -s "$appUrl" -H 'Content-Type: application/json' -X PUT -d "$payload" | jq '.deploymentId')
            if [ "$deploymentId" == null ]; then 
                echo "WARNING: $i: Scale operation failed."
            else 
                echo "$i: Done, the service is currently scaling."
            fi
        fi
    fi
done