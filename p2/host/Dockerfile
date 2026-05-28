FROM alpine:latest

RUN apk add --no-cache iproute2 iputils

COPY start-vxlan.sh /usr/local/bin/start-vxlan.sh
RUN chmod +x /usr/local/bin/start-vxlan.sh

CMD ["/bin/sh"]
