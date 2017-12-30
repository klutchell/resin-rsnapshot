#!/bin/bash

id_rsa_key="/data/keys/id_rsa"
ssh_conf_file="/root/.ssh/config"
rsnapshot_conf_file="/data/rsnapshot.conf"
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
cp -a "/usr/src/app/ssh.conf" "${ssh_conf_file}"

echo "run this command on remote hosts:"
echo "echo '$(cat "${id_rsa_key}.pub")' >> ~/.ssh/authorized_keys"

rsnapshot_conf_required=false

# if rsnapshot.conf does not exist or is not sane...
/usr/bin/rsnapshot -c "${rsnapshot_conf_file}" configtest || rsnapshot_conf_required=true

# if any variable similar to RSNAPSHOT_CONF_ is set...
for var in $(compgen -A variable | grep "^RSNAPSHOT_CONF_")
do
	[ -n "$(eval "echo \$${var}")" ] && rsnapshot_conf_required=true
done

if [ "${rsnapshot_conf_required}" == true ]
then
	echo "configuring rsnapshot..."
	cp -a "/usr/src/app/rsnapshot.conf" "${rsnapshot_conf_file}"

	for var in $(compgen -A variable | grep "^RSNAPSHOT_CONF_")
	do
		if [ -n "$(eval "echo \$${var}")" ]
		then
			eval "echo +\$${var}"
			spaces_to_tabs "$(eval "echo \$${var}")" >> "${rsnapshot_conf_file}"
		fi
	done
fi

/usr/bin/rsnapshot -c "${rsnapshot_conf_file}" configtest || exit 1

echo "configuring cron..."
cp -a "/usr/src/app/rsnapshot.cron" "${cron_file}"

IFS=$'\n'
for schedule in $(cat /etc/cron.d/rsnapshot | grep 'root')
do
	exp="$(echo "${schedule}" | awk '{print $1"+"$2"+"$3"+"$4"+"$5}')"
	user="$(echo "${schedule}" | awk '{print $6}')"
	cmd="$(echo "${schedule}" | awk '{print $7}')"
	param="$(echo "${schedule}" | awk '{print $8}')"
	when="$(curl -s "https://cronexpressiondescriptor.azurewebsites.net/api/descriptor/?expression=${exp}&locale=en-US" | awk -F '"' '{print $4}')"
	echo "+${param}: ${when}"
done
unset IFS

echo "cron ready" && exit 0
