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

# Find matching host_id based on hostname from host_info table
host_id="(SELECT id FROM host_info WHERE hostname='$hostname')";

# SQL statement to insert usage info into table
insert_stmt="INSERT INTO host_usage(\"timestamp\", host_id, memory_free, cpu_idle, cpu_kernel, disk_io, disk_available) \
  VALUES ('$timestamp', $host_id, $memory_free, $cpu_idle, $cpu_kernel, $disk_io, $disk_available)"

# Configure env variable for psql command
export PGPASSWORD=$psql_password

# Execute psql insert command using psql cli
psql -h $psql_host -p $psql_port -d $db_name -U $psql_user -c "$insert_stmt"

exit $?