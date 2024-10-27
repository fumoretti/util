# Traefik entrypoint samples


## TCP/UDP entrypoint port (eg. syslog/514):

```yaml
entryPoints:
  tcpsyslog:
    address: ":514"
  udpsyslog:
    address: ":514/udp"
```

## TCP entrypoint port (eg. mariadb/3306)

TCP/UDP entrypoint (eg. syslog/514):

```yaml
entryPoints:
  mariadb:
    address: ":3306"
```

## HTTP entrypoint

```yaml
entryPoints:
  web:
    address: :80
```

## HTTPS entrypoint

```yaml
entryPoints:
  websecure:
    address: :443
    http:
      tls: true
```

## TLS store and certFiles Dynamic config

TLS default store with local certificate files.

```yaml
## default single domain cert
tls:
  stores:
    default:
      defaultCertificate:
        certFile: /certs/local.lan.crt
        keyFile: /certs/local.lan.key
#Disable TLS version 1.0 and 1.1
  options:
    default:
      minVersion: VersionTLS12
```

TLS multi domains cert files, autodetect by domain during routing.

```yaml
tls:
 options:
   default:
     minVersion: VersionTLS12
 certificates:
   - certFile: /certs/example.local.lan.crt
     keyFile: /certs/example.local.lan.key
   - certFile: /certs/example.local2.lan.crt
     keyFile: /certs/example.local2.lan.key
```

## HTTP with redirect all to HTTPS

```yaml
entryPoints:
  web:
    address: :80
    http:
      redirections:
        entryPoint:
          to: websecure
          scheme: https
  websecure:
    address: :443
    http:
      tls: true
```

## HTTPS based on priority 1000

Redirect all HTTP to HTTPS except if priority greater than 1000 is defined by a service:

```yaml
entryPoints:
  web:
    address: :80
    http:
      redirections:
        entryPoint:
          to: websecure
          scheme: https
          priority: 1000
  websecure:
    address: :443
    http:
      tls: true
```

To expose a plain HTTP service we need a priority label with value greater than 1000. For example:

```yaml
    labels:
      - "traefik.http.routers.myapp.rule=(Host(`myapp.local.lan`)"
      - "traefik.http.routers.myapp.entrypoints=web"
      # bypass HTTPS priority with greater value
      - "traefik.http.routers.myapp.priority=2000"
      - "traefik.http.services.myapp.loadbalancer.server.port=80"
```
