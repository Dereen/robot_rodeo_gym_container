#!/bin/bash

# ============= START: PROJECT SPECIFIC VARIABLES =============

# Project name with lowercase letters and no spaces
PROJECT_NAME="main"

# Remote server variables for storing images
REMOTE_SERVER="login3.rci.cvut.cz"
REMOTE_IMAGES_PATH="/mnt/data/vras/data/robotour2024/images"


# -------- Start: Environment variables --------

# Define the environment variables to be exported to the container
# Variables starting with APPTAINER_ will be exported to the container 
# without the APPTAINER_ prefix
export APPTAINERENV_USER="${USER}"
export APPTAINERENV_DISPLAY="${DISPLAY}"
export APPTAINERENV_XAUTHORITY="${XAUTHORITY}"

# -------- End: Environment variables --------
# -------- Start: Hardware specific paths --------

# Function to build common mount paths dynamically
build_common_mount_paths() {
    local mount_paths=""

    # Bind the X11 socket
    if [ -e "/tmp/.X11-unix" ]; then
        mount_paths+=",/tmp/.X11-unix"
    fi

    # Bind the DRI devices
    if [ -e "/dev/dri" ]; then
        mount_paths+=",/dev/dri"
    fi

    echo "$mount_paths"
}

# Function to build AMD64 specific mount paths dynamically
build_amd64_mount_paths() {
    local mount_paths=""

    # Find the VS Code if it exists
    if [ -d "/usr/share/code" ]; then
        mount_paths+=",/usr/share/code"
        # mount_paths+=",/usr/share/code/bin/code:/usr/bin/code"
    fi

    # Bind snap directories
    mount_paths+=",/snap"

    echo "$mount_paths"
}

# Function to build ARM64 specific paths dynamically
build_arm64_mount_paths() {
    local mount_paths=""

    echo "$mount_paths"
}

# Function to build Jetson specific paths dynamically
build_jetson_mount_paths() {
    local mount_paths="/usr/local/cuda-10.2"

    # Only find and append mount_paths if they exist
    if [ -d "/usr/lib/aarch64-linux-gnu/" ]; then
        mount_paths+=",$(find /usr/lib/aarch64-linux-gnu/ -name 'libcudnn*' -print0 | tr '\0' ',' | sed 's/,$//')"
        mount_paths+=",$(find /usr/lib/aarch64-linux-gnu/ -name 'libcublas*.so*' -print0 | tr '\0' ',' | sed 's/,$//')"
        mount_paths+=",$(find /usr/lib/aarch64-linux-gnu/ -name 'libnv*.so*' -print0 | tr '\0' ',' | sed 's/,$//')"
    fi

    if [ -d "/usr/include/" ]; then
        mount_paths+=",$(find /usr/include/ -name '*cudnn*' -print0 | tr '\0' ',' | sed 's/,$//')"
        mount_paths+=",$(find /usr/include/ -name '*cublas*' -print0 | tr '\0' ',' | sed 's/,$//')"
    fi

    echo "$mount_paths"
}

format_paths() {
    local input_string="$1"

    # Remove leading and trailing commas
    input_string="${input_string#,}"  # Remove leading comma
    input_string="${input_string%,}"  # Remove trailing comma

    # Replace multiple consecutive commas with a single comma
    input_string="$(echo "$input_string" | sed 's/,\+/,/g')"

    echo "$input_string"
}

# Define hardware-specific configurations
declare -A MOUNT_PATHS
MOUNT_PATHS["commnon"]="$(format_paths "$(build_common_mount_paths)")"
MOUNT_PATHS["amd64"]="$(format_paths "$(build_amd64_mount_paths)")"
MOUNT_PATHS["arm64"]="$(format_paths "$(build_arm64_mount_paths)")"
MOUNT_PATHS["jetson"]="$(format_paths "$(build_jetson_mount_paths)")"

# -------- End: Hardware specific bind mount_paths --------

# ============= END: PROJECT SPECIFIC VARIABLES =============