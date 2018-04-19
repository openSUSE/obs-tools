FROM opensuse:42.3

# Install ruby rubygems and bundler
RUN zypper -n install --no-recommends --replacefiles ruby2.4-rubygem-bundler libxml2-devel libxslt-devel make gcc ruby2.4-devel osc vim

WORKDIR /home/bot

# Copy the code
COPY bot .
RUN rm -f config/config.yml
VOLUME config

# Install gem dependencies
RUN export NOKOGIRI_USE_SYSTEM_LIBRARIES=1; bundle.ruby2.4 install --jobs=3 --retry=3

# Run our bot
CMD ["ruby.ruby2.4", "runner.rb"]
