# Leap 15.1
FROM registry.opensuse.org/home/vpereirabr/dockerimages/containers/obs-tools/base:latest

COPY .  /home/frontend/obs-package-status

RUN chown -R frontend:users /home/frontend/

WORKDIR /home/frontend/obs-package-status

RUN bundler.ruby2.5 install

COPY entrypoint.sh status-check.rb /usr/local/bin/
RUN chmod a+x /usr/local/bin/entrypoint.sh /usr/local/bin/status-check.rb

USER frontend

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]

CMD ["/usr/local/bin/status-check.rb"]
