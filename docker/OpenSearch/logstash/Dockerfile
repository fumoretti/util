ARG LOGSTASH_OSS_VERSION

FROM opensearchproject/logstash-oss-with-opensearch-output-plugin:${LOGSTASH_OSS_VERSION}

# Add your logstash plugins setup here
# Example: RUN logstash-plugin install logstash-filter-json
RUN logstash-plugin install logstash-input-elastic_serverless_forwarder