# Linux Cluster Monitoring Agent
This project is a Linux cluster monitoring agent. Configured to each cluster machine allows collection of the hardware specifications and resource usage of each server. Information is stored in a central database for monitoring/analysis by system admins.

Hardware specifications are collected once; resource usage once per minute. Stored in two database tables.
* Docker: configuring psql environment
* PSQL: PostgreSQL database
* Bash: Script for creating docker containers, information collection and database insert
* Git: Version control system using GitFlow

# Quick start
```bash
# Create and/or start PostgreSQL docker container
./scripts/psql_docker.sh create postgres <db_password>
./scripts/psql_docker.sh start

# Create the database and tables (schema given in ddl.sql)
psql -h localhost -U postgres -c "CREATE DATABASE host_agent;"
psql -h localhost -U postgres -d host_agent -f sql/ddl.sql

# Record host hardware specifications (once per host)
./scripts/host_info.sh localhost 5432 host_agent postgres <db_password>

# Record snapshot of host resource usage
./scripts/host_usage.sh localhost 5432 host_agent postgres <db_password>

# Execute resource collection using crontab (once per minute)
crontab -e
# Timestamp crontab execution and resource usage return code
# Insert: * * * * * echo -n "$(vmstat -t | awk '{print $(NF-1), $NF}' | tail -n1):" >> /tmp/host_usage.log && bash /absolute/path/to/scripts/host_usage.sh localhost 5432 host_agent postgres postgres >> /tmp/host_usage.log
```
# Implementation
The project is broken down into separate components with each stage building upon the previous completed work. Starting with configuring the environment and services, collecting the data, and interacting with the database system for data insertion. Automation is done via bash crontab utilities.

Since all available data is present in the operating system, bash scripting is used collect and automate the project.
# Architecture
![Cluster architecture](./assets/Monitoring%20Agent%20Architecture.drawio.png)

# Scripts
#### psql_docker.sh - Configures the docker container for psql. Scripts starts|stops|creates docker.
```bash
./scripts/psql_docker.sh create <db_username> <db_password> # Creates container and database volume
./scripts/psql_docker.sh start                              # Start existing container
./scripts/psql_docker.sh stop                               # Stop running container
```
#### host_info.sh - collects hardware specifications and inserts into psql database using `vmstat`, `lscpu`, and `proc/cpuinfo`.
```bash
./scripts/host_info.sh <psql_host> <psql_port> <db_name> <psql_user> <psql_password>
```
#### host_usage.sh - collects host resource usage and inserts into psql database using `vmstat` and `df` command.
```bash
./scripts/host_usage.sh <psql_host> <psql_port> <db_name> <psql_user> <psql_password>
```
#### contab - Utility for executing bash script in fixed intervals, timestamp and script return code is logged.
```bash
crotab -e
# Insert: * * * * * echo -n "$(vmstat -t | awk '{print $(NF-1), $NF}' | tail -n1):" >> /tmp/host_usage.log && bash /absolute/path/to/scripts/host_usage.sh <psql_host> <psql_port> <db_name> <psql_user> <psql_password> >> /tmp/host_usage.log
```
# Database Modeling
**host_info** - Host hardware information

| Column | Type | Description |
|---|---|---|
| `host_id` | SERIAL, primary key | Generated host ID |
| `hostname` | VARCHAR, unique | Fully qualified hostname |
| `cpu_number` | INT2 | Number of CPUs |
| `cpu_architecture` | VARCHAR | CPU architecture|
| `cpu_model` | VARCHAR | CPU model |
| `cpu_mhz` | FLOAT8 | CPU clock speed (MHz) |
| `l2_cache` | INT4 | L2 cache size (kB) |
| `timestamp` | TIMESTAMP | Current time (UTC) |
| `total_mem` | INT4 | Total memory (kB) |

**host_usage** - Host current resource usage

| Column | Type | Notes |
|---|---|---|
| timestamp | TIMESTAMP | Current time (UTC) |
| host_id | SERIAL, foriegn key | Reference host_info.id |
| memory_free | INT4 | Available memory (MB) |
| cpu_idle | INT2 | CPU idle time (%) |
| cpu_kernel | INT2 | CPU kernel mode time (%) |
| disk_io | INT4 | Disk I/O operations |
| disk_available | INT4 | Available disk in root dir (MB) |
# Testing Strategy

# Deployment

# Improvements