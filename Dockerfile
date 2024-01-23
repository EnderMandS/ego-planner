FROM endermands/ros_noetic_zsh:opencv

ENV DEBIAN_FRONTEND=noninteractive
ENV ROS_DISTRO noetic
ARG USERNAME=m
ARG PROJECT_NAME=ego-planner

# install binary
RUN sudo apt update && \
    sudo apt install -y libarmadillo-dev && \
    sudo apt install -y ros-${ROS_DISTRO}-pcl-conversions ros-${ROS_DISTRO}-pcl-ros ros-${ROS_DISTRO}-pcl-msgs && \
    sudo apt install -y ros-${ROS_DISTRO}-tf ros-${ROS_DISTRO}-tf2 ros-${ROS_DISTRO}-laser-geometry && \
    sudo apt install -y ros-${ROS_DISTRO}-rviz && \
    sudo rm -rf /var/lib/apt/lists/*

# compile project
WORKDIR /home/$USERNAME/code
RUN git clone --depth 1 https://github.com/EnderMandS/ego-planner.git ros_ws && cd ros_ws && \
    sudo chmod 777 -R /home/$USERNAME/code && . /opt/ros/${ROS_DISTRO}/setup.sh && \
    catkin_make -DCATKIN_WHITELIST_PACKAGES="" -DCMAKE_BUILD_TYPE=Release && \
    echo "source /home/m/code/ros_ws/devel/setup.zsh" >> /home/${USERNAME}/.zshrc

WORKDIR /home/$USERNAME/code/ros_ws/src/planner/plan_manage/launch

# ENTRYPOINT [ "/bin/zsh" ]
ENTRYPOINT [ "/home/m/code/ros_ws/setup.zsh" ]
