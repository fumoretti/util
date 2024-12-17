# Good actions and steps

## Git checkout

```yaml
- name: Checkout repository
  uses: actions/checkout@v4
```

## ubuntu-latest add packages

Add some util packages.. change as needed.

```yaml
- name: Prepare runner
  run: |
    apt update
    apt-get install -y rsync ca-certificates tar unzip iputils-ping
```

## Deploy over SSH with RSYNC

```yaml
- name: Deploy Docker stack to docker server
  uses: easingthemes/ssh-deploy@main
  with:
    ARGS: "-rlgoDzvc -i --delete"
    SSH_PRIVATE_KEY: ${{ secrets.HOST_KEY }}
    REMOTE_USER: ${{ secrets.HOST_USER }}
    REMOTE_HOST: ${{ vars.HOST }}
    SOURCE: "my-docker-compose-stack/"
    TARGET: "/u/docker/my-docker-compose-stack/"
    EXCLUDE: "logs/, dir1, file1.abc"
    SCRIPT_BEFORE: |
        echo "Current compose services"
        cd /u/docker/my-docker-compose-stack/ || exit 2
        docker compose ps
    SCRIPT_AFTER: |
        cd /u/docker/my-docker-compose-stack/ || exit 2
        chmod 600 .*.env
        docker compose up -d --build --remove-orphans
```

ref.: [ssh-deploy official github](https://github.com/easingthemes/ssh-deploy)

## Prepare SSH Keys

Prepare SSH keys to next steps interact with targets using SSH.

```yaml
- name: Prepare RSA keys
  run: |
    echo "${{ secrets.HOST_KEY }}" > ~/.ssh/id_rsa
    chmod 600 ~/.ssh/id_rsa
    ssh-keyscan ${{ vars.HOST }} >> ~/.ssh/known_hosts

- name: Validate SSH connectivity
  run: |
    ssh ${{ secrets.HOST_USER}}@${{ vars.HOST }} "date && uptime" || exit 2
```