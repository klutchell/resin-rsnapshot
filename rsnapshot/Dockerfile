FROM resin/raspberrypi3-alpine

# set timezone
RUN apk add --no-cache tzdata
ENV TZ=America/Toronto

# install cron, rsnapshot, openssh-client
RUN apk add --no-cache \
	curl \
	dcron \
	rsnapshot \
	openssh-client

# create snapshots mount point
RUN mkdir /snapshots

COPY etc /etc

COPY start.sh /usr/bin/start.sh

CMD [ "/usr/bin/start.sh" ]

