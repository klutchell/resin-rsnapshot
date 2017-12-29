#!/bin/bash

id_rsa_key="/data/keys/id_rsa"
ssh_config_file="/root/.ssh/config"

make_secure_dir()
{
	[ ! d "${1}" ] && mkdir "${1}" && chmod 700 "${1}"
}

if [ ! -f "${id_rsa_key}" ]
then
	echo "generating ssh key..."
	make_secure_dir "$(dirname "${id_rsa_key}")"
	ssh-keygen -q -t "rsa" -N '' -f "${id_rsa_key}"
fi

make_secure_dir "$(dirname "${ssh_config_file}")"
echo "Host remotehost-rsnapshot" > "${ssh_config_file}"
echo "Hostname *" >> "${ssh_config_file}"
echo "IdentityFile ${id_rsa_key}" >> "${ssh_config_file}"

echo "public key data (add to remote host authorized_keys):"
cat "${id_rsa_key}.pub"

echo "writing rsnapshot config..."
cp "/usr/src/app/rsnapshot.conf" "/etc/rsnapshot.conf"
[ -n "${BACKUP_POINT_0}" ] && echo "${BACKUP_POINT_0}" | sed 's/ \+/\t/g' >> "/etc/rsnapshot.conf"
[ -n "${BACKUP_POINT_1}" ] && echo "${BACKUP_POINT_1}" | sed 's/ \+/\t/g' >> "/etc/rsnapshot.conf"
[ -n "${BACKUP_POINT_2}" ] && echo "${BACKUP_POINT_2}" | sed 's/ \+/\t/g' >> "/etc/rsnapshot.conf"
[ -n "${BACKUP_POINT_3}" ] && echo "${BACKUP_POINT_3}" | sed 's/ \+/\t/g' >> "/etc/rsnapshot.conf"
[ -n "${BACKUP_POINT_4}" ] && echo "${BACKUP_POINT_4}" | sed 's/ \+/\t/g' >> "/etc/rsnapshot.conf"
[ -n "${BACKUP_POINT_5}" ] && echo "${BACKUP_POINT_5}" | sed 's/ \+/\t/g' >> "/etc/rsnapshot.conf"
[ -n "${BACKUP_POINT_6}" ] && echo "${BACKUP_POINT_6}" | sed 's/ \+/\t/g' >> "/etc/rsnapshot.conf"
[ -n "${BACKUP_POINT_7}" ] && echo "${BACKUP_POINT_7}" | sed 's/ \+/\t/g' >> "/etc/rsnapshot.conf"
[ -n "${BACKUP_POINT_8}" ] && echo "${BACKUP_POINT_8}" | sed 's/ \+/\t/g' >> "/etc/rsnapshot.conf"
[ -n "${BACKUP_POINT_9}" ] && echo "${BACKUP_POINT_9}" | sed 's/ \+/\t/g' >> "/etc/rsnapshot.conf"

echo "scheduling cron jobs..."
echo "0 */4 * * * /usr/src/app/job.sh alpha" | crontab
echo "30 30 * * * /usr/src/app/job.sh beta" | crontab
echo "0 3 * * 1 /usr/src/app/job.sh gamma" | crontab
echo "30 2 1 * * /usr/src/app/job.sh delta" | crontab
crontab -l
