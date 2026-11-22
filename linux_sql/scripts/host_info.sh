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
