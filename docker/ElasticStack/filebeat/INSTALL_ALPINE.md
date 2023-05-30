# How to install filebeat

To install filebeat-8 on Alpine Linux with the oficial tarball from Elastic.

## Install dependencies

```
apk add --update-cache libc6-compat go
```

## Download/Prepare Files

```
cd /var/tmp
wget https://artifacts.elastic.co/downloads/beats/filebeat/filebeat-8.8.0-linux-x86_64.tar.gz
tar -xvzf filebeat-8.8.0-linux-x86_64.tar.gz -C /opt/
mv /opt/filebeat-8.8.0-linux-x86_64 /opt/filebeat-8
```

## Copy filebeat conf samples

Copy **filebeat.yml** from **./filebeat** directory of this repository to __/opt/filebeat-8/__ on the Alpine Linux host.

## Create open-rc service scripts

- Copy **filebeat** from **./filebeat/init.d** directory of this repository to __/etc/init.d/__ on the Alpine Linux host.

- Change permissions of the script

```
chmod 775 /etc/init.d/filebeat
```

- Add and Enable filebeat service

```
rc-update add filebeat default
```

- Start and Stop filebeat service to validate

Start:

```
service filebeat start
```

Expected out:

    * Starting filebeat-8 ...

With filebeat process running:

```
pidof filebeat
3038
```

To stop:

```
service filebeat stop
```

Expected out:

    * Stopping filebeat ...

With no more filebeat process on the host:

```
pidoff filebeat
ps -ef |grep filebeat
```