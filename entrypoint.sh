#!/bin/bash -u

if [[ ${VERBOSE:-} == true ]]; then
    set -x
fi

if [[ "${USER:-}" ]]; then
    # Rename the container user to the host user
    sed -i s/^root/"${USER}"/ /etc/passwd
fi

# Execute cmd as root but with name $USER
"$@"
