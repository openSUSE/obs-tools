FROM opensuse:42.3

# Install ruby rubygems and bundler
RUN zypper -n install --no-recommends --replacefiles ruby2.4-rubygem-bundler libxml2-devel libxslt-devel make gcc ruby2.4-devel osc vim cron

WORKDIR /home/bot

# Copy the code
COPY bot .
RUN rm -f config/config.yml
VOLUME config

# Install gem dependencies
RUN export NOKOGIRI_USE_SYSTEM_LIBRARIES=1; bundle.ruby2.4 install --jobs=3 --retry=3

# Add crontab file in the cron directory
ADD crontab /etc/cron.d/depfu-cron

# Give execution rights on the cron job
RUN chmod 0644 /etc/cron.d/depfu-cron

# Create the log file to be able to run tail
RUN touch /var/log/cron.log

# Run the command on container startup
CMD cron -n
