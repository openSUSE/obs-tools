FROM registry.opensuse.org/home/vpereirabr/dockerimages/containers/obs-tools/base:latest

RUN zypper -n in --no-recommends openQA-client; zypper cc -a

WORKDIR /home/frontend/openqa-trigger

USER frontend

# We copy the Gemfiles into this intermediate build stage so it's checksum
# changes and all the subsequent stages (a.k.a. the bundle install call below)
# have to be rebuild. Otherwise, after the first build of this image,
# docker would use it's cache for this and the following stages.
ADD Gemfile /home/frontend/openqa-trigger/Gemfile
ADD Gemfile.lock /home/frontend/openqa-trigger/Gemfile.lock

RUN bundle install

ENTRYPOINT ["/home/frontend/openqa-trigger/entrypoint.sh"]

CMD ["ruby.ruby2.5", "/home/frontend/openqa-trigger/schedule-obs.rb"]
