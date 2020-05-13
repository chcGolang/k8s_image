FROM alpine

COPY build.sh /tmp

RUN /tmp/build.sh

USER nobody

CMD ["glider", "-config", "/etc/glider/glider.conf"]