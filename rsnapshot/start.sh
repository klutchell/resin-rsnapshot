#!/bin/ash

# set timezone with TZ
# eg. TZ=America/Toronto
# ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

rsnapshot_config="/usr/src/app/rsnapshot.conf"
crontab_schedule="/usr/src/app/crontabs"

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
while IFS=; read var
do
	if [ -n "$(eval "echo \$${var}")" ]
	then
		eval "echo \$${var}" | sed -r 's/\s+/\t/g' | tee "${rsnapshot_config}"
	fi
done < <(printenv | grep "^RSNAPSHOT_CONF_")

# for var in $(printenv | grep "^RSNAPSHOT_CONF_")
# do
# 	if [ -n "$(eval "echo \$${var}")" ]
# 	then
# 		eval "echo \$${var}" | sed -r 's/\s+/\t/g' | tee "${rsnapshot_config}"
# 	fi
# done

# test rsnapshot config syntax
echo "checking rsnapshot config ..."
/usr/bin/rsnapshot -c "${rsnapshot_config}" configtest || exit 1

# print cron schedule in human readable format
echo "reading rsnapshot schedule ..."
# skip whitespace and comments
cat "${crontab_schedule}" | grep -v '^\s*#' | grep -v '^\s*$' | while IFS=$'\n' read -r line
do
	exp="$(echo "${line}" | awk '{print $1"+"$2"+"$3"+"$4"+"$5}')"
	sched="$(curl -s --retry 3 "https://cronexpressiondescriptor.azurewebsites.net/api/descriptor/?expression=${exp}&locale=en-US" | awk -F '"' '{print $4}')"
	echo "+ ${sched:-$exp}"
done

echo "ready."

# start cron in foreground
/usr/sbin/crond -f

