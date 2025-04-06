#!/bin/bash

export VERSION=${1:-2.99}

if [ "${VERSION//./}" -ge 218 ]
then

    sudo apt-get update
    sudo apt-get install -y ansible ansible-lint

else

    echo "installing legacy ansible (2.16.x)"
    sudo apt-get update && sudo apt-get install -y pipx
    pipx install --include-deps ansible==9.13.0
    pipx inject ansible ansible-lint
    pipx ensurepath
    ln -s ~/.local/share/pipx/venvs/ansible/bin/ansible-lint ~/.local/bin/ansible-lint

    echo "Enabling legacy SSH client Ciphers, Kex and Host key types"

    echo 'HostKeyAlgorithms +ssh-rsa
PubkeyAcceptedKeyTypes +ssh-rsa
KexAlgorithms +diffie-hellman-group1-sha1
Ciphers +aes128-cbc' | sudo tee -a /etc/ssh/ssh_config

fi