# OpenQA Trigger
This script triggers the openqa tests of OBS (Open Build Service). Currently,
the tested Appliance versions are: **2.10** and **Unstable**.

## Requirements
The machine needs to have `docker`, `docker-compose` and `git` installed.

## Configuration
Before running the docker container, you need to copy `.env.example` file
to `.env` and configure the variables. See the file for more information.

## Usage
1. Clone the repository
1. `docker-compose build`
1. `docker-compose up -d`
