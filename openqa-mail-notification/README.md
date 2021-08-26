# OpenQA mail notification
This script sends mails with the results of the OpenQA tests of OBS (Open Build Service).

## Requirements
The machine needs to have installed `docker`, `docker-compose` and `git`.

## Configuration
Before running the Docker container, we need to copy `dotenv.example` file
to `.env` and modify the file accordingly.

## Usage
1. Clone the repository
1. Configure .env
1. `docker-compose build openqa-mail-notification`
1. `docker-compose up openqa-mail-notification`
