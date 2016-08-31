.PHONY: run

default: run

run: 
	chmod +x ./scale.sh
	./scale.sh http://localhost:8999/mesos http://localhost:8999/service/marathon service1,service2
