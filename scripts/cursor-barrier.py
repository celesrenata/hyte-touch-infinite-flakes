#!/usr/bin/env python3
import subprocess
import time

while True:
    try:
        pos = subprocess.check_output(['hyprctl', 'cursorpos']).decode().strip()
        x, y = pos.replace(',', '').split()
        x, y = int(x), int(y)
        
        if x >= 3840:
            subprocess.run(['hyprctl', 'dispatch', 'movecursor', '3839', str(y)], 
                         stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
        
        time.sleep(0.01)
    except Exception as e:
        time.sleep(1)
