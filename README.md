# Security Toolkit Docker Container

## Overview
This Docker container provides a comprehensive security testing toolkit with web fuzzers, password crackers, and development tools.

## Included Tools

### Web Fuzzers
- **ffuf**: Fast web fuzzer for discovering hidden files and directories
  ```bash
  ffuf -u http://example.com/FUZZ -w wordlist.txt
  ```

- **gobuster**: Directory/file & DNS busting tool
  ```bash
  gobuster dir -u http://example.com -w wordlist.txt
  ```

- **dirb**: Web content scanner
  ```bash
  dirb http://example.com /usr/share/dirb/wordlists/common.txt
  ```

- **wfuzz**: Web application fuzzer
  ```bash
  wfuzz -w wordlist.txt http://example.com/FUZZ
  ```

### Password Crackers
- **John the Ripper**: Password cracking tool
  ```bash
  john --wordlist=/path/to/wordlist.txt hashfile.txt
  ```

- **hashcat**: Advanced password recovery
  ```bash
  hashcat -m 0 -a 0 hashfile.txt wordlist.txt
  ```

### Development Tools
- Python 3 with pip (includes: requests, beautifulsoup4, selenium, paramiko, pycryptodome, scapy)
- Go runtime and compiler
- git, curl, wget
- nano text editor

## Building the Image

```bash
docker build -t security-toolkit:latest .
```

Note: The build process will take some time as several tools are compiled from source for optimal performance.

## Running the Container

### Interactive Mode (Recommended)
```bash
docker run -it -v "$(pwd)":/workspace security-toolkit:latest
```

### Run with Specific Command
```bash
docker run --rm -v "$(pwd)":/workspace security-toolkit:latest ffuf -h
```

### Mount Custom Directory
```bash
docker run -it -v /path/to/your/files:/workspace security-toolkit:latest
```

## Security Features
- Runs as non-root user (secuser) for enhanced security
- Minimal base image (Debian stable-slim)
- Working directory: `/workspace`
- Tools installed from official sources

## Tips
- Always mount a volume to `/workspace` to persist your work
- Use the interactive mode for the best experience
- The container automatically displays available tools on startup

## Examples

### Example 1: Directory Fuzzing
```bash
docker run --rm -v "$(pwd)":/workspace security-toolkit:latest \
  ffuf -u http://testsite.com/FUZZ -w /path/to/wordlist.txt
```

### Example 2: Password Cracking
```bash
docker run --rm -v "$(pwd)":/workspace security-toolkit:latest \
  john --wordlist=wordlist.txt hashes.txt
```

## Troubleshooting
- If you encounter permission issues, ensure the mounted directory has appropriate permissions
- For GPU acceleration with hashcat, additional Docker runtime configuration is required
- Tools are accessible from any directory within the container
