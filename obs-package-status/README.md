# OBS Package Status Scanner
This script shows if the packages of OBS (Open Build Service) are broken or not. The status gets then reported to a Trello card.

## Configuration
This bot is configured via environment variables. Either set them however you set them
or copy the `dotenv.example` file to `.env` and the script picks them up from this file.

### Trello
- `OBS_TRELLO_API_KEY` *
Your Trello API Key, see https://developers.trello.com/

**Default**: nothing (you have to set this)

- `OBS_TRELLO_API_TOKEN` *
Your Trello API Token, see https://developers.trello.com/

**Default**: nothing (you have to set this)

- `OBS_TRELLO_CARD_ID`
The id of the trello card you want to change

**Default**: nothing (you have to set this)

- `OBS_TRELLO_FAILED_IMAGE`
The filename of the image that should be used as cover for the card
if the there are failures

**Default**: failed.jpg

- `OBS_TRELLO_PASSED_IMAGE`
The filename of the image that should be used as cover for the card
if the there aren't any failures

**Default**: passed.jpg

### OBS
- `OBS_API_URL`
The full URL of your Open Build Service API

**Default**: https://api.opensuse.org

- `OBS_PROJECT`
The project you want to check

**Default**: `'OBS:Server:Unstable'`

- `OBS_PACKAGE`
The package you want to check

**Default**: `'obs-server'`

- `OBS_ARCHITECTURE`
The architecture you want to check

**Default**: `'x86_64'`

- `OBS_REPOSITORIES`
A list of OBS Repositories you want to check the package for. Separated by blank.

**Default**: `'SLE_12_SP4 openSUSE_42.3'`

## Usage
1. Clone the repository
2. Build the docker container:
``` make build```
3. Start the service:
```
make run
```
