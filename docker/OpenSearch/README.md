# OpenSeach Stack

An Elastic Stack Like with opensearch and opensearch dashboard instead ElasticSearch + Kibana.

## What you get

A docker compose stack to bring up OpenSearch, Dashboard and Logstash OSS stack. All services on compose are defined based on official OpenSearch docs with minor changes. Fell free to change and always validade consistance with official docs:

[OpenSearch Docs](https://opensearch.org/docs/latest/getting-started/)

## Logstash samples

I have some experience and daily usage of Elastic Stack to ingest and analize some logs and metrics of some services like:

- Printing Servers
- Fortinet Firewalls
- Web Servers
- Loadbalancers (haproxy, nginx, traefik, CoreDNS (as DNS forwarder loadbalancer) )

Some of then have I little bit complicated log formats, like Fortinet. On elastic stack we have proprietary ingest pipelines with "filebeat setup" but here on OpenSearch i need to do the ingest pipeline manually with logstash. So, the dirs **logstash-samples** and **Ingest-pipelines-Samples** have some logstash filters and OpenSearch pipeline definitions to process this kind of data, some of then are based on Filebeat Ingest pipelines and adapted to OpenSearch. Feel free to use and/or modify.

## OSS Agents

OpenSearch as a fork of ElasticSearch OSS 7.10 has some compatibility with Elastic Beats... I used to use Filebeat, MetricBeat and Logstash in 7.12 OSS version and all works fine. But maybe most recent releases cand work as well. For official Beats OSS download page, check out [OSS agents](./OSS-agents/README.md).

# Starting up stack

- Change **.env** file with desired versions (check latest [Opensearch](https://hub.docker.com/r/opensearchproject/opensearch/tags) and [Logstash OSS](https://hub.docker.com/r/opensearchproject/logstash-oss-with-opensearch-output-plugin/tags) versions)
- Change **.env** initial admin password, take care with minimal password security requirements, i provided a Sample one, don't forget to change!
- build and pull all images to check if all is defined OK on .env

    ```bash
    docker compose build
    docker compose pull
    ```
- bring up the stack

    ```bash
    docker compose up -d
    ```

- check out logs

    ```bash
    docker compose logs -tf
    ```

# Post "install" recommended steps

- make sure you changed default initial passwords as well as internal users passwords (filebeat, logstash, etc)
- configure DataStreams templates and/or Index as needed
- configure State management policies to make sure no space and retention management issues happen
- configure Centralized Identity source as needed (Eg.: ActiveDirectory, Open LDAP, etc)
- configure OpenSearch docker security as recommended on [Official Docs](https://opensearch.org/docs/latest/install-and-configure/install-opensearch/docker/#configuring-basic-security-settings)
- configure Logstash pipelines to centralize data ingestion with Beats Agents (or ingest on OpenSearch if you want a more "raw data ingestion", not recommended aproach IMO)
- add to stack additional services as needed, like a Filebeat container to concentrate Syslog ingestions based on Elastic ªTM templates
