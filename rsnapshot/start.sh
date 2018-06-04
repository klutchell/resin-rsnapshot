#!/bin/ash

rsnapshot_config="/usr/src/app/rsnapshot.conf"
crontab_schedule="/usr/src/app/crontab"

part_label="snapshots"
dev_path="$(blkid | grep "LABEL=\"${part_label}\"" | cut -d: -f1)"

# mount device with LABEL="snapshot" if it exists
if [ -n "${dev_path}" ]
then
	echo "mounting ${dev_path} onto ${SNAPSHOT_ROOT} ..."
	mount "${dev_path}" "${SNAPSHOT_ROOT}"
else
	echo "no devices with label '${part_label}' found!"
	exit 1
fi

# append RSNAPSHOT_CONF_* environment variables to rsnapshot.conf
echo "updating rsnapshot config ..."
printenv | grep "^RSNAPSHOT_CONF_" | sed -r 's/^[^=]+=//' | sed -r 's/\s+/\t/g' | tee -a "${rsnapshot_config}"

# test rsnapshot config syntax
echo "checking rsnapshot config ..."
/usr/bin/rsnapshot -c "${rsnapshot_config}" configtest || exit 1

# print cron schedule in human readable format
echo "reading rsnapshot schedule ..."
# skip whitespace and comments
cat "${crontab_schedule}" | grep -v '^\s*#' | grep -v '^\s*$' \
	| awk '{print "https://cronexpressiondescriptor.azurewebsites.net/api/descriptor/?expression="$1"+"$2"+"$3"+"$4"+"$5"&locale=en-US"}' \
	| xargs curl -s --retry 3 | sed -r 's/\{"description":"([^"]+)"\}/\1\n/g'

echo "ready."

# start cron in foreground
/usr/sbin/crond -f

