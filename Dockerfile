FROM debian:stable-slim

LABEL maintainer="security-toolkit"
LABEL description="Security testing toolkit with web fuzzers and password crackers"

ENV DEBIAN_FRONTEND=noninteractive \
	GOPATH=/opt/go \
	PATH="/opt/go/bin:/usr/local/go/bin:${PATH}" \
	JOHN_PATH=/opt/john/run

RUN apt-get update && apt-get install -y --no-install-recommends \
	ca-certificates \
	curl \
	wget \
	git \
	nano \
	build-essential \
	libssl-dev \
	zlib1g-dev \
	libbz2-dev \
	libreadline-dev \
	libsqlite3-dev \
	libncurses5-dev \
	libncursesw5-dev \
	xz-utils \
	tk-dev \
	libffi-dev \
	liblzma-dev \
	python3-dev \
	python3-pip \
	pkg-config \
	libpcap-dev \
	&& rm -rf /var/lib/apt/lists/*


RUN ARCH=$(dpkg --print-architecture) && \
	GO_VERSION="1.23.4" && \
	wget -q https://go.dev/dl/go${GO_VERSION}.linux-${ARCH}.tar.gz && \
	tar -C /usr/local -xzf go${GO_VERSION}.linux-${ARCH}.tar.gz && \
	rm go${GO_VERSION}.linux-${ARCH}.tar.gz

RUN git clone https://github.com/ffuf/ffuf /tmp/ffuf && \
	cd /tmp/ffuf && \
	go build -o /usr/local/bin/ffuf && \
	rm -rf /tmp/ffuf

RUN git clone https://github.com/OJ/gobuster /tmp/gobuster && \
	cd /tmp/gobuster && \
	go build -o /usr/local/bin/gobuster && \
	rm -rf /tmp/gobuster

RUN apt-get update && apt-get install -y --no-install-recommends dirb libcurl4-openssl-dev python3-pycurl && \
	apt-get install -y wfuzz || echo "wfuzz not available in apt, skipping" && \
	rm -rf /var/lib/apt/lists/*

RUN apt-get update && apt-get install -y --no-install-recommends \
	libssl-dev \
	yasm \
	libgmp-dev \
	libpcap-dev \
	libbz2-dev \
	&& rm -rf /var/lib/apt/lists/* && \
	git clone https://github.com/openwall/john /opt/john && \
	cd /opt/john/src && \
	./configure && \
	make -s clean && make -j$(nproc) && \
	ln -s /opt/john/run/john /usr/local/bin/john

RUN apt-get update && apt-get install -y --no-install-recommends \
	ocl-icd-libopencl1 \
	pocl-opencl-icd \
	&& rm -rf /var/lib/apt/lists/* && \
	git clone https://github.com/hashcat/hashcat /tmp/hashcat && \
	cd /tmp/hashcat && \
	make && \
	make install && \
	rm -rf /tmp/hashcat

RUN pip3 install --no-cache-dir --break-system-packages \
	requests \
	beautifulsoup4 \
	selenium \
	paramiko \
	pycryptodome \
	scapy

RUN useradd -m -s /bin/bash secuser && \
	mkdir -p /workspace && \
	chown -R secuser:secuser /workspace

WORKDIR /workspace

USER secuser

RUN echo '#!/bin/bash\n\
	echo "Available Tools:"\n\
	echo "    - ffuf (fast web fuzzer)"\n\
	echo "    - gobuster (directory/DNS busting)"\n\
	echo "    - dirb (web content scanner)"\n\
	echo "    - wfuzz (web application fuzzer)"\n\
	echo ""\n\
	echo "    - john (John the Ripper)"\n\
	echo "    - hashcat (advanced password recovery)"\n\
	echo ""\n\
	echo "    - python3, pip3"\n\
	echo "    - go"\n\
	echo "    - git, curl, wget, nano"\n\
	echo ""\n\
	exec /bin/bash' > /home/secuser/.startup.sh && \
	chmod +x /home/secuser/.startup.sh

CMD ["/home/secuser/.startup.sh"]
