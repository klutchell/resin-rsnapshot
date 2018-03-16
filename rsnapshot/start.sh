#!/bin/bash

# replace one or more spaces with a single tab
spaces_to_tabs()	{ echo "${1}" | sed 's| \+|\t|g' ; }

# create ssh dir if it doesn't exist
if [ ! -d "${HOME}/.ssh" ]
then
	mkdir -p "${HOME}/.ssh"
fi

# generate ssh key to connect to other authenticated systems
if [ ! -f "${HOME}/.ssh/id_rsa" ]
then
	ssh-keygen -q -t "rsa" -N '' -f "${HOME}/.ssh/id_rsa" -C "$(id -un)@$(hostname) $(date)"
fi

# generate ssh config file to prevent caching known hosts
if [ ! -f "${HOME}/.ssh/config" ]
then
	cat <<EOF >> "${HOME}/.ssh/config"

Host *
	StrictHostKeyChecking no
	UserKnownHostsFile /dev/null"

EOF
fi

# set permissions on ssh dir
chown -R root:root "${HOME}/.ssh"
chmod -R 700 "${HOME}/.ssh"

# mount /dev/sda1 if it exists
part_label="snapshots"
if blkid | grep -q "LABEL=$part_label"
then
	echo "found 'snapshots' device ..."
	blkid | grep "LABEL=$part_label"
	echo "mounting onto /snapshots ..."
	mkdir /snapshots 2>/dev/null || true
	mount -L "$part_label" /snapshots
else
	# rsnapshot configtest will fail since /snapshots does not exist
	# and no_create_root is currently enabled
	echo "no devices with label 'snapshots' found!"
fi

# append RSNAPSHOT_CONF_* environment variables to rsnapshot.conf
echo "updating rsnapshot config ..."
rsnapshot_config="/etc/rsnapshot.conf"
for var in $(compgen -A variable | grep "^RSNAPSHOT_CONF_")
do
	if [ -n "$(eval "echo \$${var}")" ]
	then
		eval "echo +\$${var}"
		spaces_to_tabs "$(eval "echo \$${var}")" >> "${rsnapshot_config}"
	fi
done

# test rsnapshot config syntax
echo "checking rsnapshot config ..."
/usr/bin/rsnapshot -c "${rsnapshot_config}" configtest || exit 1

# print cron schedule in human readable format
echo "reading rsnapshot schedule ..."
grep -v '^\s*#' "/etc/crontabs/root" | grep -v '^\s*$' | while IFS=$'\n' read -r line
do
	exp="$(echo "${line}" | awk '{print $1"+"$2"+"$3"+"$4"+"$5}')"
	sched="$(curl -s "https://cronexpressiondescriptor.azurewebsites.net/api/descriptor/?expression=${exp}&locale=en-US" | awk -F '"' '{print $4}')"
	echo "+${sched}"
done

# start cron in foreground
/usr/sbin/crond -f
