# Docker Driver notes

## Driver Install

```
docker plugin install grafana/loki-docker-driver:3.2.1 --alias loki --grant-all-permissions
```

## Set log driver in compose

```yaml
logging:
  driver: loki
  options:
    loki-url: "http://loki:changeme@loki.local.lan:3100/loki/api/v1/push"
    loki-max-backoff: "1s"
    loki-retries: 3
```

## Loi driver as default in daemon.json

With loki:

```json
{
    "debug" : true,
    "log-driver": "loki",
    "log-opts": {
        "loki-url": "http://loki:changeme@loki.local.lan:3100/loki/api/v1/push",
        "loki-batch-size": "50000",
        "loki-max-backoff": "1s",
        "loki-retries": "3"
    },
    "data-root": "/home/var-lib-docker",
    "default-address-pools": [
         {
             "base": "172.31.0.0/16",
             "size": 27
          }
  ]
}
```

Without loki:

```json
{
    "log-driver": "json-file",
    "log-opts": {
      "max-size": "128m",
      "max-file": "30",
      "labels": "production_status",
      "env": "os,customer"
    },
    "data-root": "/home/var-lib-docker",
    "default-address-pools": [
         {
             "base": "172.31.0.0/16",
             "size": 27
          }
  ]
}
```