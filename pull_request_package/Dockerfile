FROM opensuse/tumbleweed

RUN zypper  --non-interactive --quiet ref \
 && zypper -n in osc ruby2.6 ruby2.6-devel git gcc make autoconf zlib-devel libxml2-devel libxslt-devel
RUN gem install bundler
RUN bundle.ruby2.6 config build.nokogiri --use-system-libraries
COPY .  /home/puller/pull_request_package
RUN cd /home/puller/pull_request_package && bundler.ruby2.6 install

RUN useradd -ms /bin/bash puller

RUN mkdir -p /home/puller/.config/osc/
COPY oscrc /home/puller/.config/osc/oscrc
RUN chown -R puller:users /home/puller/

USER puller

WORKDIR /home/puller/pull_request_package

ENTRYPOINT ["./entrypoint.sh"]
CMD ["./runner.rb", "-f", "config/config.yml"]
