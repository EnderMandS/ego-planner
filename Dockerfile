FROM ros:noetic-ros-base-focal

ENV DEBIAN_FRONTEND=noninteractive
ENV ROS_DISTRO noetic
ARG USERNAME=m
ARG PROJECT_NAME=ego_planner

# install binary
RUN apt update && \
    apt install -y vim tree wget curl git rename && \
    apt install -y libarmadillo-dev && \
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

# compile project
COPY . /home/$USERNAME/code/${PROJECT_NAME}
RUN sudo chmod 777 /home/$USERNAME/code/${PROJECT_NAME}
WORKDIR /home/$USERNAME/code/${PROJECT_NAME}
RUN . /opt/ros/${ROS_DISTRO}/setup.sh && \
    catkin_make -DCATKIN_WHITELIST_PACKAGES="" -DCMAKE_BUILD_TYPE=Release

ENTRYPOINT [ "/bin/zsh" ]
# ENTRYPOINT [ "/home/$USERNAME/code/${PROJECT_NAME}/setup.zsh" ]
