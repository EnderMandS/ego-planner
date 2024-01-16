FROM endermands/ros_noetic_zsh:opencv

ENV DEBIAN_FRONTEND=noninteractive
ENV ROS_DISTRO noetic
ARG USERNAME=m
ARG PROJECT_NAME=ego-planner

# install binary
RUN apt update && \
    # apt install -y vim tree wget curl git unzip ninja-build && \ 
    # apt install -y libeigen3-dev && \
    apt install -y libarmadillo-dev && \
    apt install -y ros-${ROS_DISTRO}-pcl-conversions ros-${ROS_DISTRO}-pcl-ros ros-${ROS_DISTRO}-tf && \
    rm -rf /var/lib/apt/lists/*

# compile project
WORKDIR /home/$USERNAME/code/ros_ws/src
RUN git clone --depth 1 https://github.com/EnderMandS/ego-planner.git && \
    sudo cp -r /home/$USERNAME/code/ros_ws/src/${PROJECT_NAME}/.vscode/ /home/${USERNAME}/code/ros_ws && \
    sudo chmod 777 -R /home/$USERNAME/code && \
    . /opt/ros/${ROS_DISTRO}/setup.sh && \
    catkin_make -DCATKIN_WHITELIST_PACKAGES="" -DCMAKE_BUILD_TYPE=Release && \
    echo "source /home/${USERNAME}/code/ros_ws/devel/setup.zsh" >> /home/${USERNAME}/.zshrc

ENTRYPOINT [ "/bin/zsh" ]
# ENTRYPOINT [ "/home/${USERNAME}/code/ros_ws/src/${PROJECT_NAME}/setup.zsh" ]
