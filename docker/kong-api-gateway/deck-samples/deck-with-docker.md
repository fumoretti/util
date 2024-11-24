# Using Kong Deck inside container

Simple run deck container passing the yml files dir as volume.

```
cd /path/to/deck/files
docker run --rm -it -e DECK_KONG_ADDR=http://kong.local.lan:8001 --network host -v $(pwd):/tmp --workdir=/tmp kong/deck:latest gateway ping
```

## Kong ADDR as variable

export KONG_URL=http://kong.local.lan:8001

docker run --rm -it -e DECK_KONG_ADDR=${KONG_URL} --network host -v $(pwd):/tmp --workdir=/tmp kong/deck:latest gateway ping

## Kong auth headers

To add a admin api basic auth authorization header add the follwing parameter:

```
--headers "Authorization: basic YourSuperUserAndSecretBase64Hash="
```

## Kong admin api with HTTPs

By default, deck container don't have ca-certificates package. So, to connect in kong admin api with HTTPs the local machine ca-certificate file can be mounted as docker bind volume.

OpenSuse Linux:

```
-v /etc/ssl/certs/ca-certificates.crt/ca-bundle.pem:/etc/ssl/certs/ca-certificates.crt
```

Ubuntu/Debian:

```
-v /etc/ssl/certs/ca-certificates.crt:/etc/ssl/certs/ca-certificates.crt
```

## Final docker run command

The final docker run command will look like this:

```
docker run --rm -it -e DECK_KONG_ADDR=${KONG_URL} --network host -v /etc/ssl/certs/ca-certificates.crt/ca-bundle.pem:/etc/ssl/certs/ca-certificates.crt -v $(pwd):/tmp --workdir=/tmp kong/deck:latest --headers "Authorization: basic YourSuperUserAndSecretBase64Hash="
```

## Creating command alias in linux

To create a command alias to run deck container with docker, include these lines in your user profile, eg. __~/.profile__, __~/.bashrc__ or __~/.bash_profile__ depending of your Linux Distro.

```
export KONG_URL=http://kong.example.com:8001
alias deck='docker run --rm -it -e DECK_KONG_ADDR=${KONG_URL} --network host -v /etc/ssl/certs/ca-certificates.crt/ca-bundle.pem:/etc/ssl/certs/ca-certificates.crt -v $(pwd):/tmp --workdir=/tmp kong/deck:latest --headers "Authorization: basic YourSuperUserAndSecretBase64Hash="'
```
