# Github Labeling Bot

This bot will check for open pull requests in openSUSE/open-build-service project on GitHub and compare the gem update with the following projects on 
[build.opensuse.org](https://build.opensuse.org)

- OBS:Server:Unstable 
- devel:languages:ruby:extensions
- home:factory-auto:branches:devel:languages:ruby:extensions (coolo's bot)

and depending on the version it will comment on the pull request with a:

- Note that package is already up to date
- Note with command how update the link reference
- Note with a link to the pending submit request which needs to get accepted
- Note that there package is not up to date and there is no pending submit request

# Usage

You can just run the bot script by hand using ruby (after setting up all the environment needed):

```
ruby bot/runner.rb
```

Setup first a directory with the config.yml file in it and use that dir path for setting the volume in the docker container.

See this example for a one execution container:
```
docker run --rm -it -v PATH_TO_CONFIG/config:/home/bot/config chrisbr/depfu-commenter
```
