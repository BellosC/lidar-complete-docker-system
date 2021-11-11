#!/bin/bash

echo "Launching one_docker_to_rule_them_all:latest"

mkdir -p ${HOME}/shared_dir

docker run \
    -it \
    --rm \
    --volume=$HOME/shared_dir:/root/shared_dir:rw \
    --net=host \
    --env BAGNAME="${1:-lidar-bag}" \
    --env IMU="${2:-0}" \
    --ipc host \
    -e DISPLAY --volume /tmp/.X11-unix:/tmp/.X11-unix --volume /dev:/dev --privileged fca645b2fb4b
    #  vietanhdev/lio_livox:ros-kinetic-lio-1.0  

    

if command -v pcl_viewer >/dev/null; then
    pcl_viewer $HOME/shared_dir/${1:-lidar-bag}_pcd/*
else
    echo "pcl_viewer not found. Install with \`sudo apt-get install pcl-tools\`."
fi
