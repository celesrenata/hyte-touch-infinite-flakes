#!/usr/bin/env bash
PATH=/run/current-system/sw/bin:/etc/profiles/per-user/celes/bin:$PATH

# CPU usage
echo $(top -bn1 | grep 'Cpu(s)' | awk '{print 100 - $8}')

# RAM usage
echo $(free | grep Mem | awk '{print ($3/$2) * 100}')

# GPU usage
echo $(nvidia-smi --query-gpu=utilization.gpu --format=csv,noheader,nounits)

# GPU memory usage
echo $(nvidia-smi --query-gpu=memory.used,memory.total --format=csv,noheader,nounits | awk -F', ' '{print ($1/$2)*100}')

# Disk usage /
echo $(df / | tail -1 | awk '{print $5}' | tr -d '%')

# Disk usage /mnt/fast
echo $(df /mnt/fast | tail -1 | awk '{print $5}' | tr -d '%')

# CPU temp
echo $(sensors | grep 'Tctl:' | awk '{print $2}' | tr -d '+°C')

# GPU temp
echo $(nvidia-smi --query-gpu=temperature.gpu --format=csv,noheader,nounits)

# Motherboard temp
echo $(sensors | grep 'Motherboard:' | awk '{print $2}' | tr -d '+°C')

# Chipset temp
echo $(sensors | grep 'Chipset:' | awk '{print $2}' | tr -d '+°C')

# CPU power (from ASUS EC sensor)
echo $(echo "scale=2; $(cat $(grep -l asusec /sys/class/hwmon/hwmon*/name | sed 's/name/in0_input/') ) * $(cat $(grep -l asusec /sys/class/hwmon/hwmon*/name | sed 's/name/curr1_input/') ) / 1000000" | bc)

# GPU power
echo $(nvidia-smi --query-gpu=power.draw --format=csv,noheader,nounits)

# Network stats
cat /proc/net/dev | grep -E 'enp5s0f0|enp5s0f1|br0' | awk '{rx+=$2; tx+=$10} END {print rx, tx}'
