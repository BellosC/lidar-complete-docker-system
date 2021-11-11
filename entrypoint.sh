#!/bin/bash

source /home/ros/catkin_ws/devel/setup.sh
rosbag record -a -O "/root/shared_dir/${BAGNAME}.bag" &
roslaunch livox_ros_driver livox_lidar_msg.launch 
chmod a+rw "/root/shared_dir/${BAGNAME}.bag"

source /home/ros/catkin_ws/devel/setup.sh
roslaunch lio_livox horizon.launch BagName:="${BAGNAME}.bag" IMU:=${IMU} & 
rosbag play "/root/shared_dir/${BAGNAME}.bag" & 
rosbag record /livox_full_cloud -O "/root/shared_dir/${BAGNAME}_slammed.bag" 
chmod a+rw "/root/shared_dir/${BAGNAME}_slammed.bag"
#sudo chown -R $USER:$USER "/root/shared_dir/${BAGNAME}_slammed.bag"
PCD_FOLDER="/root/shared_dir/${BAGNAME}_pcd"
mkdir -p ${PCD_FOLDER}
roscore &
sleep 5
rosrun pcl_ros pointcloud_to_pcd input:=/livox_full_cloud _prefix:=${PCD_FOLDER}/ &
rosbag play "/root/shared_dir/${BAGNAME}_slammed.bag" 
chmod a+rw -R ${PCD_FOLDER}
#sudo chown -R $USER:$USER ${PCD_FOLDER}
