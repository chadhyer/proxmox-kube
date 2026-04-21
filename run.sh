#!/bin/bash
image='proxmox-kube-deployer'

while (( "$#" )); do
    case "$1" in
        -t|--tag) tag=$2;shift;;
        -e|--env) env=$2;shift;;
    esac
    shift
done

if [ -z "${tag}" ];then
    tag="$(docker images --format table|grep $image|head -n 1|awk '{print $2}')"
    echo "No tag provided and found: '${tag}'"
fi
if [ -z "${env}" ];then
    env='./dev.env'
    echo "Environment file not provided with -e, so using '${env}'"
fi
echo "Starting container image: '${image}:${tag}' with env: '${env}'"

docker run --rm -it \
    --name $image-run \
    --user "${USERID:-1000}:${GROUPID:-$USERID}" \
    --net=host \
    --volume ./ansible:/usr/local/app/ansible \
    --volume ./ansible/.secret:/usr/local/app/.secret \
    --volume ./ansible/.key:/usr/local/app/.key \
    --volume ./terraform:/usr/local/app/terraform \
    --volume ~/.ssh/:/usr/local/app/.ssh/ \
    --env-file ${env} \
    $image:$tag
