FROM debian:bookworm

ENV LANG=C.UTF-8

RUN apt-get update && apt-get install -y openssh-client
#install vscode server
RUN curl -fsSL https://code-server.dev/install.sh | sh

