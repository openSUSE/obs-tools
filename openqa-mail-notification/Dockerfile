FROM registry.opensuse.org/home/vpereirabr/dockerimages/containers/obs-tools/base:latest

RUN zypper --non-interactive --quiet refresh \
 && zypper --non-interactive install ruby2.5-rubygem-mail

RUN chown --recursive frontend:users /home/frontend/

WORKDIR /home/frontend/openqa-mail-notification

COPY entrypoint.sh mail_notification.rb /usr/local/bin/
RUN chmod a+x /usr/local/bin/entrypoint.sh /usr/local/bin/mail_notification.rb

USER frontend

ENTRYPOINT ["./entrypoint.sh"]

CMD ["./mail_notification.rb"]
