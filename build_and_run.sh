#!/bin/bash
docker build -t myimage .
docker run --privileged --rm -it --security-opt seccomp=unconfined --security-opt apparmor=unconfined myimage
