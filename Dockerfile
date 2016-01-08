FROM ubuntu
ENV DEBIAN_FRONTEND noninteractive
RUN apt-get update -qq && apt-get install -y nfs-kernel-server rpcbind nfs-common runit inotify-tools -qq
RUN mkdir -p /exports

RUN mkdir -p /etc/sv/nfs
ADD nfs.init /etc/sv/nfs/run
ADD nfs.stop /etc/sv/nfs/finish

ADD nfs_setup.sh /usr/local/bin/nfs_setup

VOLUME /exports

EXPOSE 111/udp 111/tcp 2049/udp 2049/tcp 32765/udp 32765/tcp 32766/udp 32766/tcp 32767/udp 32767/tcp 32768/udp 32768/tcp

RUN service nfs-kernel-server stop && \
    service statd stop && \
    service idmapd stop && \
    service rpcbind stop && \
    modprobe -r nfsd nfs lockd
RUN echo 'RPCMOUNTDOPTS="--manage-gids --port 32767 --no-nfs-version 4"' > /etc/default/nfs-kernel-server && \
    echo 'NEED_SVCGSSD="no"' >> /etc/default/nfs-kernel-server && \
    echo 'NEED_STATD="yes"' > /etc/default/nfs-common && \
    echo 'STATDOPTS="--port 32765 --outgoing-port 32766"' >> /etc/default/nfs-common && \
    #echo 'NEED_IDMAPD="no"' >> /etc/default/nfs-common && \
    echo 'NEED_GSSD="no"' >> /etc/default/nfs-common && \
    echo "options lockd nlm_udpport=32768 nlm_tcpport=32768" > /etc/modprobe.d/local.conf && \
    echo "# NFS ports" >> /etc/services && \
    echo "rpc.nfsd 2049/tcp # RPC nfsd" >> /etc/services && \
    echo "rpc.nfsd 2049/udp # RPC nfsd" >> /etc/services && \
    echo "rpc.statd-bc 32765/tcp # RPC statd broadcast" >> /etc/services && \
    echo "rpc.statd-bc 32765/udp # RPC statd broadcast" >> /etc/services && \
    echo "rpc.statd 32766/tcp # RPC statd listen" >> /etc/services && \
    echo "rpc.statd 32766/udp # RPC statd listen" >> /etc/services && \
    echo "rpc.mountd 32767/tcp # RPC mountd" >> /etc/services && \
    echo "rpc.mountd 32767/udp # RPC mountd" >> /etc/services && \
    echo "rpc.lockd 32768/tcp # RPC lockd/nlockmgr" >> /etc/services && \
    echo "rpc.lockd 32768/udp # RPC lockd/nlockmgr" >> /etc/services && \
    echo "manual" > /etc/init/idmapd.override

ENTRYPOINT ["/usr/local/bin/nfs_setup"]
