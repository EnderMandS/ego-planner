FROM ros:noetic-ros-base-focal

ENV DEBIAN_FRONTEND=noninteractive
ENV ROS_DISTRO noetic
ARG USERNAME=m
ARG PROJECT_NAME=ego_planner

# install binary
RUN apt update && \
    apt install -y vim tree wget curl git rename unzip ninja-build && \
    apt install -y libeigen3-dev && \
    apt install -y libarmadillo-dev && \
    apt install -y ros-${ROS_DISTRO}-pcl-conversions ros-${ROS_DISTRO}-tf && \
    rm -rf /var/lib/apt/lists/*

# setup user
ARG USER_UID=1000
ARG USER_GID=$USER_UID
RUN groupadd --gid $USER_GID $USERNAME \
    && useradd --uid $USER_UID --gid $USER_GID -m $USERNAME \
    && echo $USERNAME ALL=\(root\) NOPASSWD:ALL > /etc/sudoers.d/$USERNAME \
    && chmod 0440 /etc/sudoers.d/$USERNAME
USER $USERNAME

# zsh
RUN sh -c "$(wget -O- https://github.com/deluan/zsh-in-docker/releases/download/v1.1.5/zsh-in-docker.sh)" -- \
    -t robbyrussell  \ 
    -p git \
    -p https://github.com/zsh-users/zsh-autosuggestions \
    -p https://github.com/zsh-users/zsh-syntax-highlighting && \
    sudo rm -rf /var/lib/apt/lists/*

# OpenCV
WORKDIR /home/$USERNAME/pkg/OpenCV
RUN wget -O opencv.zip https://github.com/opencv/opencv/archive/4.x.zip && \
    unzip opencv.zip && rm opencv.zip && mkdir -p build && cd build && \
    cmake -GNinja ../opencv-4.x && ninja && sudo ninja install && ninja clean && \
    sudo rm -rf /home/$USERNAME/pkg
RUN sudo apt update && \
    sudo apt install -y ros-${ROS_DISTRO}-cv-bridge && \
    sudo rm -rf /var/lib/apt/lists/*

# compile project
WORKDIR /home/$USERNAME/code/ros_ws
COPY . /home/$USERNAME/code/ros_ws/src/${PROJECT_NAME}
COPY .vscode /home/$USERNAME/code/ros_ws/
RUN sudo chmod 777 -R /home/$USERNAME/code && \
    . /opt/ros/${ROS_DISTRO}/setup.sh && \
    catkin_make -DCATKIN_WHITELIST_PACKAGES="" -DCMAKE_BUILD_TYPE=Release && \
    echo "source /home/${USERNAME}/code/ros_ws/devel/setup.zsh" >> /home/${USERNAME}/.zshrc

ENTRYPOINT [ "/bin/zsh" ]
# ENTRYPOINT [ "/home/$USERNAME/code/ros_ws/src/${PROJECT_NAME}/setup.zsh" ]
