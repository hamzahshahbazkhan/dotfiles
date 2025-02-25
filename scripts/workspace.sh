#!/bin/bash

# Function to check if a program is installed
check_program() {
  if ! command -v $1 &>/dev/null; then
    echo "$1 is not installed. Please install it first."
    exit 1
  fi
}

# Check for required programs
check_program wmctrl
check_program xdotool

# Configuration variables - customize these
WORKSPACE_1_NAME="1"
WORKSPACE_2_NAME="2"
WORKSPACE_3_NAME="3"
TERMINAL="ghostty"
BROWSER="brave-browser"

# Function to create and switch to a workspace
create_workspace() {
  local workspace_num=$1
  local workspace_name=$2

  # Create workspace if it doesn't exist
  wmctrl -n $workspace_num 2>/dev/null

  # Name the workspace (requires GNOME)
  gsettings set org.gnome.desktop.wm.preferences workspace-names "['$WORKSPACE_1_NAME', '$WORKSPACE_2_NAME', '$WORKSPACE_3_NAME']"
}

# Function to launch application in specific workspace
launch_in_workspace() {
  local workspace=$1
  local command=$2

  # Switch to workspace
  wmctrl -s $((workspace - 1))

  # Launch application
  $command &

  # Wait for the window to appear
  sleep 1

  # Move window to current workspace
  window_id=$(wmctrl -l | grep -i $(echo $command | cut -d' ' -f1) | tail -1 | cut -d' ' -f1)
  wmctrl -i -r $window_id -t $((workspace - 1))
}

# Create workspaces
create_workspace 3 "$WORKSPACE_3_NAME"

# Launch applications in their respective workspaces
launch_in_workspace 1 "$TERMINAL"
launch_in_workspace 2 "$BROWSER"
launch_in_workspace 3 "snap run notion-snap-reborn " 
# Optional: Maximize windows
sleep 1
wmctrl -r :ACTIVE: -b add,maximized_vert,maximized_horz
wmctrl -s 0

echo "Workspace setup complete!"
