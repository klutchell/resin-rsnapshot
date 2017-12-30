#!/bin/bash

# /proc/1/fd/1 is systemd's stdout, and therefore appears in the resin logs.
echo "running /usr/bin/rsnapshot -v -c /data/rsnapshot.conf ${1}..." &>/proc/1/fd/1
/usr/bin/rsnapshot -v -c /data/rsnapshot.conf ${1} &>/proc/1/fd/1