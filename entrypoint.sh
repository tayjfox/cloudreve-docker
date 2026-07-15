#!/bin/sh
set -eu

if [ -n "${TZ:-}" ] && [ -f "/usr/share/zoneinfo/$TZ" ]; then
  cp "/usr/share/zoneinfo/$TZ" /etc/localtime
  echo "$TZ" > /etc/timezone
fi

if [ "${CR_ENABLE_ARIA2:-0}" = "1" ]; then
  if ! command -v supervisord >/dev/null 2>&1 || ! command -v aria2c >/dev/null 2>&1; then
    echo "CR_ENABLE_ARIA2=1 but aria2/supervisor is not installed. Rebuild with INSTALL_ARIA2=1 or set CR_ENABLE_ARIA2=0." >&2
    exit 1
  fi

  mkdir -p /cloudreve/data/temp/aria2
  touch /cloudreve/data/temp/aria2/aria2.session
  supervisord -c ./aria2.supervisor.conf
fi

exec ./cloudreve
