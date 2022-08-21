# zigbee2mqttpi

The way we modify the raspberry pi image without needing root is with a docker/podman container that uses libguestfs
to mount the image and copy in our files.

The docker/podman container is based off of Uwe Dauernheim's [docker-guestfs](https://github.com/djui/docker-guestfs) image.

### How to run

```commandline
podman build -t z2mpi .
podman run -v $PWD:/root/src:Z --rm z2mpi:latest
```

### Sample command to get a guestfish shell with the raspi image inside docker

```
podman run --rm -it -v $PWD:/mnt:Z guestfs --format=raw -a /mnt/2022-01-28-raspios-bullseye-arm64-lite.img -m /dev/sda2 -v
```

Make sure to mount the image with the :Z flag if you're using SELinux, or you'll get cryptic errors.
