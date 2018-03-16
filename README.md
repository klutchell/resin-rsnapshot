# resin-rsnapshot

[resin.io](https://resin.io/) stack with the following services:
* [rsnapshot](http://rsnapshot.org/)

## Getting Started

* https://docs.resin.io/learn/getting-started
* http://rsnapshot.org/rsnapshot/docs/docbook/rest.html

## Deployment

```bash
git push resin master
```

## Usage

### Storage
A usb storage partition is expected at `/dev/sda1`. If found, it will be mounted
at startup to `/snapshots`. Otherwise rsnapshot will not run in order to
avoid filling the SD card.

### Backups
Any environment variables matching `RSNAPSHOT_CONF_*` will be appended
to `/etc/rsnapshot.conf` at startup.
```bash
# Example 1:
RSNAPSHOT_CONF_ex1="exclude media/movies"
RSNAPSHOT_CONF_ex2="exclude media/tv"
RSNAPSHOT_CONF_bak1="backup /home/ localhost/"
RSNAPSHOT_CONF_bak2="backup /etc/ localhost/"
RSNAPSHOT_CONF_bak3="backup /usr/local/ localhost/"
RSNAPSHOT_CONF_bak4="backup_script /data/backup_smb_share.sh 192.168.1.102/"
RSNAPSHOT_CONF_bak5="backup pi@192.168.1.101:/home/ 192.168.1.101/"
```

_avoid spaces except as a delimiter!_

### Schedule
The default backup levels are defined by `/etc/rsnapshot.conf`:
```
retain	alpha	6
retain	beta	7
retain	gamma	4
retain	delta	3
```

The default cron schedules are defined by `/etc/crontabs/root`:
```
alpha:	Every 4 hours
beta:	At 03:30 AM
gamma:	At 03:00 AM, only on Monday
delta:	At 02:30 AM, on day 1 of the month
```

## Author

Kyle Harding <kylemharding@gmail.com>

## License

_tbd_

## Acknowledgments

* https://github.com/resin-io-playground/cron-example
