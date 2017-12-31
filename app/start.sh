#!/bin/bash

ssh_keys_dir="/data/keys"
rsnapshot_conf_file="/data/rsnapshot.conf"

# replace one or more spaces with a single tab
spaces_to_tabs()	{ echo "${1}" | sed 's| \+|\t|g' ; }

# create secure directory for ssh keys
if [ ! -d "${ssh_keys_dir}" ]
then
	mkdir -p "${ssh_keys_dir}"
	chmod 700 "${ssh_keys_dir}"
fi

# generate ssh key if one does not exist
if [ ! -f "${ssh_keys_dir}/id_rsa" ]
then
	echo "generating ssh key..."
	ssh-keygen -q -t "rsa" -N '' -f "${ssh_keys_dir}/id_rsa"
fi

# print the command to add this public key to remote hosts
echo "reading ssh key..."
echo "run this command on remote hosts:"
echo "echo '$(cat "${ssh_keys_dir}/id_rsa.pub")' >> ~/.ssh/authorized_keys"

rsnapshot_conf_required=false

# reconfigure rsnapshot if config does not exist or is not sane
/usr/bin/rsnapshot -c "${rsnapshot_conf_file}" configtest &>/dev/null || rsnapshot_conf_required=true

# reconfigure rsnapshot if any variables starting with RSNAPSHOT_CONF_ are set
for var in $(compgen -A variable | grep "^RSNAPSHOT_CONF_")
do
	[ -n "$(eval "echo \$${var}")" ] && rsnapshot_conf_required=true
done

# rsnapshot configuration is required for one of the above two reasons
if [ "${rsnapshot_conf_required}" == true ]
then
	echo "installing rsnapshot.conf..."
	cp -a "/usr/src/app/rsnapshot.conf" "${rsnapshot_conf_file}"

	for var in $(compgen -A variable | grep "^RSNAPSHOT_CONF_")
	do
		if [ -n "$(eval "echo \$${var}")" ]
		then
			eval "echo +\$${var}"
			# convert spaces to tabs and append each value to the end of rsnapshot.conf
			spaces_to_tabs "$(eval "echo \$${var}")" >> "${rsnapshot_conf_file}"
		fi
	done
fi

# test rsnapshot configuration syntax
echo "checking rsnapshot.conf..."
/usr/bin/rsnapshot -c "${rsnapshot_conf_file}" configtest || exit 1

# install cron.d file
echo "checking crontab..."

# print cron schedules in human readable format
while IFS=$'\n' read -r line
do
	exp="$(echo "${line}" | awk '{print $1"+"$2"+"$3"+"$4"+"$5}')"
	cmd="$(echo "${line}" | awk '{print $6}')"
	level="$(echo "${line}" | awk '{print $7}')"

	[ "${cmd}" == "/usr/src/app/job.sh" ] || continue

	sched="$(curl -s "https://cronexpressiondescriptor.azurewebsites.net/api/descriptor/?expression=${exp}&locale=en-US" | awk -F '"' '{print $4}')"

	echo "+${level}: ${sched}"
done < <(crontab -l)

echo "ready" && exit 0
