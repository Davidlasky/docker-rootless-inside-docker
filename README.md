# Docker-rootless-in-Docker
This repo is specifically made for Corp APT mirror maintainers whose companies are mainly using Docker.io or Docker-ce on Ubuntu 20.04(LTS). The Dockerfile is written for testing PRODUCTION environment and the least amount of dependencies of Docker Rootless only.

( ゜- ゜)つロ Cheers~

## Intro 
Security needed to be a top priority! 

### Why Docker Rootless? 
Since one of the biggest security issues with Docker is that, its daemon runs as a root user. The main concern when running any program as the root user lies in potential vulnerabilities. If a vulnerability is found in the software run by root, the attacker has instant access to the entire system. Thankfully Docker introduced Docker rootless mode. The Rootless mode allows users to run the Docker daemon and containers as a non-root user. This mitigates the potential vulnerabilities in the daemon and the container runtime. As long as the prerequisites are met, rootless mode does not require root privileges even during the installation of the Docker daemon. 

## Solution
Docker rootless is preferred right now as it's easy to install(whether Docker-ce is installed or not), easy to configure for individual users, and zero learning cost for developers. It can serve as a temporary transition solution until Podman gets updated on Ubuntu(hopefullly :) ) 

### Build Image
```
docker build -t myimage .
```

### Run
add " -v " to mount directories into the containers as needed
```
docker run --privileged --rm -it --security-opt seccomp=unconfined --security-opt apparmor=unconfined -it myimage
```

### Entrypoint
The entrypoint.sh file is made specifically for rootless containers such as podman and docker rootless mode, where the default user in the container is root with id 0. In production environment, we need to mount files and directories into the container, which by default are all owned by root:root(USER:GROUP). We need to change the USER to the real user name to have correct access to the moutned files and directories,  pretending we are the user, yet we ARE STILL root. 

It's worth noting that even though our user name is changed to the real user name on the host machine, our id is still 0, so from the container's perspective of view, we're still root with UID and GID 0. This id issue may cause some troubles. Watch out for apps and verifications that read user id UID.

### Start Docker
Once we are in the container, run the following command to run the docker daemon and start the service.
```
dockerd-rootless.sh --experimental --storage-driver fuse-overlayfs&
```
