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

# Collect statistics
vmstat_mb=$(vmstat --unit K)
lscpu_out=$(lscpu)
hostname=$(hostname -f)
cpu_info=$(cat /proc/cpuinfo)

# Query device info
cpu_number=$(echo "$lscpu_out" | awk -F: '/^CPU\(s\):/ {print $2}' | xargs)
cpu_architecture=$(echo "$lscpu_out" | awk -F: '/^Architecture:/ {print $2}' | xargs)
cpu_model=$(echo "$lscpu_out" | awk -F: '/^Model name:/ {print $2}' | xargs)
cpu_mhz=$(echo "$cpu_info" | grep "cpu MHz" | head -n 1 | awk '{print $4}' | xargs)
l2_cache=$(echo "$lscpu_out" | awk -F: '/^L2 cache:/ {print $2}' | awk '{print $1}' | xargs)
timestamp=$(vmstat -t | awk '{print $(NF-1), $NF}' | tail -n1 | xargs)
total_mem=$(vmstat -s --unit K | head -n 1 | awk '{print $1}')

echo "Hostname: $hostname"
echo "CPU number: $cpu_number"
echo "CPU architecture: $cpu_architecture"
echo "CPU model: $cpu_model"
echo "CPU mHz: $cpu_mhz"
echo "l2 cache: $l2_cache"
echo "Timestamp: $timestamp"
echo "Total memory $total_mem"