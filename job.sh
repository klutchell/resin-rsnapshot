#!/bin/bash

# /proc/1/fd/1 is systemd's stdout, and therefore appears in the resin logs.
/usr/bin/rsnapshot -v -c /etc/rsnapshot.conf "${1}" >/proc/1/fd/1