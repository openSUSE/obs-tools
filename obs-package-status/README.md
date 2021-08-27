# OBS Package Status Scanner
This script shows if the packages of OBS (Open Build Service) are broken or not. The status gets then reported to a Trello card.

## Configuration
This bot is configured via environment variables. Either set them however you set them
or copy the `dotenv.example` file to `.env` and the script picks them up from this file.

## Usage
1. Clone the repository
2. Build the docker container:
``` make build```
3. Start the service:
```
make run
```
