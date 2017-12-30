# resin-rsnapshot

resin.io rsnapshot application

based on https://github.com/resin-io-playground/cron-example

## Getting Started

https://docs.resin.io/raspberrypi3/nodejs/getting-started/#create-an-application

## Deployment

https://docs.resin.io/raspberrypi3/nodejs/getting-started/#deploy-code

## Usage

```bash
# define backup points with the following syntax
BACKUP_POINT_0="backup /home/	localhost/"
BACKUP_POINT_1="backup /etc/	localhost/"
BACKUP_POINT_2="backup /usr/local/	localhost/"

# there is no limit to the number of backup points
# as long as they start with BACKUP_POINT_ and
# are formatted correctly with 3 fields separated by tabs
```

## Author

Kyle Harding <kylemharding@gmail.com>

## License

_tbd_

## Acknowledgments

_tbd_
