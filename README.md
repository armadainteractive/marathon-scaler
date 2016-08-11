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


Basic usage from command line, adapt to your scheduler practices:

    docker run marathon-scaler http://mesos.leader:5050 http://marathon.mesos:8080 service1,service2,service3

