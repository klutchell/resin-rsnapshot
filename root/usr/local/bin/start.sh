#!/bin/bash

# replace one or more spaces with a single tab
spaces_to_tabs()	{ echo "${1}" | sed 's| \+|\t|g' ; }

# create ssh dir if it does not exist
[ -d "/data/.ssh" ] ||
	mkdir -p "/data/.ssh"

# touch authorized_keys if it does not exist
[ -f "/data/.ssh/authorized_keys" ] ||
	touch "/data/.ssh/authorized_keys"

# set permissions on ssh dir
chown -R root:root "/data/.ssh"
chmod -R 700 "/data/.ssh"

# generate host keys
/usr/bin/ssh-keygen -A

rsnapshot_conf_required=false

# reconfigure rsnapshot if config does not exist or is not sane
/usr/bin/rsnapshot -c "/data/rsnapshot.conf" configtest &>/dev/null || rsnapshot_conf_required=true

# reconfigure rsnapshot if any variables starting with RSNAPSHOT_CONF_ are set
for var in $(compgen -A variable | grep "^RSNAPSHOT_CONF_")
do
	[ -n "$(eval "echo \$${var}")" ] && rsnapshot_conf_required=true
done

# rsnapshot configuration is required for one of the above two reasons
if [ "${rsnapshot_conf_required}" == true ]
then
	echo "installing rsnapshot.conf..."
	cp -a "/etc/rsnapshot.conf" "/data/rsnapshot.conf"

	for var in $(compgen -A variable | grep "^RSNAPSHOT_CONF_")
	do
		if [ -n "$(eval "echo \$${var}")" ]
		then
			eval "echo +\$${var}"
			# convert spaces to tabs and append each value to the end of rsnapshot.conf
			spaces_to_tabs "$(eval "echo \$${var}")" >> "/data/rsnapshot.conf"
		fi
	done
fi

# test rsnapshot configuration syntax
echo "checking rsnapshot.conf..."
/usr/bin/rsnapshot -c "/data/rsnapshot.conf" configtest || exit 1

# print schedule in human readable format
echo "checking cron..."
# skip comment lines and whitespace lines
grep -v '^\s*#' "/etc/crontabs/root" | grep -v '^\s*$' | while IFS=$'\n' read -r line
do
	cmd="$(echo "${line}" | awk '{$1=$2=$3=$4=$5=""; print $0}' | sed -e 's/^[ \t]*//')"
	exp="$(echo "${line}" | awk '{print $1"+"$2"+"$3"+"$4"+"$5}')"

	sched="$(curl -s "https://cronexpressiondescriptor.azurewebsites.net/api/descriptor/?expression=${exp}&locale=en-US" | awk -F '"' '{print $4}')"

	echo "+${cmd} @ ${sched}"
done

# start services
supervisord -c "/etc/supervisord.conf"