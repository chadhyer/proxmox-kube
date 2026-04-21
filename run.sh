#!/bin/bash
image='proxmox-kube-deployer'
tag=$1
if [ "${tag}" == '' ];then
    tag="$(docker images --format table|grep $image|head -n 1|awk '{print $2}')"
    echo "No tag provided and found: '${tag}'"
fi
docker run --rm -it \
    --name $image-run \
    --user "${USERID:-1000}:${GROUPID:-$USERID}" \
    --net=host \
    --volume ./ansible:/usr/local/app/ansible \
    --volume ./ansible/.secret:/usr/local/app/.secret \
    --volume ./ansible/.key:/usr/local/app/.key \
    --volume ./terraform:/usr/local/app/terraform \
    --volume ~/.ssh/:/usr/local/app/.ssh/ \
    --env-file ./dev.env \
    $image:$tag
