# Benchmarking Disks I/O Performance with FIO

"Fio was written by Jens Axboe <axboe@kernel.dk> to enable flexible testing of the Linux I/O subsystem and schedulers."

Read More on FIO official documentation page:

[FIO - Flexible I/O tester](https://fio.readthedocs.io/en/latest/fio_doc.html)

## Installing FIO

FIO is available is most moderns Linux Distribution and can be installed easily with package managers.

- Debian/Ubuntu

```bash
sudo apt update && sudo apt-get install fio
```

- Rocky/Fedora/RedHat

```bash
sudo dnf install fio
```

- OpenSUSE

```bash
sudo zypper refresh && zypper in fio
```

- ArchLinux

```bash
sudo pacman -Syu fio
```

- Docker Container

A recent version of FIO can be used with docker building an image from any common Linux Docker image. For example, from debian unstable:

```bash
cd /tmp/

echo 'FROM debian:unstable

RUN apt-get update && apt-get -y install fio' | tee Dockerfile
```

Build the image:

```bash
docker build -t docker-fio .
```

Run any fio commands, for example:

```bash
docker run -it --rm -v $(pwd):/bench --workdir=/bench docker-fio fio --version
```

Create a temporary alias to use the container as "fio".

```bash
alias fio='docker run -it --rm -v $(pwd):/bench --workdir=/bench docker-fio fio'
```

## Warning!

The following FIO commands are intended to be executed in the mount directory of disk to be measured. FIO will create the number of large files needed to execute IO requests. For exemple, if **--numjobs=1** and **--filesize=10G** is defined so **one file** with **10Gb** will be created. If **--numjobs=4** so **four files** of **10Gb** will be created.

So, take care where FIO commands will be executed to prevend space exausting on the system.

## Performing Random IOs tests

Random IOs simulate a more distributed I/O requests common in enterprise enviroments that performs small and large IOs on different volumes or areas of SAN arrays, like in large database systems, Virtual Machines enviroments, etc.

This kind of Random IO stress is less common on domestic computers so much less performance are expected from this kind of NVME/SSD devices compared with high end or enterprise devices.

### Random Small (IOPS stress focused)

Read:

```
fio --name=fio \
--filesize=4G \
--time_based \
--runtime=30 \
--ioengine=libaio \
--sync=0 \
--direct=1 \
--bs=4k \
--iodepth=64 \
--rw=randread \
--numjobs=1 \
--group_reporting
```

Write:

```
fio --name=fio \
--filesize=4G \
--time_based \
--runtime=30 \
--ioengine=libaio \
--sync=0 \
--direct=1 \
--bs=4k \
--iodepth=64 \
--rw=randwrite \
--numjobs=1 \
--group_reporting
```

### Random Large (Throughput focused)

Read:

```
fio --name=fio \
--filesize=4G \
--time_based \
--runtime=30 \
--ioengine=libaio \
--sync=0 \
--direct=1 \
--bs=128k \
--iodepth=64 \
--rw=randread \
--numjobs=1 \
--group_reporting
```

Write:

```
fio --name=fio \
--filesize=4G \
--time_based \
--runtime=30 \
--ioengine=libaio \
--sync=0 \
--direct=1 \
--bs=128k \
--iodepth=32 \
--rw=randwrite \
--numjobs=1 \
--group_reporting
```

### Sequential Small (IOPS stress focused)

Read:

```
fio --name=fio \
--filesize=4G \
--time_based \
--runtime=30 \
--ioengine=libaio \
--sync=0 \
--direct=1 \
--bs=4k \
--iodepth=64 \
--rw=read \
--numjobs=1 \
--group_reporting
```

Write:

```
fio --name=fio \
--filesize=4G \
--time_based \
--runtime=30 \
--ioengine=libaio \
--sync=0 \
--direct=1 \
--bs=4k \
--iodepth=64 \
--rw=write \
--numjobs=1 \
--group_reporting
```

### Sequential Large (Throughput focused)

Read:

```
fio --name=fio \
--filesize=4G \
--time_based \
--runtime=30 \
--ioengine=libaio \
--sync=0 \
--direct=1 \
--bs=128k \
--iodepth=64 \
--rw=read \
--numjobs=1 \
--group_reporting
```

Write:

```
fio --name=fio \
--filesize=4G \
--time_based \
--runtime=30 \
--ioengine=libaio \
--sync=0 \
--direct=1 \
--bs=128k \
--iodepth=32 \
--rw=write \
--numjobs=1 \
--group_reporting
```