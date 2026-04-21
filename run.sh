#!/bin/bash

# Arguments
while (( "$#" )); do
    case "$1" in
        -i|--image) image=$2;shift;;
        -t|--tag) tag=$2;shift;;
        -n|--name) name=$2;shift;;
        -e|--env) env=$2;shift;;
        -u|--uid) uid=$2;shift;;
        -g|--gid) gid=$2;shift;;
    esac
    shift
done

# Default values
if [ -z "${image}" ];then image="${IMAGE:-proxmox-kube-deployer}";fi
if [ -z "${tag}" ];then
    tag="$(docker images --format table|grep $image|head -n 1|awk '{print $2}')"
    echo "No tag provided and found: '${tag}'"
fi
if [ -z "${name}" ];then name=${image};fi
if [ -z "${env}" ];then
    env='./dev.env'
    echo "Environment file not provided with -e, so using '${env}'"
fi
if [ -z "${uid}" ];then uid="${USERID:-1000}";fi
if [ -z "${gid}" ];then gid="${GROUPID:-$uid}";fi

# Execute Docker Run
echo "Starting container image: '${image}:${tag}' with env: '${env}'"
echo ''
set -x
docker run --rm -it \
    --name ${name} \
    --user "${uid}:${gid}" \
    --net=host \
    --volume ./ansible:/usr/local/app/ansible \
    --volume ./ansible/.secret:/usr/local/app/.secret \
    --volume ./ansible/.key:/usr/local/app/.key \
    --volume ./terraform:/usr/local/app/terraform \
    --volume ~/.ssh/:/usr/local/app/.ssh/ \
    --env-file ${env} \
    ${image}:${tag}
