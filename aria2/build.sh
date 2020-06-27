#!/usr/bin/env sh

cd /tmp

LATEST_TAG="$(wget --spider -qS https://github.com/nadoo/glider/releases/latest 2>&1 | sed -n 's|^ *Location:.*/tag/\(.*\)$|\1|p' | tr -d '\r\n')"
if [ -z "$LATEST_TAG" ]; then
  LATEST_TAG="$(wget -qO- https://github.com/nadoo/glider/releases | grep -o -m 1 'tag/[^"]\+' | sed -n 's|tag/\(.*\)$|\1|p')"
fi

if [ -z "$LATEST_TAG" ]; then
  echo Get latest tag fail
  exit 1
fi

VERSION=${LATEST_TAG:1}

wget "https://github.com/nadoo/glider/releases/download/${LATEST_TAG}/glider_${VERSION}_linux_amd64.tar.gz"
tar zxvf "glider_${VERSION}_linux_amd64.tar.gz"

mv "glider_${VERSION}_linux_amd64/glider" /usr/bin
mv "glider_${VERSION}_linux_amd64/config/" /etc/glider/
mv /etc/glider/glider.conf.example /etc/glider/glider.conf

rm -rf /tmp/*