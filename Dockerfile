FROM ubuntu:21.10

WORKDIR /root

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && \
    apt-get install --no-install-recommends -y \
          libguestfs-tools \
          qemu-utils \
          linux-image-generic \
          python3 \
          python3-pip \
          zip \
          unzip

RUN pip3 install j2cli

COPY install.sh /root/install.sh

CMD ./install.sh
