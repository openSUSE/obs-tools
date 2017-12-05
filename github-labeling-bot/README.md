# Github Labeling Bot

This bot is meant for labeling PRs in repositories, mainly for Open Build Service. It will tag the PRs based on the files touched and on the tags added
to the commit titles.

# Usage

You can just run the bot script by hand using ruby (after setting up all the environment needed):

```
ruby bot/runner.rb
```

Or you can just use the docker image provided at [hub.docker.com - mdeniz/github_labeling_bot](https://hub.docker.com/r/mdeniz/github_labeling_bot/).

Setup first a directory with the config.yml file in it and use that dir path for setting the volume in the docker container.

See this example for a one execution container:
```
docker run --rm -it -v PATH_TO_CONFIG/config:/home/bot/config mdeniz/github_labeling_bot
```
