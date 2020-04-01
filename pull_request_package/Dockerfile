# Leap 15.1
FROM registry.opensuse.org/home/vpereirabr/dockerimages/containers/obs-tools/base:latest

COPY . /home/frontend/obs-pullrequest-package/

RUN chown -R frontend:users /home/frontend/

WORKDIR /home/frontend/obs-pullrequest-package

COPY entrypoint.sh runner.rb /home/frontend/obs-pullrequest-package/
RUN chmod a+x /home/frontend/obs-pullrequest-package/entrypoint.sh /home/frontend/obs-pullrequest-package/runner.rb

RUN bundler.ruby2.5 install

USER frontend

ENTRYPOINT ["/home/frontend/obs-pullrequest-package/entrypoint.sh"]

CMD ["/home/frontend/obs-pullrequest-package/runner.rb"]
