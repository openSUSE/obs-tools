FROM registry.opensuse.org/home/vpereirabr/dockerimages/containers/obs-tools/base:latest

RUN zypper --non-interactive --quiet ref \
 && zypper -n in curl openQA-client

RUN mkdir -p /home/frontend/.config/openqa/
COPY client.conf /home/frontend/.config/openqa/client.conf
RUN chown -R frontend:users /home/frontend/

WORKDIR /home/frontend/openqa-trigger

COPY entrypoint.sh schedule-obs.sh /usr/local/bin/

USER frontend

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]

CMD ["/usr/local/bin/schedule-obs.sh"]
