#!/bin/bash

print_usage() {
    cat <<EOF
Initialize the catkin workspace for the project. This script should
not be run directly. Instead, use the start_singularity.sh script to start the
singularity container and then run this script inside the container.
EOF
}

# ============= START: Source the variables and utility functions =============

# Source the variables and utility functions
source "$(realpath "$(dirname "${BASH_SOURCE[0]}")")/vars.sh"
source "$(realpath "$(dirname "${BASH_SOURCE[0]}")")/functions.sh"

# ============= END: Source the variables and utility functions =============

# TODO: Change the function
init_workspace() {
  info_log "Initializing workspace"

  # Check if the catkin workspace is initialized
  cd "${WORKSPACE_DIR}" || exit 1

  echo "${WORKSPACE_DIR}/src"
	echo "$( ls -A "${WORKSPACE_DIR}/src" )"

  # Check if workspace packges are installed
  if [ -z "$( ls -A "${WORKSPACE_DIR}/src" )" ]; then
		info_log "Installing packages"
    cd "${WORKSPACE_DIR}/src"
    vcs import < "/.config/packages.repos" 
 		cd "${WORKSPACE_DIR}"
	else
		info_log "Packages installed"  
	fi

  if [ ! -d build ] || [ ! -d devel ]; then
    info_log "Initializing the catkin workspace."
    source /opt/ros/noetic/setup.bash
    catkin config --extend /opt/dependency_workspace/install/
    catkin build
  else
    info_log "The catkin workspace is already initialized."
  fi

	echo $PWD
	source ./devel/setup.bash
}

convert_url() {
    local url=$1

    # Check if the URL is a GitHub URL using HTTPS protocol
    if [[ $url =~ ^https://github\.com/(.*)\.git$ ]]; then
        if is_robot; then
            debug_log "Skipping GitHub URL conversion for the robot."
            echo "$url"
        else
            debug_log "Converting GitHub URL to ssh protocol for the local machine."
            echo "git@github.com:${BASH_REMATCH[1]}.git"
        fi
    # Check if the URL is a GitLab URL using shh protocol
    elif [[ $url =~ ^git@gitlab\.fel\.cvut\.cz:(.*)\.git$ ]]; then
        if is_robot; then
            debug_log "Converting GitLab URL to HTTPS protocol for the robot."
            echo "https://gitlab.fel.cvut.cz/${BASH_REMATCH[1]}.git"
        else
            debug_log "Skipping GitLab URL conversion for the local machine."
            echo "$url"
        fi
    else
        error_log "Invalid fetch URL format: $url"
        return 1
    fi
}


main() {

  # Parse command-line arguments
  while [[ $# -gt 0 ]]; do
      key="$1"
      case $key in
          -h|--help)
          print_usage  # Show usage information
          exit 0
          ;;
          --debug)
          DEBUG_MODE=true  # Enable debug mode
          shift # Move to the next argument or value
          ;;
          *)
          print_usage  # Show usage information if an unknown option is encountered
          handle_error "Unknown option: $1"
          shift # Move to the next argument or value
          ;;
      esac
  done

  # Check if the singularity container is running
  if [ "$APPTAINER_NAME" != "$(basename "${IMAGE_FILE}")" ]; then
    error_log "You are not inside the apptainer container. 
    Please start the container first using start_container.sh."
    exit 1
  fi

  # Check if the conda is in ~/.bashrc
  check_anaconda

  echo
  echo "==============================================================="
  echo

  # Initialize the workspace
  init_workspace

  debug_log "Changing the directory to the workspace directory: ${BOLD}${WORKSPACE_DIR}${RESET}"
  cd "${WORKSPACE_DIR}" || exit 1

  # Start the interactive bash
  info_log "Starting interactive bash"
  debug_log "Starting the interactive bash by running the command: ${BOLD}bash${RESET}"
  
  bash --rcfile "./devel/setup.bash"
}

main "$@"
