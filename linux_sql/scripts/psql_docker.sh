#!/bin/bash

# Get CLU arguments
cmd=$1
db_username=$2
db_password=$3

# Check if docker is running (exit 0) otherwise start docker
sudo systemctl status docker || sudo systemctl start docker

# Check the container status
docker container inspect jrvs-psql
# Capture previous command exit code (zero for success)
container_status=$?

# User command argument switch case for create|stop|start operations
case $cmd in
  create)

    # Check if container is already created
    if [ $container_status -eq 0 ]; then
      echo 'Container already exists'
      exit 1
    fi

    # Check # of CLI arguments
    if [ $# -ne 3 ]; then
      echo 'Create requires username and password'
      exit 1
    fi

    # Create docker volume
    docker volume create pgdata
    # Create container
    docker run --name jrvs-psql -e POSTGRES_USER="$db_username" -e POSTGRES_PASSWORD="$db_password" -d -v pgdata:/var/lib/postgresql/data -p 5432:5432 postgres:9.6-alpine
    # Capture docker run exit code
    exit $?
    ;;

  start|stop)
    # Check docker status; exit 1 if container has not been created
    if [ $container_status -ne 0 ]; then
      echo 'Container has not been created'
      exit 1
    fi

    # Start or stop the container
    docker container "$cmd" jrvs-psql
    exit $?
    ;;

  # Default any other argument
  *)
    echo 'Illegal command'
    echo 'Commands; start|stop|create'
    exit 1
    ;;
esac
