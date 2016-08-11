# marathon-scaler

Docker image calling Mesos for slave count, and then scaling given Marathon
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

Basic usage from command line, adapt to your scheduler practices:

    docker run marathon-scaler http://mesos.leader:5050 http://marathon.mesos:8080 service1,service2,service3

With Chronos the setup is e.g.:

    {
        "schedule": "R/2016-01-01T10:13:00Z/PT10M",
        "name": "scale-per-node-services",
        "owner": "monitor@armadainteractive.com",
        "container": {
            "type": "DOCKER",
            "image": "951625648013.dkr.ecr.us-east-1.amazonaws.com/marathon-scaler:1.0.3"
        },
        "cpus": "0.1",
        "mem": "80",
        "uris": [ ],
        "command": "./scale.sh http://leader.mesos:5050 http://marathon.mesos:8080 logspout"
    }

