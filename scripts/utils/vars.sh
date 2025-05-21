#!/bin/bash

# Source the configuration variables
source "$(realpath "$(dirname "${BASH_SOURCE[0]}")")/../../config/config.sh"

# Type of the local hardware (amd64, jetson, arm64)
HARDWARE_TYPE="amd64"

# Get the project folder
PROJECT_DIR=$(realpath "$(dirname "${BASH_SOURCE[0]}")/../..")

# Important paths
ENV_DIR=$(realpath "$PROJECT_DIR/env")
LOGS_DIR=$(realpath "$PROJECT_DIR/logs")
BUILD_DIR=$(realpath "$PROJECT_DIR/build")
CONFIG_DIR=$(realpath "$PROJECT_DIR/config")
IMAGES_DIR=$(realpath "$PROJECT_DIR/images")
SCRIPTS_DIR=$(realpath "$PROJECT_DIR/scripts")
OVERLAYS_DIR=$(realpath "$PROJECT_DIR/overlays")
COMMANDS_DIR=$(realpath "$PROJECT_DIR/commands")
WORKSPACE_DIR=$(realpath "$PROJECT_DIR/workspace")

# Important files
IMAGE_FILE_NAME="${IMAGE_NAME}_${HARDWARE_TYPE}.simg"
METADATA_FILE_NAME="${IMAGE_NAME}_${HARDWARE_TYPE}.json"

IMAGE_FILE="${IMAGES_DIR}/${IMAGE_FILE_NAME}"
METADATA_FILE="${IMAGES_DIR}/${METADATA_FILE_NAME}"
REMOTE_IMAGE_FILE="${REMOTE_IMAGES_PATH}/${IMAGE_FILE_NAME}"
REMOTE_METADATA_FILE="${REMOTE_IMAGES_PATH}/${METADATA_FILE_NAME}"

BUILD_LOG_FILE="${LOGS_DIR}/${IMAGE_NAME}.log"
DEFINITION_FILE="${BUILD_DIR}/${HARDWARE_TYPE}.def"
WORKSPACE_SETUP_FILE="${WORKSPACE_DIR}/devel/setup.bash"

# Remote server
REMOTE_USERNAME="${REMOTE_USERNAME:-$(whoami)}"
SSH_PASSWORD=""

# Overlays
OVERLAY_ARG=""
OVERLAY_IMAGE_FILE=""

# Debugging
DEBUG_MODE=false

if tput setaf 1 &>/dev/null; then
    tput sgr0 # reset colors
    BOLD=$(tput bold)
    RESET="${BOLD}$(tput sgr0)"
    # Solarized colors, taken from http://git.io/solarized-colors.
    BLACK="${BOLD}$(tput setaf 0)"
    BLUE="${BOLD}$(tput setaf 33)"
    CYAN="${BOLD}$(tput setaf 37)"
    GREEN="${BOLD}$(tput setaf 64)"
    ORANGE="${BOLD}$(tput setaf 166)"
    PURPLE="${BOLD}$(tput setaf 125)"
    RED="${BOLD}$(tput setaf 124)"
    VIOLET="${BOLD}$(tput setaf 61)"
    WHITE="${BOLD}$(tput setaf 15)"
    YELLOW="${BOLD}$(tput setaf 136)"
    PINK="${BOLD}$(tput setaf 169)"
else
    BOLD=''
    RESET="\e[0m"
    BLACK="\e[1;30m"
    BLUE="\e[1;34m"
    CYAN="\e[1;36m"
    GREEN="\e[1;32m"
    ORANGE="\e[1;33m"
    PURPLE="\e[1;35m"
    RED="\e[1;31m"
    VIOLET="\e[1;35m"
    WHITE="\e[1;37m"
    YELLOW="\e[1;33m"
    PINK="\e[1;95m"
fi
