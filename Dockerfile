#FROM ros:kinetic-ros-core
FROM althack/ros:kinetic-full
ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y cmake git
RUN apt-get update && apt-get install -y libpcl-dev libsuitesparse-dev
RUN apt-get update && apt-get install -y ros-kinetic-tf ros-kinetic-pcl-ros
RUN rm -rf /var/lib/apt/lists/*

RUN apt-get update && apt-get install -y git vim nano wget unzip build-essential cmake \
libgoogle-glog-dev libboost-all-dev protobuf-compiler libatlas-base-dev  \
libsuitesparse-dev ros-kinetic-pcl-ros 

# Install Eigen 3.3.4 - Must be done for Ubuntu 16.04
RUN wget http://mirrors.kernel.org/ubuntu/pool/universe/e/eigen3/libeigen3-dev_3.3.4-4_all.deb -O /tmp/libeigen3-dev_3.3.4-4_all.deb
RUN dpkg -i /tmp/libeigen3-dev_3.3.4-4_all.deb
RUN rm /tmp/libeigen3-dev_3.3.4-4_all.deb

# Install Ceres
RUN cd /tmp && git clone --depth=1 -b 1.14.0 https://ceres-solver.googlesource.com/ceres-solver
RUN cd /tmp/ceres-solver && cmake . && make -j$(nproc) && make install
RUN rm -rf /tmp/ceres-solver

# Prepare workspace for livox driver and LIO-Livox
# Add commands to clone other repos
RUN mkdir -p /home/ros/catkin_ws/src
RUN cd /home/ros/catkin_ws/src && git clone --depth=1 https://github.com/Livox-SDK/Livox-SDK.git
RUN cd /home/ros/catkin_ws/src && git clone https://github.com/Livox-SDK/livox_ros_driver
RUN cd /home/ros/catkin_ws/src && git clone https://github.com/Livox-SDK/LIO-Livox

# Specify Eigen version 3.3 - Must be done for Ubuntu 16.04
RUN sed -i 's/Eigen3\sREQUIRED/Eigen3 3.3 REQUIRED/g' /home/ros/catkin_ws/src/LIO-Livox/CMakeLists.txt

WORKDIR /home/ros/catkin_ws/src/Livox-SDK/build

RUN cmake .. && make -j"$(($(nproc)+1))" && make install -j"$(($(nproc)+1))"

# Build the workspace
RUN cd /home/ros/catkin_ws && catkin_make


# # Set up auto-source of workspace for ros user
RUN echo "source /home/ros/catkin_ws/devel/setup.bash" >> /root/.bashrc
WORKDIR "/home/ros/catkin_ws/"

# #RUN /bin/bash -c '. /opt/ros/kinetic/setup.bash; cd /ws_livox; catkin_make -j"$(($(nproc)+1))"'

COPY entrypoint.sh /

COPY livox_lidar.launch /home/ros/catkin_ws/src/Livox-SDK/livox_ros_driver/launch/livox_lidar.launch

WORKDIR /

ENV BAGNAME lidar-bag
ENV IMU 0

ENTRYPOINT [ "./entrypoint.sh" ]

