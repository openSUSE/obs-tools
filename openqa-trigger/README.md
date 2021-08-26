# OpenQA Trigger
This script triggers the tests of OBS (Open Build Service) on openQA.

## Requirements
The machine needs to have installed previously `docker`, `docker-compose` and `git`.

## Configuration
You need to configure the script in the `.env` file. See the `dotenv.example` file for details.

## Usage
1. Clone the repository
1. Configure `.env`
1. `docker-compose build`
1. `docker-compose up -d`
