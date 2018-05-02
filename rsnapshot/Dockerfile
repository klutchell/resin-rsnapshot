FROM resin/raspberrypi3-alpine

LABEL maintainer="kylemharding@gmail.com"

# allow building on x86
RUN cross-build-start || exit 0

# install cron, rsnapshot, openssh-client
RUN apk add --no-cache \
	curl \
	dcron \
	rsnapshot \
	openssh-client \
	tzdata

# create snapshots mount point
RUN mkdir /snapshots

# copy config files
COPY etc /etc

# copy start script
COPY start.sh /usr/bin/start.sh

# run start script on boot
CMD [ "/usr/bin/start.sh" ]

# end cross build
RUN cross-build-end || exit 0

