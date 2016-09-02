FROM alpine
MAINTAINER Daniel D <djx339@gmail.com>

RUN apk --no-cache --verbose add dnsmasq

COPY dnsmasq.conf  /etc/dnsmasq.conf
COPY linster.conf  /etc/linster.conf
COPY linster       /usr/bin/linster
COPY entrypoint.sh /entrypoint.sh

RUN chmod a+x /etc/linster.conf /usr/bin/linster /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
CMD ["start"]
