#!/bin/bash

TMP_WORKSPACE_SRC="/.tmp/workspace/src"
DEPENDENCY_WORKSPACE_SRC="/opt/dependency_workspace/src"

import_dependencies() {
    local directory=$1
    
    # Clone the dependencies for each source repository
    for repo in $(ls $directory); do
        if [ -f "${directory}/${repo}/dependencies.rosinstall" ]; then
            rosinstall ${DEPENDENCY_WORKSPACE_SRC} "${directory}/${repo}/dependencies.rosinstall"
        fi
    done

    # Output the number of dependencies installed (number of directories)
    return $(ls -l ${DEPENDENCY_WORKSPACE_SRC} | grep -c ^d)
}

main() {
    # Create the directories
    mkdir -p ${DEPENDENCY_WORKSPACE_SRC}
    mkdir -p ${TMP_WORKSPACE_SRC}

    # Source ROS
    source /opt/ros/noetic/setup.bash
    
    # Import the source repositories
    cd ${TMP_WORKSPACE_SRC} || exit 1
    vcs import < "/.config/packages.repos"

    # Clone dependencies until the number of dependencies is the same as the previous iteration 
    num_dependencies_prev=0
    num_dependencies=$(import_dependencies ${TMP_WORKSPACE_SRC})
    while (( num_dependencies!= num_dependencies_prev )); do
        num_dependencies_prev=${num_dependencies}
        num_dependencies=$(import_dependencies ${DEPENDENCY_WORKSPACE_SRC})
    done

    # Install dependencies for all imported repositories
    cd ${TMP_WORKSPACE_SRC} || exit 1
    rosdep update
    rosdep install --from-paths ${TMP_WORKSPACE_SRC} ${DEPENDENCY_WORKSPACE_SRC} --ignore-src -y

    # Build the dependency workspace
    cd ${DEPENDENCY_WORKSPACE_SRC}/.. || exit 1
    catkin config --init --install -DPYTHON_EXECUTABLE=/usr/bin/python3
    catkin build
}

main
