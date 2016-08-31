# marathon-scaler

Simple bash script calling Mesos for slave count, and then scaling given Marathon
services to the same count. Suitable for log collection, monitoring
services etc. that need one service instance per slave. Run with a scheduling
tool (Chronos, Metronome) on your Mesos or DC/OS cluster.

Services, that are scaled like this, need to have the hostname:UNIQUE constraint
on their Marathon descriptor, and they need to accept all slave types:

    "constraints": [
        [
            "hostname",
            "UNIQUE"
        ]
    ],
    "acceptedResourceRoles": [
        "slave_public", "*"
    ],

Unfortunately even the above skips Mesos master nodes, so if something needs to
be collected from them it needs a manual installation.

Works with both local copy of [JQ](https://stedolan.github.io/jq/), or JQ from $PATH.
Mesos agents might not have Jq installed, but it can be copied in with Mesos URI fetcher.
Sample Chronos setup that does this:

    {
        "schedule": "R/2016-01-01T10:13:00Z/PT10M",
        "name": "scale-per-node-services",
        "owner": "monitor@mycompany.com",
        "cpus": "0.05",
        "mem": "40",
        "uris": [
            "https://github.com/stedolan/jq/releases/download/jq-1.5/jq-linux64",
            "https://raw.githubusercontent.com/armadainteractive/marathon-scaler/master/scale.sh"
        ],
        "command": "mv jq-linux64 jq && chmod +x jq scale.sh && ./scale.sh http://leader.mesos:5050 http://marathon.mesos:8080 logspout,dogstatsd"
    }

