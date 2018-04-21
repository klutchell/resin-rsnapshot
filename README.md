# resin-rsnapshot

[resin.io](https://resin.io/) stack with the following services:
* [rsnapshot backups](http://rsnapshot.org/)
* [ssh server](https://www.ssh.com/ssh/)

## Getting Started

* https://docs.resin.io/learn/getting-started

## Deployment

```yaml
# example docker-compose.yml
version: '2.1'

volumes:

  ssh-data:

services:

  rsnapshot:
    build: ./rsnapshot
    privileged: true
    volumes:
      - 'ssh-data:/root/.ssh'

  ssh:
    build: ./ssh
    ports:
      - '22:22'
    volumes:
      - 'ssh-data:/root/.ssh'
```

## Usage

* [ssh](ssh/README.md)
* [rsnapshot](rsnapshot/README.md)

## Author

Kyle Harding <kylemharding@gmail.com>

## License

_tbd_

## Acknowledgments

* https://github.com/diginc/docker-pi-hole
