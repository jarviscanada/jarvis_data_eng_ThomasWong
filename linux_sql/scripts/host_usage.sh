#!/bin/bash

# Setup cmd arguments
psql_host=$1
psql_port=$2
db_name=$3
psql_user=$4
psql_password=$5

# Check number of intput arguments
if [ "$#" -ne 5 ]; then
  echo "Illegal number of arguments"
  exit 1
fi

# target columns
mem_free_col=4
cpu_idle_col=15
kernel_state_col=14
disk_io_col=10
disk_avail_col=4

# Save machine statistics in MB and current machine name to variables
vmstat_mb=$(vmstat --unit M)
hostname=$(hostname -f)

# Retrieve hardware specifications
memory_free=$(echo "$vmstat_mb" | awk -v col="$mem_free_col" '{print $col}' | tail -n1 | xargs)
cpu_idle=$(echo "$vmstat_mb" | awk -v col="$cpu_idle_col" '{print $col}' | tail -n1 | xargs)
cpu_kernel=$(echo "$vmstat_mb" | awk -v col="$kernel_state_col" '{print $col}' | tail -n1 | xargs)

# Retrieve disk info
disk_io=$(vmstat -d | awk -v col="$disk_io_col" '{print $col}' | tail -n1 | xargs)
disk_available=$(df -BM / | awk -v col="$disk_avail_col" '{print $col}' | tail -n1 | xargs | grep -oE '[0-9]+')

# Current time in 'yyyy-mm-dd HH-MM-SS' UTC format
timestamp=$(vmstat -t | awk '{print $(NF-1), $NF}' | tail -n1 | xargs)

echo "Memory free: $memory_free"
echo "CPU idle time: $cpu_idle"
echo "CPU kernel state: $cpu_kernel"
echo "Disk IO: $disk_io"
echo "Disk available: $disk_available"
echo "Timestamp: $timestamp"