# HAproxyHTTP_lb01

HAproxy stack with the following components:

- HAProxy pre configured to operate in HTTP mode with certs and DNS resolution
- Rsyslog to concentrate HAproxy logs in RAW format (prepared to send to ElasticStack with filebeat + logstash)
- Rotate logs on Rsyslog
- hatop tool
- HAproxy conf samples to route requests based on path and domains
- Pre configured drone-CI/CD file
- HAproxy default deny 403 when no matched ACLs
