FROM alpine:latest

RUN apk update && apk add --no-cache \
    frr \
    frr-openrc \
    bash \
    busybox-extras \
    iproute2 \
    iputils \
    tcpdump \
    vim

RUN sed -i 's/bgpd=no/bgpd=yes/' /etc/frr/daemons && \
    sed -i 's/ospfd=no/ospfd=yes/' /etc/frr/daemons && \
    sed -i 's/isisd=no/isisd=yes/' /etc/frr/daemons && \
    sed -i 's/zebra=no/zebra=yes/' /etc/frr/daemons

COPY start-vxlan.sh /usr/local/bin/start-vxlan.sh
RUN chmod +x /usr/local/bin/start-vxlan.sh

CMD ["/bin/bash"]
