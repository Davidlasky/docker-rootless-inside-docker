#This dockerfile is for testing build environment and the LEAST amount of dependencies of Docker Rootless only
#In short, this is Docker in Docker, which has quite a few limitations.

# To run the image, use the following command:
# docker run --privileged --rm --security-opt seccomp=unconfined --security-opt apparmor=unconfined -it myimage

FROM ubuntu:20.04
#Replace ubuntu version with custom image if needed

#change the IP address of following proxies to your server's IP, or use the docker0 IP address(run ifconfig to show) if cntlm is not configured
#Uncomment out if needed
#ENV http_proxy http://YOUR-DOCKER-IP-ADDRESS:3128
#ENV https_proxy http://YOUR-DOCKER-IP-ADDRESS:3128

RUN apt update \
     && apt upgrade -y \
     && DEBIAN_FRONTEND=noninteractive apt install -y systemd \
     curl \
     # dbus and uidmap are prequisites for rootless docker installed on servers according to the official website, but dbus won't work in the container
     # see https://docs.docker.com/engine/security/rootless/#prerequisites
     dbus-user-session \
     uidmap \
     #the four packages below are required to run dockerd-rootless.sh
     iptables \
     kmod \
     libcap2-bin \
     iproute2 \
     #we prefer to use fuse-overlayfs as storage driver in the container since the default overlay2 is not working in DinD(docker in docker) mode.
     fuse-overlayfs

ENV USER john
ENV UID 1000
ENV GID 1000
ENV HOME /home/$USER
ENV PATH=$HOME/bin:$PATH

RUN groupadd -g $UID $USER
RUN groupadd docker
RUN useradd --no-log-init -s /bin/bash -g $GID -u $UID -o -c "container user" --create-home $USER
RUN echo "ALL ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers

USER $USER
WORKDIR $HOME

RUN curl -fsSL https://get.docker.com/rootless | sh

#On a non-systemd host, you need to set the XDG_RUNTIME_DIR environment variable.
#On a systemd host, log into the host using pam_systemd (ssh is preferred). The value is AUTOMATICALLY set to /run/user/$UID and cleaned up on every logout.
ENV XDG_RUNTIME_DIR=$HOME/.docker/

#On the server, we should use systemd to start dockerd-rootless.sh, but it is not working in the container.
#Please refer to https://docs.docker.com/engine/security/rootless/#daemon

#So we run the following command to start dockerd-rootless.sh with fuse-overlayfs as our preferred storage driver when we are in the container.

#dockerd-rootless.sh --experimental --storage-driver fuse-overlayfs&
