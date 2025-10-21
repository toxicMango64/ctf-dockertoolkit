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
	p7zip-full


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

RUN apt-get install -y --no-install-recommends dirb libcurl4-openssl-dev python3-pycurl && \
	apt-get install -y wfuzz || echo "wfuzz not available in apt, skipping"

RUN apt-get install -y --no-install-recommends \
	libssl-dev \
	yasm \
	libgmp-dev \
	libpcap-dev \
	libbz2-dev \
	&& git clone https://github.com/openwall/john /opt/john && \
	cd /opt/john/src && \
	./configure && \
	make -s clean && make -j$(nproc) && \
	ln -s /opt/john/run/john /usr/local/bin/john


# HASHCAT DEBUGGING

# # RUN apt-get install -y --no-install-recommends \
# # 	ocl-icd-libopencl1 \
# # 	pocl-opencl-icd \
# # 	&& git clone https://github.com/hashcat/hashcat /tmp/hashcat && \
# RUN git clone https://github.com/hashcat/hashcat /tmp/hashcat && \
# 	cd /tmp/hashcat && \
# 	make && \
# 	make install && \
# 	rm -rf /tmp/hashcat

# # Multi-stage: extract in builder, copy to final
# FROM debian:stable-slim AS hashcat-builder
# RUN apt-get update && apt-get install -y --no-install-recommends curl p7zip-full && rm -rf /var/lib/apt/lists/*
# ARG HASHCAT_VERSION=6.2.6
# RUN ARCH=$(dpkg --print-architecture) && \
#     HASHCAT_ARCH="linux64" && [ "$ARCH" = "arm64" ] && HASHCAT_ARCH="linuxarm64" || true && \
#     cd /tmp && \
#     curl -sSL https://github.com/hashcat/hashcat/releases/download/v${HASHCAT_VERSION}/hashcat-${HASHCAT_VERSION}.7z -o hashcat.7z && \
#     7z x hashcat.7z && \
#     mv hashcat-${HASHCAT_VERSION} /out

# # In your main image:
# COPY --from=hashcat-builder /out /opt/hashcat
# RUN ln -s /opt/hashcat/hashcat.bin /usr/local/bin/hashcat

# Install minimal OpenCL runtime (only what's needed for hashcat binary)
RUN apt-get update && apt-get install -y --no-install-recommends \
    ocl-icd-libopencl1 \
    && rm -rf /var/lib/apt/lists/*

# Download and install prebuilt hashcat binary
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
    apt-get update && apt-get install -y --no-install-recommends p7zip-full && \
    7z x hashcat.7z && \
    mv hashcat-${HASHCAT_VERSION} /opt/hashcat && \
    ln -s /opt/hashcat/hashcat.bin /usr/local/bin/hashcat && \
    rm -rf hashcat.7z && \
    apt-get purge -y p7zip-full && \
    apt-get autoremove -y && \
    rm -rf /var/lib/apt/lists/*


RUN pip3 install --no-cache-dir --break-system-packages \
	requests \
	beautifulsoup4 \
	selenium \
	paramiko \
	pycryptodome \
	scapy \
	&& rm -rf /var/lib/apt/lists/*

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
