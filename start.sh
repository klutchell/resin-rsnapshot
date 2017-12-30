#!/bin/bash

id_rsa_key="/data/keys/id_rsa"
ssh_conf_file="/root/.ssh/config"
rsnapshot_conf_file="/data/rsnapshot.conf"
cron_file="/etc/cron.d/rsnapshot"

# if dir does not exist, create it and set user-only perms
make_secure_dir()
{
	[ ! -e "${1}" ] && mkdir "${1}" && chmod 700 "${1}"
}

# replace one or more spaces with a single tab
spaces_to_tabs()
{
	echo "${1// \+/\t}"
}

# generate ssh key if one does not exist
if [ ! -f "${id_rsa_key}" ]
then
	echo "generating ssh key..."
	make_secure_dir "$(dirname "${id_rsa_key}")"
	ssh-keygen -q -t "rsa" -N '' -f "${id_rsa_key}"
fi

# install ssh config file that specifies which key to use for all hosts
echo "configuring ssh..."
make_secure_dir "$(dirname "${ssh_conf_file}")"
cp -a "/usr/src/app/ssh.conf" "${ssh_conf_file}"

# print the command to add this public key to remote hosts
echo "run this command on remote hosts:"
echo "echo '$(cat "${id_rsa_key}.pub")' >> ~/.ssh/authorized_keys"

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
	echo "configuring rsnapshot..."
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
/usr/bin/rsnapshot -c "${rsnapshot_conf_file}" configtest || exit 1

# install cron.d file
echo "configuring cron..."
cp -a "/usr/src/app/rsnapshot.cron" "${cron_file}"

# print cron schedules in human readable format
while IFS=$'\n' read -r line
do
	user="$(echo "${line}" | awk '{print $6}')"
	cmd="$(echo "${line}" | awk '{print $7}')"
	level="$(echo "${line}" | awk '{print $8}')"
	exp="$(echo "${line}" | awk '{print $1"+"$2"+"$3"+"$4"+"$5}')"

	[ "${user}+${cmd}" == "root+/usr/src/app/job.sh" ] || continue

	sched="$(curl -s "https://cronexpressiondescriptor.azurewebsites.net/api/descriptor/?expression=${exp}&locale=en-US" | awk -F '"' '{print $4}')"

	echo "+${level}: ${sched}"
done < "${cron_file}"

echo "cron ready" && exit 0
