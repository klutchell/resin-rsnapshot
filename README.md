# resin-rsnapshot

resin.io rsnapshot application

## Getting Started

https://docs.resin.io/raspberrypi3/nodejs/getting-started

## Deployment

Define additional rsnapshot config entries with the following syntax:
```bash
# Example 1:
RSNAPSHOT_CONF_0="backup  /home/  localhost/"
RSNAPSHOT_CONF_1="backup  /etc/  localhost/"
RSNAPSHOT_CONF_2="backup  /usr/local/  localhost/"
RSNAPSHOT_CONF_3="exclude  media/movies"
RSNAPSHOT_CONF_4="exclude  media/tv"
```

* any environment variable matching `RSNAPSHOT_CONF_` will be appended to `rsnapshot.conf`
* avoid spaces except between values

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

## Usage

http://troy.jdmz.net/rsnapshot/

## Author

Kyle Harding <kylemharding@gmail.com>

## License

_tbd_

## Acknowledgments

* https://github.com/resin-io-playground/cron-example
