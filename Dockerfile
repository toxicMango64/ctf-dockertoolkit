# Build stage for Go tools
FROM debian:stable-slim AS go-builder

ENV DEBIAN_FRONTEND=noninteractive \
	GOPATH=/opt/go \
	PATH="/usr/local/go/bin:${PATH}"

RUN apt-get update && apt-get install -y --no-install-recommends \
	ca-certificates \
	wget \
	git \
	&& rm -rf /var/lib/apt/lists/*

RUN ARCH=$(dpkg --print-architecture) && \
	GO_VERSION="1.23.4" && \
	wget -q https://go.dev/dl/go${GO_VERSION}.linux-${ARCH}.tar.gz && \
	tar -C /usr/local -xzf go${GO_VERSION}.linux-${ARCH}.tar.gz && \
	rm go${GO_VERSION}.linux-${ARCH}.tar.gz

RUN git clone --depth 1 https://github.com/ffuf/ffuf /tmp/ffuf && \
	cd /tmp/ffuf && \
	go build -ldflags="-s -w" -o /usr/local/bin/ffuf && \
	rm -rf /tmp/ffuf

RUN git clone --depth 1 https://github.com/OJ/gobuster /tmp/gobuster && \
	cd /tmp/gobuster && \
	go build -ldflags="-s -w" -o /usr/local/bin/gobuster && \
	rm -rf /tmp/gobuster

# Build stage for John the Ripper
FROM debian:stable-slim AS john-builder

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y --no-install-recommends \
	ca-certificates \
	build-essential \
	libssl-dev \
	yasm \
	libgmp-dev \
	libpcap-dev \
	libbz2-dev \
	zlib1g-dev \
	git \
	&& rm -rf /var/lib/apt/lists/*

RUN git clone --depth 1 https://github.com/openwall/john /opt/john && \
	cd /opt/john/src && \
	./configure && \
	make -j$(nproc) && \
	strip /opt/john/run/john

# Final stage
FROM debian:stable-slim

LABEL maintainer="security-toolkit"
LABEL description="Security testing toolkit with web fuzzers and password crackers"

ENV DEBIAN_FRONTEND=noninteractive \
	JOHN_PATH=/opt/john/run \
	PATH="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/opt/john/run"

RUN apt-get update && apt-get install -y --no-install-recommends \
	ca-certificates \
	curl \
	wget \
	git \
	nano \
	python3-dev \
	python3-pip \
	dirb \
	libcurl4-openssl-dev \
	python3-pycurl \
	libssl-dev \
	libgmp-dev \
	libpcap-dev \
	libbz2-dev \
	zlib1g-dev \
	ocl-icd-libopencl1 \
	p7zip-full \
	libgomp1 \
	&& apt-get install -y wfuzz || echo "wfuzz not available in apt, skipping" \
	&& rm -rf /var/lib/apt/lists/*

COPY --from=go-builder /usr/local/bin/ffuf /usr/local/bin/ffuf
COPY --from=go-builder /usr/local/bin/gobuster /usr/local/bin/gobuster

COPY --from=john-builder /opt/john /opt/john

# Create a wrapper script for John that preserves current directory
RUN printf '#!/bin/bash\nSAVEDIR="$(pwd)"\ncd /opt/john/run\n./john "$@"\nRET=$?\ncd "$SAVEDIR"\nexit $RET\n' > /usr/local/bin/john && \
	chmod +x /usr/local/bin/john

RUN ARCH=$(dpkg --print-architecture) && \
	HASHCAT_VERSION="6.2.6" && \
	if [ "$ARCH" = "amd64" ]; then \
	HASHCAT_ARCH="linux64"; \
	elif [ "$ARCH" = "arm64" ]; then \
	HASHCAT_ARCH="linuxarm64"; \
	else \
	echo "Unsupported architecture: $ARCH"; exit 1; \
	fi && \
	cd /tmp && \
	curl -sSL https://github.com/hashcat/hashcat/releases/download/v${HASHCAT_VERSION}/hashcat-${HASHCAT_VERSION}.7z \
	-o hashcat.7z && \
	7z x hashcat.7z && \
	mv hashcat-${HASHCAT_VERSION} /opt/hashcat && \
	ln -s /opt/hashcat/hashcat.bin /usr/local/bin/hashcat && \
	rm -rf hashcat.7z

RUN pip3 install --no-cache-dir --break-system-packages \
	requests \
	beautifulsoup4 \
	selenium \
	paramiko \
	pycryptodome \
	scapy

# Create user and workspace
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
