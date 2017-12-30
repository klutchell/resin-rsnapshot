# resin-rsnapshot

resin.io rsnapshot application

## Getting Started

https://docs.resin.io/raspberrypi3/nodejs/getting-started

## Deployment

Define backup points with the following syntax:
```bash
BACKUP_POINT_0="backup /home/	localhost/"
BACKUP_POINT_1="backup /etc/	localhost/"
BACKUP_POINT_2="backup /usr/local/	localhost/"
```

There is no limit to the number of backup points
as long as they start with BACKUP_POINT_ and
are formatted as 3 fields separated by tabs.

## Usage

The default backup levels are defined by `rsnapshot.conf`:
```
retain	alpha	6
retain	beta	7
retain	gamma	4
retain	delta	3
```

The default cron schedules are defined by `rsnapshot.cron`:
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
