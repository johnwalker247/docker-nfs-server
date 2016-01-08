FROM ubuntu
ENV DEBIAN_FRONTEND noninteractive
RUN apt-get update -qq && apt-get install -y nfs-kernel-server rpcbind nfs-common runit inotify-tools -qq
RUN mkdir -p /exports

RUN mkdir -p /etc/sv/nfs
ADD nfs.init /etc/sv/nfs/run
ADD nfs.stop /etc/sv/nfs/finish

ADD nfs_setup.sh /usr/local/bin/nfs_setup

VOLUME /exports

EXPOSE 111/udp 111/tcp 2049/udp 2049/tcp 32767/udp 32767/tcp

RUN sed -i -e 's/^RPCMOUNTDOPTS="--manage-gids"$/RPCMOUNTDOPTS="--manage-gids --port 32767 --no-nfs-version 4"/' /etc/default/nfs-kernel-server

ENTRYPOINT ["/usr/local/bin/nfs_setup"]
