#!/bin/bash

id_rsa_key="/data/keys/id_rsa"
ssh_conf_file="/root/.ssh/config"
rsnapshot_conf_file="/etc/rsnapshot.conf"
cron_file="/etc/cron.d/rsnapshot"

make_secure_dir()
{
	[ ! -e "${1}" ] && mkdir "${1}" && chmod 700 "${1}"
}

spaces_to_tabs()
{
	echo "${1}" | sed 's/ \+/\t/g'
}

if [ ! -f "${id_rsa_key}" ]
then
	echo "generating ssh key..."
	make_secure_dir "$(dirname "${id_rsa_key}")"
	ssh-keygen -q -t "rsa" -N '' -f "${id_rsa_key}"
fi

echo "configuring ssh..."
make_secure_dir "$(dirname "${ssh_conf_file}")"
cp "/usr/src/app/ssh.conf" "${ssh_conf_file}"
chmod 700 "${ssh_conf_file}"

echo "run this command on remote hosts:"
echo "echo '$(cat "${id_rsa_key}.pub")' >> ~/.ssh/authorized_keys"

echo "configuring rsnapshot..."
cp "/usr/src/app/rsnapshot.conf" "${rsnapshot_conf_file}"
chmod 755 "${rsnapshot_conf_file}"

[ -n "${BACKUP_POINT_0}" ] && spaces_to_tabs "${BACKUP_POINT_0}" >> "${rsnapshot_conf_file}"
[ -n "${BACKUP_POINT_1}" ] && spaces_to_tabs "${BACKUP_POINT_1}" >> "${rsnapshot_conf_file}"
[ -n "${BACKUP_POINT_2}" ] && spaces_to_tabs "${BACKUP_POINT_2}" >> "${rsnapshot_conf_file}"
[ -n "${BACKUP_POINT_3}" ] && spaces_to_tabs "${BACKUP_POINT_3}" >> "${rsnapshot_conf_file}"
[ -n "${BACKUP_POINT_4}" ] && spaces_to_tabs "${BACKUP_POINT_4}" >> "${rsnapshot_conf_file}"
[ -n "${BACKUP_POINT_5}" ] && spaces_to_tabs "${BACKUP_POINT_5}" >> "${rsnapshot_conf_file}"
[ -n "${BACKUP_POINT_6}" ] && spaces_to_tabs "${BACKUP_POINT_6}" >> "${rsnapshot_conf_file}"
[ -n "${BACKUP_POINT_7}" ] && spaces_to_tabs "${BACKUP_POINT_7}" >> "${rsnapshot_conf_file}"
[ -n "${BACKUP_POINT_8}" ] && spaces_to_tabs "${BACKUP_POINT_8}" >> "${rsnapshot_conf_file}"
[ -n "${BACKUP_POINT_9}" ] && spaces_to_tabs "${BACKUP_POINT_9}" >> "${rsnapshot_conf_file}"

/usr/bin/rsnapshot configtest || exit 1

echo "configuring cron..."
cp "/usr/src/app/rsnapshot.cron" "${cron_file}"
chmod 755 "${cron_file}"

for exp in $(cat /etc/cron.d/rsnapshot | grep 'root' | awk '{print $1"+"$2"+"$3"+"$4"+"$5}')
do
	curl "https://cronexpressiondescriptor.azurewebsites.net/api/descriptor/?expression=${exp}&locale=en-US"
	echo
done

echo "cron ready" && exit 0
