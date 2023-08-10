#!/bin/bash -u

if [[ ${VERBOSE:-} == true ]]; then
    set -x
fi

if [[ "${USER:-}" ]]; then
    # Rename the container user to the host user
    sed -i s/^root/"${USER}"/ /etc/passwd
    export HOME=/home/"${USER}"
    # change ENV Var as desired

    # if ssh is used to perform git operations, then we should copy the mounted .ssh dir under root's folder, and change appropriate permission.
    #This is because our id is 0(root), so ssh can't find corresponding UID for the USER, then it'll use the one under root.
    cp -r $HOME/.ssh /root/.ssh
    chmod 0600 /root/.ssh/*
fi

# Execute cmd as root but with name $USER
"$@"
