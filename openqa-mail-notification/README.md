# OpenQA mail notification
This script sends mails with the results of the OpenQA tests of OBS (Open Build Service).

## Requirements
The machine needs to have installed `docker`, `docker-compose` and `git`.

## Configuration
Before running the Docker container, we need to copy `config.yml.example` file
to `config.yml` and modify the file accordingly.

## Usage
1. Clone the repository
1. `docker-compose build`
1. `docker-compose up -d`
