FROM ubuntu:20.04

LABEL maintainer="Julio Gutierrez julio.guti+nordlynx@pm.me"
ENV DEBIAN_FRONTEND="noninteractive"
ARG WIREGUARD_RELEASE

COPY install.sh /usr/bin

RUN \
 echo "**** install dependencies ****" && \
 apt-get update && \
 apt-get install -y --no-install-recommends \
	bc \
	build-essential \
    ca-certificates \
	curl \
	dkms \
	git \
	gnupg \
	ifupdown \
	iproute2 \
	iptables \
	iputils-ping \
	jq \
	libc6 \
	libelf-dev \
	net-tools \
    openresolv \
	perl \
	pkg-config
RUN echo "**** install wireguard-tools ****" && \
 if [ -z ${WIREGUARD_RELEASE+x} ]; then \
	WIREGUARD_RELEASE=$(curl -sX GET "https://api.github.com/repos/WireGuard/wireguard-tools/tags" | jq -r .[0].name); \
 fi && \
 mkdir /app && \
 cd /app && \
 git clone https://git.zx2c4.com/wireguard-linux-compat && \
 git clone https://git.zx2c4.com/wireguard-tools && \
 cd wireguard-tools && \
 git checkout "${WIREGUARD_RELEASE}" && \
 make -C src -j$(nproc) && \
 make -C src install && \
 chmod +x /usr/bin/install.sh && \
 echo "**** clean up ****" && \
 rm -rf \
    /patch \
	/tmp/* \
	/var/lib/apt/lists/* \
	/var/tmp/*

CMD /usr/bin/install.sh