FROM alpine

COPY glider/build.sh /tmp

RUN chmod +x /tmp/build.sh

RUN /tmp/build.sh

USER nobody

CMD ["glider", "-config", "/etc/glider/glider.conf"]