# Container image for Github Labeling Bot
FROM opensuse:42.3

# Install ruby rubygems and bundler
RUN zypper -n install --no-recommends --replacefiles ruby2.4-rubygem-bundler

WORKDIR /home/bot

# Copy the code
COPY bot .
RUN rm -f config/config.yml
VOLUME config

# Install gem dependencies
RUN bundler.ruby2.4

# Run our bot
CMD ["ruby.ruby2.4", "runner.rb"]
