#!/bin/bash

readonly ssh_config_dir="/data/.ssh"
readonly rsnapshot_conf_file="/data/rsnapshot.conf"

# replace one or more spaces with a single tab
spaces_to_tabs()	{ echo "${1}" | sed 's| \+|\t|g' ; }

# create ssh config dir if it does not exist
mkdir -p "${ssh_config_dir}" 2>/dev/null || true

# set permissions on ssh config dir
chmod -R 700 "${ssh_config_dir}"

# generate ssh key if one does not exist
if [ ! -f "${ssh_config_dir}/id_rsa" ]
then
	echo "generating ssh key..."
	ssh-keygen -q -t "rsa" -N '' -f "${ssh_config_dir}/id_rsa"
fi

# print the command to add this public key to remote hosts
echo "reading ssh key..."
echo "run this command on remote hosts:"
echo "echo '$(cat "${ssh_config_dir}/id_rsa.pub")' >> ~/.ssh/authorized_keys"

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
	cp -a "/config/rsnapshot.conf" "${rsnapshot_conf_file}"

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

# print schedule in human readable format
echo "checking cron..."
# skip comment lines and whitespace lines
grep -v '^\s*#' "/etc/crontabs/root" | grep -v '^\s*$' | while IFS=$'\n' read -r line
do
	cmd="$(echo "${line}" | awk '{$1=$2=$3=$4=$5=""; print $0}')"
	exp="$(echo "${line}" | awk '{print $1"+"$2"+"$3"+"$4"+"$5}')"

	sched="$(curl -s "https://cronexpressiondescriptor.azurewebsites.net/api/descriptor/?expression=${exp}&locale=en-US" | awk -F '"' '{print $4}')"

	echo "+${cmd} @ ${sched}"
done

if [ ! -f "/data/backup_smb_share.sh" ]
then
	cp "/usr/src/app/backup_smb_share.sh.example" "/data/backup_smb_share.sh"
	chmod +x "/data/backup_smb_share.sh"
fi

supervisord -c /config/supervisord.conf
