#!/bin/bash
image=proxmox-kube-deployer
build=FALSE

# Arguments
while (( "$#" )); do
    case "$1" in
        -t|--tag) tag=$2;shift;;
        -n|--name) name=$2;shift;;
        -e|--env) env=$2;shift;;
        -u|--uid) uid=$2;shift;;
        -g|--gid) gid=$2;shift;;
        -b|--build) build=TRUE;;
    esac
    shift
done

# Check if image exists
if [ $(docker images --format 'table'|grep -c ${image}) -lt 1 ];then
    read -p "$image image is missing. Would you like to build? <Y|n>" bld
    case $bld in
        [nN]* ) echo 'Exiting script...';exit 0;;
        *) echo 'Building image...';build=TRUE;;
    esac
fi
if [ "${build}" == "TRUE" ];then
    cd ./Docker/
    docker build -t ${image}:v$(date -I) .
    if [ $? == 1 ];then
        echo 'Something went wrong with docker build command! Exiting...'
        exit 1
    fi
    cd ../
fi

# Default values
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
