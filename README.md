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
There are no backup points enabled by default.

To add backup points, create environment variables in the Resin.io Application starting
with `RSNAPSHOT_CONF_`.

Any environment variables matching `RSNAPSHOT_CONF_*` will be appended
to `/etc/rsnapshot.conf` at startup.

```bash
# Examples:
RSNAPSHOT_CONF_local1="backup /home/ localhost/"
RSNAPSHOT_CONF_local2="backup /etc/ localhost/"
RSNAPSHOT_CONF_local3="backup /usr/local/ localhost/"
RSNAPSHOT_CONF_pi="backup pi@192.168.1.101:/home/ 192.168.1.101/"
RSNAPSHOT_CONF_ex1="exclude media/movies"
RSNAPSHOT_CONF_ex2="exclude media/tv"
```

_avoid spaces except as a delimiter!_

### Schedule

The default rsnapshot schedules are defined by `/etc/crontabs/root`:
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
