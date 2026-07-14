#!/bin/sh

if [ -n "$TZ" ] && [ -f "/usr/share/zoneinfo/$TZ" ]; then
  cp "/usr/share/zoneinfo/$TZ" /etc/localtime
  echo "$TZ" > /etc/timezone
fi

supervisord -c ./aria2.supervisor.conf
./cloudreve
