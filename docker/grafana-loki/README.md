A very basic implementation of Grafana Loki Stack for testing purposes.

Based on official compose files.

[Official Docs](https://grafana.com/docs/loki/latest)   
[Official Docker Compose](https://grafana.com/docs/loki/latest/setup/install/docker/)

Some changes I made:

1. main conf files as docker volumes (based on default ones)
2. main volumes persistence (promtail positions, loki data, etc)


Enjoy!