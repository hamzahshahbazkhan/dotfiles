#!/bin/bash

# Get screen dimensions
get_screen_dimensions() {
  xdpyinfo | awk '/dimensions:/ { split($2, dims, "x"); print dims[1], dims[2] }'
}

# Get active window ID
get_active_window() {
  xdotool getactivewindow
}

# Find window in direction (same as before)
find_window_in_direction() {
  local direction=$1
  local current_window=$(get_active_window)
  local current_x current_y current_width current_height
  eval $(xwininfo -id $current_window |
    awk '/Absolute upper-left X/ {x=$4} 
             /Absolute upper-left Y/ {y=$4} 
             /Width/ {w=$2} 
             /Height/ {h=$2} 
             END {print "current_x=" x "; current_y=" y "; current_width=" w "; current_height=" h}')

  local current_center_x=$((current_x + current_width / 2))
  local current_center_y=$((current_y + current_height / 2))

  local windows=$(wmctrl -l | grep "$(xdotool get_desktop)" | cut -d' ' -f1)
  local best_distance=999999
  local best_window=""

  for window in $windows; do
    if [ "$window" != "$current_window" ]; then
      local win_x win_y win_width win_height
      eval $(xwininfo -id $window |
        awk '/Absolute upper-left X/ {x=$4} 
                     /Absolute upper-left Y/ {y=$4} 
                     /Width/ {w=$2} 
                     /Height/ {h=$2} 
                     END {print "win_x=" x "; win_y=" y "; win_width=" w "; win_height=" h}')

      local win_center_x=$((win_x + win_width / 2))
      local win_center_y=$((win_y + win_height / 2))

      case $direction in
      "left")
        if [ $win_center_x -lt $current_center_x ]; then
          local distance=$(((current_center_x - win_center_x) ** 2 + (current_center_y - win_center_y) ** 2))
          if [ $distance -lt $best_distance ]; then
            best_distance=$distance
            best_window=$window
          fi
        fi
        ;;
      "right")
        if [ $win_center_x -gt $current_center_x ]; then
          local distance=$(((current_center_x - win_center_x) ** 2 + (current_center_y - win_center_y) ** 2))
          if [ $distance -lt $best_distance ]; then
            best_distance=$distance
            best_window=$window
          fi
        fi
        ;;
      "up")
        if [ $win_center_y -lt $current_center_y ]; then
          local distance=$(((current_center_x - win_center_x) ** 2 + (current_center_y - win_center_y) ** 2))
          if [ $distance -lt $best_distance ]; then
            best_distance=$distance
            best_window=$window
          fi
        fi
        ;;
      "down")
        if [ $win_center_y -gt $current_center_y ]; then
          local distance=$(((current_center_x - win_center_x) ** 2 + (current_center_y - win_center_y) ** 2))
          if [ $distance -lt $best_distance ]; then
            best_distance=$distance
            best_window=$window
          fi
        fi
        ;;
      esac
    fi
  done

  if [ -n "$best_window" ]; then
    wmctrl -ia "$best_window"
  fi
}

# Calculate layout positions
calculate_layout() {
  local layout=$1
  local position=$2
  read screen_width screen_height <<<$(get_screen_dimensions)

  case $layout in
  "half")
    case $position in
    "left") echo "0,0,$((screen_width / 2)),$screen_height" ;;
    "right") echo "$((screen_width / 2)),0,$((screen_width / 2)),$screen_height" ;;
    "top") echo "0,0,$screen_width,$((screen_height / 2))" ;;
    "bottom") echo "0,$((screen_height / 2)),$screen_width,$((screen_height / 2))" ;;
    esac
    ;;
  "third")
    case $position in
    "left") echo "0,0,$((screen_width / 3)),$screen_height" ;;
    "middle") echo "$((screen_width / 3)),0,$((screen_width / 3)),$screen_height" ;;
    "right") echo "$((2 * screen_width / 3)),0,$((screen_width / 3)),$screen_height" ;;
    esac
    ;;
  "quad")
    case $position in
    "top_left") echo "0,0,$((screen_width / 2)),$((screen_height / 2))" ;;
    "top_right") echo "$((screen_width / 2)),0,$((screen_width / 2)),$((screen_height / 2))" ;;
    "bottom_left") echo "0,$((screen_height / 2)),$((screen_width / 2)),$((screen_height / 2))" ;;
    "bottom_right") echo "$((screen_width / 2)),$((screen_height / 2)),$((screen_width / 2)),$((screen_height / 2))" ;;
    esac
    ;;
  "full")
    echo "0,0,$screen_width,$screen_height"
    ;;
  esac
}

# Apply window position
apply_window_position() {
  local window_id=$1
  local x=$2
  local y=$3
  local width=$4
  local height=$5
  wmctrl -ir $window_id -e "0,$x,$y,$width,$height"
}

# Main command handling
case "$1" in
# Window focus commands
"focus_left") find_window_in_direction "left" ;;
"focus_right") find_window_in_direction "right" ;;
"focus_up") find_window_in_direction "up" ;;
"focus_down") find_window_in_direction "down" ;;

# Half screen layouts
"half_left")
  read x y w h <<<$(calculate_layout "half" "left" | tr ',' ' ')
  apply_window_position $(get_active_window) $x $y $w $h
  ;;
"half_right")
  read x y w h <<<$(calculate_layout "half" "right" | tr ',' ' ')
  apply_window_position $(get_active_window) $x $y $w $h
  ;;
"half_top")
  read x y w h <<<$(calculate_layout "half" "top" | tr ',' ' ')
  apply_window_position $(get_active_window) $x $y $w $h
  ;;
"half_bottom")
  read x y w h <<<$(calculate_layout "half" "bottom" | tr ',' ' ')
  apply_window_position $(get_active_window) $x $y $w $h
  ;;

# Third screen layouts
"third_left")
  read x y w h <<<$(calculate_layout "third" "left" | tr ',' ' ')
  apply_window_position $(get_active_window) $x $y $w $h
  ;;
"third_middle")
  read x y w h <<<$(calculate_layout "third" "middle" | tr ',' ' ')
  apply_window_position $(get_active_window) $x $y $w $h
  ;;
"third_right")
  read x y w h <<<$(calculate_layout "third" "right" | tr ',' ' ')
  apply_window_position $(get_active_window) $x $y $w $h
  ;;

# Quad screen layouts
"quad_top_left")
  read x y w h <<<$(calculate_layout "quad" "top_left" | tr ',' ' ')
  apply_window_position $(get_active_window) $x $y $w $h
  ;;
"quad_top_right")
  read x y w h <<<$(calculate_layout "quad" "top_right" | tr ',' ' ')
  apply_window_position $(get_active_window) $x $y $w $h
  ;;
"quad_bottom_left")
  read x y w h <<<$(calculate_layout "quad" "bottom_left" | tr ',' ' ')
  apply_window_position $(get_active_window) $x $y $w $h
  ;;
"quad_bottom_right")
  read x y w h <<<$(calculate_layout "quad" "bottom_right" | tr ',' ' ')
  apply_window_position $(get_active_window) $x $y $w $h
  ;;

# Full screen
"full")
  read x y w h <<<$(calculate_layout "full" "" | tr ',' ' ')
  apply_window_position $(get_active_window) $x $y $w $h
  ;;

*)
  echo "Usage: $0 {focus_left|focus_right|focus_up|focus_down|"
  echo "          half_left|half_right|half_top|half_bottom|"
  echo "          third_left|third_middle|third_right|"
  echo "          quad_top_left|quad_top_right|quad_bottom_left|quad_bottom_right|"
  echo "          full}"
  exit 1
  ;;
esac
