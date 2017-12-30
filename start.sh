#!/bin/bash

id_rsa_key="/data/keys/id_rsa"
ssh_conf_file="/root/.ssh/config"
rsnapshot_conf_file="/etc/rsnapshot.conf"
cron_file="/etc/cron.d/rsnapshot"

make_secure_dir()
{
	[ ! -e "${1}" ] && mkdir "${1}" && chmod 700 "${1}"
}

if [ ! -f "${id_rsa_key}" ]
then
	echo "generating ssh key..."
	make_secure_dir "$(dirname "${id_rsa_key}")"
	ssh-keygen -q -t "rsa" -N '' -f "${id_rsa_key}"
fi

echo "configuring ssh..."
make_secure_dir "$(dirname "${ssh_config_file}")"
cp "/usr/src/app/ssh.conf" "${ssh_config_file}"

echo "run this command on remote hosts:"
echo "'echo \"$(cat "${id_rsa_key}.pub")\" >> ~/.ssh/authorized_keys'"

echo "configuring rsnapshot..."
cp "/usr/src/app/rsnapshot.conf" "${rsnapshot_conf_file}"

[ -n "${BACKUP_POINT_0}" ] && echo "${BACKUP_POINT_0}" | sed 's/ \+ /\t/g' >> "${rsnapshot_conf_file}"
[ -n "${BACKUP_POINT_1}" ] && echo "${BACKUP_POINT_1}" | sed 's/ \+ /\t/g' >> "${rsnapshot_conf_file}"
[ -n "${BACKUP_POINT_2}" ] && echo "${BACKUP_POINT_2}" | sed 's/ \+ /\t/g' >> "${rsnapshot_conf_file}"
[ -n "${BACKUP_POINT_3}" ] && echo "${BACKUP_POINT_3}" | sed 's/ \+ /\t/g' >> "${rsnapshot_conf_file}"
[ -n "${BACKUP_POINT_4}" ] && echo "${BACKUP_POINT_4}" | sed 's/ \+ /\t/g' >> "${rsnapshot_conf_file}"
[ -n "${BACKUP_POINT_5}" ] && echo "${BACKUP_POINT_5}" | sed 's/ \+ /\t/g' >> "${rsnapshot_conf_file}"
[ -n "${BACKUP_POINT_6}" ] && echo "${BACKUP_POINT_6}" | sed 's/ \+ /\t/g' >> "${rsnapshot_conf_file}"
[ -n "${BACKUP_POINT_7}" ] && echo "${BACKUP_POINT_7}" | sed 's/ \+ /\t/g' >> "${rsnapshot_conf_file}"
[ -n "${BACKUP_POINT_8}" ] && echo "${BACKUP_POINT_8}" | sed 's/ \+ /\t/g' >> "${rsnapshot_conf_file}"
[ -n "${BACKUP_POINT_9}" ] && echo "${BACKUP_POINT_9}" | sed 's/ \+ /\t/g' >> "${rsnapshot_conf_file}"

/usr/bin/rsnapshot configtest

echo "configuring cron..."
cp "/usr/src/app/rsnapshot.cron" "${cron_file}"
