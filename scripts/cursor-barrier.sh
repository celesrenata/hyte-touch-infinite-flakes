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
        
        # Block cursor from crossing into DP-3 x boundary
        if [[ $x -ge $dp3_x ]]; then
            # Move cursor back to edge of main monitor
            hyprctl dispatch movecursor $((dp3_x - 1)) $y
        fi
    fi
    
    sleep 0.01  # 10ms polling
done
