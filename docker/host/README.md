## daemon.json

Docker config file that I use on all my docker hosts. On this file we have definition for:

1. docker containers log rotate based on the size of log file and retain _N_ last versions of it at each rotate event

2. a default IPv4 address pool. A very handy config to limit and organize all docker networks ip address. On this config, each docker network created without explicit IP cofig (eg. automatic created by the docker-compose) will have an IP range inside CIDR 172.31.0.0/16 with /27 prefix. For example:

- 172.31.0.1/27 is the first subnet and by default will be used automaticaly to docker0 host network
- the next docker network when created will be assigned with 172.16.0.1.32/27
- the next one with 172.16.0.64/27 and so on

So, to use this daemon.json sample, just copy it to _/etc/docker/_ (common dockerd config path on most Linux Distros) and restart your docker service.