#!/bin/bash
# Get CPU usage (user+system)
cpu_val=$(top -bn1 | grep "Cpu(s)" | awk '{print $2 + $4}')
# Get Memory usage (used)
mem_val=$(free -m | grep Mem | awk '{print $3}')
# Get Memory total
mem_total=$(free -m | grep Mem | awk '{print $2}')

# Format as JSON
echo "{\"cpu\": \"$cpu_val\", \"mem_used\": \"$mem_val\", \"mem_total\": \"$mem_total\"}"
