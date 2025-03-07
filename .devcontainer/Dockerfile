FROM debian:unstable

ARG LOCAL_USER
ARG TIMEZONE
ARG ANSIBLE_VERSION

ENV LANG=C.UTF-8
ENV TZ=${TIMEZONE:-UTC}

#install utils
RUN apt-get update && \
    apt-get install -y \
    awscli \
    # azure-cli \
    bind9-dnsutils \
    curl \
    ftp \
    git \
    iputils-ping \
    jq \
    openssh-client \
    rclone \
    rsync \
    sshpass \
    sudo \
    unzip \
    vim

#add container user, IDs will be updated by devcontainer scripts
RUN useradd -G sudo -s /bin/bash -m -u 2999 ${LOCAL_USER}
RUN mkdir /home/${LOCAL_USER}/.ssh && chmod 700 /home/${LOCAL_USER}/.ssh
RUN echo "${LOCAL_USER} ALL=(ALL:ALL) NOPASSWD:ALL" >> /etc/sudoers

#install ansible
COPY ansible_install.sh /tmp/
RUN chmod +x /tmp/ansible_install.sh && sudo su - ${LOCAL_USER} -c "/tmp/ansible_install.sh ${ANSIBLE_VERSION}"

#install vscode server
#RUN curl -fsSL https://code-server.dev/install.sh | sh
