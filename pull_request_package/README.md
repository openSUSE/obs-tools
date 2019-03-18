# Build Git(hub) pull requests on openSUSE BuildService (https://build.opensuse.org/)

How to run it:

### Development

I normally have the openSUSE [BuildService](https://github.com/openSUSE/open-build-service/wiki/Development-Environment-Tips-&-Tricks) locally running and then I can configure it together with a ```config.yml```

then I call:

```
docker build -t $USER/pull_request_package .
```

and then

```
docker run --network="open-build-service_default"  -v $PWD:/home/puller/pull_request_package --rm -ti $USER/pull_request_package -e RUN_EVERY=360
```

if you want to run multiple instances in parallel, just map the new config file
to ```config/config.yml``` inside the container, i.e:

```
docker run  -v $(PWD):/home/puller/pull_request_package -v $PWD/other-config.yml:$PWD/config/config.yml -e RUN_EVERY=60--rm -ti $USER/pull_request_package
```

if you need to pass an existing osc config to your container do something
similar with:

```
docker run -v /home/vpereira/.config/osc/oscrc:/home/puller/.config/osc/oscrc -v $(PWD):/home/puller/pull_request_package -e RUN_EVERY=600 --rm -ti $USER/pull_request_package
```

### Production

- First generate the config file
- Run ```make build``` to build the docker container
- Run ```make run``` to start the container as a service


## The config.yml file syntax:

```
# generate and customize your token here
# https://github.com/settings/tokens
#
# The only necessary rights are to update Mrepo:status

:credentials:
  :access_token: my-oath-tokens
:logging: false
:build_server: https://build.opensuse.org
:build_server_project_integration_prefix: OBS:Server:Unstable:TestGithub:PR
:build_server_project: OBS:Server:Unstable
:build_server_package_name: obs-server
:git_repository: openSUSE/open-buildservice
:git_server: https://github.com/
:git_branch: master

```
