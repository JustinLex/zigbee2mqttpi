# zigbee2mqttpi

The way we modify the raspberry pi image without needing root is with a docker/podman container that uses libguestfs
to mount the image and copy in our files.

The docker/podman container is based off of Uwe Dauernheim's [docker-guestfs](https://github.com/djui/docker-guestfs) image.

### Sample command to get a guestfish shell with the raspi image inside docker

```
podman run --rm -it -v "$PWD"/2022-01-28-raspios-bullseye-arm64-lite.img:/2022-01-28-raspios-bullseye-arm64-lite.img djui/guestfs --ro -i -a 2022-01-28-raspios-bullseye-arm64-lite.img
```

Make sure to mount the image with the :Z flag if you're using SELinux, or you'll get cryptic errors.
