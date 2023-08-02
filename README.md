# Docker-rootless-in-Docker
This repo is specifically made for Corp APT mirror maintainers whose companies are mainly using Docker.io or Docker-ce on Ubuntu 20.04(LTS). The Dockerfile is written for testing production environment and the least amount of dependencies of Docker Rootless only.

( ゜- ゜)つロ Cheers~

## Intro 
Security needed to be a top priority! 

### Why Docker Rootless? 
Since one of the biggest security issues with Docker is that, its daemon runs as a root user. The main concern when running any program as the root user lies in potential vulnerabilities. If a vulnerability is found in the software run by root, the attacker has instant access to the entire system. Thankfully Docker introduced Docker rootless mode. The Rootless mode allows users to run the Docker daemon and containers as a non-root user. This mitigates the potential vulnerabilities in the daemon and the container runtime. As long as the prerequisites are met, rootless mode does not require root privileges even during the installation of the Docker daemon. 

### What about Podman?
Personally I'd recommend Podman over Docker and Docker Rootless. Podman follows the OCI standard and has been designed since its inception to be a close replacement to Docker. It runs rootlessly by design. though the only confusing piece of this is that a Podman container running as a non-root user will run within the user namespace. Also, one of the primary "selling" points of Podman is the fact that it runs "daemonless". To the average user this likely means very little, but from a security standpoint it means a LOT.  

However, updates of Podman is falling far behind on Ubuntu. Only Ubuntu 20.10 and above have it included in the apt packages, and it's version 3.4.4, while the latest is 4.5.X. Most companies still use Ubuntu 18.04 and 20.04 for production, and downloading Podman 3.4.2 from Kubic repo is NOT recommended for production use. 

Manual compilation of latest Podman is doable and fully functioning on Ubuntu 20.04, but HIGHLY NOT recommended! It took me three days to deal with weird compilation errors, installation of various dependencies,and package conflicts :(  

## Solution
Docker rootless is preferred right now as it's easy to install(whether Docker-ce is installed or not), easy to configure for individual users, and zero learning cost for developers. It can serve as a temporary transition solution until Podman gets updated on Ubuntu(hopefullly :) ) 

### Build Image
```
docker build -t myimage .
```

### Run
```
docker run --privileged --rm -it --security-opt seccomp=unconfined --security-opt apparmor=unconfined -it myimage
```

### Start Docker
Once we are in the container, run 
```
dockerd-rootless.sh --experimental --storage-driver fuse-overlayfs&
```
