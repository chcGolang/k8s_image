#
# Dockerfile for ocserv
#

FROM alpine
MAINTAINER kev <noreply@easypi.pro>

ENV OCSERV_VERSION 1.0.0
ENV OCSERV_URL ftp://ftp.infradead.org/pub/ocserv/ocserv-$OCSERV_VERSION.tar.xz

RUN buildDeps=" \
        curl \
        g++ \
        gnutls-dev \
        gpgme \
        libev-dev \
        libnl3-dev \
        libseccomp-dev \
        linux-headers \
        linux-pam-dev \
        lz4-dev \
        make \
        readline-dev \
        tar \
        xz \
    "; \
    set -x \
    && apk add --update --virtual .build-deps $buildDeps \
    && apk add --upgrade sed \
    && curl -SL $OCSERV_URL -o ocserv.tar.xz \
    && curl -SL $OCSERV_URL.sig -o ocserv.tar.xz.sig \
    && mkdir -p /usr/src/ocserv \
    && tar -xf ocserv.tar.xz -C /usr/src/ocserv --strip-components=1 \
    && rm ocserv.tar.xz* \
    && cd /usr/src/ocserv \
    && ./configure \
    && make \
    && make install \
    && mkdir -p /etc/ocserv \
    && cp /usr/src/ocserv/doc/sample.config /etc/ocserv/ocserv.conf \
    && cd / \
    && runDeps="$( \
        scanelf --needed --nobanner /usr/local/sbin/ocserv \
            | awk '{ gsub(/,/, "\nso:", $2); print "so:" $2 }' \
            | xargs -r apk info --installed \
            | sort -u \
        )" \
    && apk add --virtual .run-deps $runDeps gnutls-utils iptables \
    && apk del .build-deps \
    && rm -rf /var/cache/apk/*

RUN set -xe \
    && mkdir -p /etc/ocserv/certs \
    && mkdir -p /etc/ocserv/config-per-user \
    && mkdir -p /etc/ocserv/config-per-group \
    && mkdir -p /etc/ocserv/defaults \
    && touch /etc/ocserv/defaults/user.conf \
    && touch /etc/ocserv/defaults/group.conf \
    && touch /etc/ocserv/ocpasswd \
    && sed -i -e 's@\./sample.passwd@/etc/ocserv/ocpasswd@' \
              -e 's@\.\./tests/@/etc/ocserv/@' \
              -e 's@^#cert-group-oid =@cert-group-oid =@' \
              -e 's@^#compression =.*@compression = true@' \
              -e 's@^#config-per-@config-per-@' \
              -e 's@^#default-@default-@' \
              -e 's@^default-domain@#&@' \
              -e 's@^dns =.*@dns = 8.8.8.8@' \
              -e 's@^max-clients =.*@max-clients = 0@' \
              -e 's@^max-same-clients =.*@max-same-clients = 0@' \
              -e 's@^route@#&@' \
              -e 's@^try-mtu-discovery =.*@try-mtu-discovery = true@' \
              /etc/ocserv/ocserv.conf

RUN sed -i -e 's@^auth = \"plain@#&@' /etc/ocserv/ocserv.conf
RUN sed -i -e 's@^#auth = "certificate"$@auth = "certificate"@' /etc/ocserv/ocserv.conf
RUN sed -i -e 's@^#crl =.*@crl = /etc/ocserv/certs/crl.pem@' /etc/ocserv/ocserv.conf
RUN sed -i -e 's/\[vhost:www.example.com]/#[vhost:www.example.com]/g' /etc/ocserv/ocserv.conf
RUN sed -i -e ':a;/\ncert-user-oid =/!{$bb;N;ba};P;D;:b;s/cert-user-oid =/#cert-user-oid =/' /etc/ocserv/ocserv.conf
RUN sed -i -e ':a;/\nserver-key =/!{$bb;N;ba};P;D;:b;s/server-key =/#server-key =/' /etc/ocserv/ocserv.conf
RUN sed -i -e ':a;/\nserver-cert =/!{$bb;N;ba};P;D;:b;s/server-cert =/#server-cert =/' /etc/ocserv/ocserv.conf
RUN sed -i -e ':a;/\nca-cert =/!{$bb;N;ba};P;D;:b;s/ca-cert =/#ca-cert =/' /etc/ocserv/ocserv.conf
RUN sed -i -e ':a;/\nauth =/!{$bb;N;ba};P;D;:b;s/auth =/#auth =/' /etc/ocserv/ocserv.conf
RUN sed -i -e ':a;/\nipv4-network =/!{$bb;N;ba};P;D;:b;s/ipv4-network =/#ipv4-network =/' /etc/ocserv/ocserv.conf
RUN sed -i -e ':a;/\nipv4-netmask =/!{$bb;N;ba};P;D;:b;s/ipv4-netmask =/#ipv4-netmask =/' /etc/ocserv/ocserv.conf
RUN sed -i -e 's@^cert-user-oid = 0\.9\.2342\.19200300\.100\.1\.1$@cert-user-oid = 2.5.4.3@' /etc/ocserv/ocserv.conf
RUN sed -i -e 's@^no-route@#&@' /etc/ocserv/ocserv.conf
RUN sed -i -e "s@^isolate-workers =.*@isolate-workers = false@" /etc/ocserv/ocserv.conf

COPY init.sh /init.sh
COPY docker-entrypoint.sh /entrypoint.sh
COPY setup-anyconnect.sh /etc/ocserv/setup-anyconnect.sh

RUN chmod +x /init.sh
RUN chmod +x /entrypoint.sh
RUN chmod +x /etc/ocserv/setup-anyconnect.sh

VOLUME /etc/ocserv
WORKDIR /etc/ocserv

ENV VPN_DOMAIN=vpn.easypi.pro    \
    VPN_NETWORK=10.20.30.0       \
    VPN_NETMASK=255.255.255.0    \
    LAN_NETWORK=192.168.0.0      \
    LAN_NETMASK=255.255.0.0      \
    VPN_USERNAME=username        \
    VPN_PASSWORD=password        \
    TERM=xterm

EXPOSE 443/tcp 443/udp

ENTRYPOINT ["/entrypoint.sh"]
