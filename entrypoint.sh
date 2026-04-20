#!/bin/bash
source ~/.bashrc

export DEBUG=${DEBUG:-false}
export SSH_KEY_PATH=${SSH_KEY_PATH}
export LOAD_SSH_KEY=${LOAD_SSH_KEY:-false}


# SSH KEY
echo "DEBUG=${DEBUG}, LOAD_SSH_KEY=${LOAD_SSH_KEY}, SSH_KEY_PATH=${SSH_KEY_PATH}"
if [ "${LOAD_SSH_KEY}" == 'true' ] && [ -f "${SSH_KEY_PATH}" ];then
    echo "Starting agent"
    eval "$(ssh-agent -s)"
    echo "Adding key"
    ssh-add "${SSH_KEY_PATH}"
fi

# True entry
echo "Entering bash"
/bin/bash
