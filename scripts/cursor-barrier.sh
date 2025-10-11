#!/usr/bin/env bash

# Cursor barrier script to prevent mouse from entering DP-3
# Gets monitor boundaries and blocks cursor from crossing into DP-3

get_dp3_bounds() {
    hyprctl monitors -j | jq -r '.[] | select(.name == "DP-3") | "\(.x) \(.y) \(.width) \(.height)"'
}

while true; do
    # Get current cursor position
    cursor_pos=$(hyprctl cursorpos)
    x=$(echo "$cursor_pos" | cut -d',' -f1)
    y=$(echo "$cursor_pos" | cut -d',' -f2)
    
    # Get DP-3 bounds
    bounds=$(get_dp3_bounds)
    if [[ -n "$bounds" ]]; then
        read dp3_x dp3_y dp3_w dp3_h <<< "$bounds"
        
        # Check if cursor is in DP-3 area
        if [[ $x -ge $dp3_x && $x -lt $((dp3_x + dp3_w)) && 
              $y -ge $dp3_y && $y -lt $((dp3_y + dp3_h)) ]]; then
            # Move cursor back to edge of main monitors
            hyprctl dispatch movecursor $((dp3_x - 1)) $y
        fi
    fi
    
    sleep 0.01  # 10ms polling
done
