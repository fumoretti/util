# ansible containers

Simple Dockerfiles to build test ansible client containers.

## ansible-core 2.10

```bash
docker build -t ansible-2.10 -f Dockerfile.2.10 .
```

## ansible-core 2.16

```bash
docker build -t ansible-2.16 -f Dockerfile.2.16 .
```

## ansible-core latest (almost)

```bash
docker build -t ansible:latest -f Dockerfile.latest .
```

## Docker run

```bash
cd /your/playbooks/directory

docker run --rm -it -v $(pwd):/home/ansible ansible:latest
```
