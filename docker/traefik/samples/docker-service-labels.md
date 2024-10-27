# Traefik Docker service labels for common situations

Traefik labels can be very trick and annoying, many different syntax, vastly possibilities, lack of examples specific for docker provider in official traefik docs, etc...

So i decided to compile the most common situations i had in past months using traefik as reverse proxy for my docker servers.

## TCP HostSNI

Simple exposes a backend TCP port (eg. mariadb TCP/3306) routing it based on requested host name.

```yaml
labels:
- "traefik.tcp.routers.myapp.rule=HostSNI(`myapp.local.lan`)"
- "traefik.tcp.routers.myapp.entrypoints=mariadb"
- "traefik.tcp.services.myapp.loadbalancer.server.port=3306"
```

Entrypoint for 3306 port in the traefik Dynamic configuration file:

```yaml
entryPoints:
  mariadb:
    address: ":3306"
```

## TCP HostSNI with TLS passthrough

When you need to serve a HTTPs or TCP docker service that manage your own public CA certificates. That way traefik expose the port of the docker backend passing TLS over TCP avoinding the needs of TLS negotiation on the traefik entrypoint too.

```yaml
labels:
- "traefik.tcp.routers.myapp.rule=HostSNI(`myapp.local.lan`)"
- "traefik.tcp.routers.myapp.tls.passthrough=true"
- "traefik.tcp.services.myapp.loadbalancer.server.port=443"
```

## TCP HostSNI with TLS termination on traefik

When you need to serve a TCP port secured by TLS for service that support SSL/TLS (Eg.: postgreSQL) and route it based on SNI, but don't want to add certificates on each backend service.

```yaml
- "traefik.enable=true"
- "traefik.tcp.routers.postgres.rule=HostSNI(`postgres.local.lan`)"
- "traefik.tcp.routers.postgres.entrypoints=pgsecure"
- "traefik.tcp.routers.postgres.tls=true"
- "traefik.tcp.routers.postgres.tls.passthrough=false"
- "traefik.tcp.routers.portgres.service=postgres@docker"
- "traefik.tcp.services.postgres.loadbalancer.server.port=5432"
```

Entrypoint for 5432 port in traefik Dynamic conf file:

```yaml
entryPoints:
  pgsecure:
    address: :5432
```

For the tls certs you can use a Default Store like in HTTPS examples... or specify certFiles.

## HTTPs terminated in traefik (plain HTTP backend)

Expose with HTTPs a non HTTPs backend, very common to do TLS termination in traefik side.

```yaml
- "traefik.http.routers.myapp.rule=Host(`myapp.local.lan`)"
- "traefik.http.routers.myapp.entrypoints=websecure"
- "traefik.http.services.myapp.loadbalancer.server.port=80"
```

## HTTPs backend skiping TLS verify

When a docker service app have self signed certificates without HTTPS downgrade option (like passbolt or PWM LDAP management apps).

```yaml
- "traefik.http.routers.myapp.rule=Host(`myapp.local.lan`)"
- "traefik.http.services.myapp.loadbalancer.server.scheme=https"
- "traefik.http.services.myapp.loadbalancer.server.port=443"
- "traefik.http.services.myapp.loadbalancer.serversTransport=mytransport@file""
```

In the dynamic configuration file of traefik, create a http serversTransport and set it to ignore TLS verify:

```yaml
http:
  serversTransports:
    mytransport:
      insecureSkipVerify: true
```

## HTTPs backend with end to end TLS

End to end TLS betwheen Traefik and Backend docker service.

```yaml
- "traefik.http.routers.myapp.rule=Host(`myapp.local.lan`)"
- "traefik.http.services.myapp.loadbalancer.server.scheme=https"
- "traefik.http.services.myapp.loadbalancer.server.port=443"
- "traefik.http.services.myapp.loadbalancer.serversTransport=mytransport@file""
```

In the dynamic configuration file of traefik, create a http serversTransport and set it with serverName option defining the certificate SAN name of the app certificate.

```yaml
http:
  serversTransports:
    mytransport:
      insecureSkipVerify: false
      serverName: myapp.local.lan
      #specify the CA certificate inside traefik container if needed (eg.: custom/non public CA)
      rootCAs: /path-to-ca-certificate.crt
```

This aproach avoid the common problem of internal error 500 message when traefik uses the container IP to send HTTPs traffic to backend:

    Eg: '500 Internal Server Error' caused by: x509: cannot validate certificate for 172.31.0.45 because it doesn't contain any IP SANs

References:

https://github.com/traefik/traefik/issues/7454  
https://doc.traefik.io/traefik/routing/services/#serverstransport_1  