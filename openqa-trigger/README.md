# OpenQA Trigger
This script triggers the openqa tests of OBS (Open Build Service). Currently,
the tested Appliance versions are: **2.10** and **Unstable**.

## Requirements
The machine needs to have installed previously `docker`, `docker-compose` and `git`.

## Configuration
Before running the docker container, we need to copy `client.conf.example` file
to `client.conf` and add the openqa **host**, API **key** and API **secret**.

## Usage
1. Clone the repository
1. `docker-compose build`
1. `docker-compose up -d`
