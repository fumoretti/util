FROM debian:stable

ENV DEBIAN_FRONTEND=noninteractive

# Dependências mínimas
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        ca-certificates \
        curl \
        bash \
        jq \
    && rm -rf /var/lib/apt/lists/*

# Baixar shell2http estático (binário oficial)
ARG S2H_VERSION=1.17.0

RUN curl -L -o /var/tmp/shell2http.deb \
    https://github.com/msoap/shell2http/releases/download/v${S2H_VERSION}/shell2http_${S2H_VERSION}_linux_amd64.deb && \
    apt-get install -y /var/tmp/shell2http.deb

RUN groupadd -g 1000 s2h && \
    useradd -u 1000 -g 1000 -s /usr/bin/bash -m s2h

RUN mkdir /data && \
    touch /data/all-lists-here.txt && \
    chown -R s2h:s2h /data

COPY ./scripts /scripts

RUN chown root:s2h /scripts && \
    chmod +x /scripts/*.sh && \
    rm -rf /var/tmp/*

WORKDIR /scripts
USER s2h

EXPOSE 8080

ENTRYPOINT [ "/usr/bin/shell2http" ]