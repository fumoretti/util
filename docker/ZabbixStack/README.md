# The ZabbixServer Stack

An objective and simple zabbix server stack that i did based on official Zabbix docker images.

The stack is composed by the following services:

1. zabbix agent 2 in passive check mode to serve as agent to the ZabbixServer container
2. Zabbix web frontend based on NGINX exposing ports HTTP 80 and 443 on docker host by default
3. Zabbix Server with support to Mysql/Mariadb
4. MariaDB database


All services are defined in _docker-compose.yaml_ based on official [Zabbix Docs](https://www.zabbix.com/documentation/current/en/manual/installation/containers) with changes that i did for personal use.

Please change it based on your needs.

# First deploy

Just clone this repository into a docker host plus docker-compose, change directory to _util/docker/ZabbixStack_, edit default important settings and start up the stack.

## change default passwords

Users and passwords must be changed on env files of each service (check **env_file:** section on each compose service). I highly recommend to do that before first stack startup up.

## change HTTP(S) ports

By default i normaly use a reverse proxy inside docker host to control access to services like this, so i used zabbix default ports **8080** and **8443** by default on this stack and exposed it on **front** service. Please change that based on your environment.

## Startup

```
cd util/docker/ZabbixStack
docker-compose up -d
```

# Post deploy steps

## First WEB UI access

After all services are up and running at first time, Zabbix take some time to prepare the database schema and all other stuffs. This process can take around 1 minute or a bit more.

After that, ZabbixServer will be available on http://DOCKER-HOST-ADDRESS:8080 .

The initial user and password is **Admin/zabbix** . Please check Official Docs in case of uncessful first login. I'll always keep the latest stable version and default initial users/passwords on this stack.

## Change "Zabbix Server" host config

To make the "Zabbix Server" inventory host correctly use the deployed zabbix agent container, just change the host to use DNS address instead localhost IP (used by default on fresh install Zabbix Server). This is needed since Zabbix don't provides your own agent on server docker image making the 127.0.0.1 an invalid IP for the agent. To change the Zabbix Server host config:

1. login to zabbix WEB UI with Admin account
2. on the left panel, go to **Monitoring > Hosts**
3. click on **Zabbix server** and **Host** (CONFIGURATION section on menu)
4. on **DNS name** put your zabbix-agent service name (**server-agent** by default on this compose)
5. select **DNS** on _Connect to_ option
6. Click on **Update** button

With this change the zabbix server container will use the agent container DNS name instead. this change take some time to make effect and clear out Zabbix Server self monitoring problems.

## Change zabbix default passwords

This stack contains default passwords from Zabbix products, please change it asap.

## Fine tune Zabbix Server and Database parameters

On each service directory i put a env file to easily define and change enviorment variables. Use its to fine tune the stack services. All recommed .d conf directories are mapped to containers and also can be used to fine tune parameters.

## Take care of .env files permissions

By default i changed permissions masks on env files to better protect sensitive data like passwords. Please double check this before use it.