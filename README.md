# resin-rsnapshot

resin.io rsnapshot application

## Getting Started

https://docs.resin.io/raspberrypi3/nodejs/getting-started

## Deployment

Define additional rsnapshot config entries with the following syntax:
```bash
# Example 1:
RSNAPSHOT_CONF_ex1="exclude media/movies"
RSNAPSHOT_CONF_ex2="exclude media/tv"
RSNAPSHOT_CONF_bak1="backup /home/ localhost/"
RSNAPSHOT_CONF_bak2="backup /etc/ localhost/"
RSNAPSHOT_CONF_bak3="backup /usr/local/ localhost/"
RSNAPSHOT_CONF_bak4="backup_script /data/backup_smb_share.sh 192.168.86.102/"
RSNAPSHOT_CONF_bak5="backup pi@192.168.86.101:/home/ 192.168.86.101/"
```

Any environment variable matching `RSNAPSHOT_CONF_` will be appended to `rsnapshot.conf`

_avoid spaces except as a delimiter_

The default backup levels are defined by `rsnapshot.conf`:
```
retain	alpha	6
retain	beta	7
retain	gamma	4
retain	delta	3
```

The default cron schedules are defined by `cron.conf`:
```
alpha:	Every 4 hours
beta:	At 03:30 AM
gamma:	At 03:00 AM, only on Monday
delta:	At 02:30 AM, on day 1 of the month
```

## Usage

http://rsnapshot.org/rsnapshot/docs/docbook/rest.html

For samba access to the data dir go to `//<device-ip>/data`.

The default credentials are `root:alpine`.

## Author

Kyle Harding <kylemharding@gmail.com>

## License

_tbd_

## Acknowledgments

* https://github.com/resin-io-playground/cron-example
