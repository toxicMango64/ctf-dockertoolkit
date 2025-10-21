# Project Requirements: Security Toolkit Docker Image

## Overview
Create a lightweight Docker image that bundles essential security testing tools for web fuzzing, password cracking, and development.

## Tools to Include

### Web Fuzzers
- **ffuf** - Fast web fuzzer written in Go
- **gobuster** - Directory/file & DNS busting tool
- **dirb** - Web content scanner
- **wfuzz** - Web application fuzzer

### Password Crackers
- **John the Ripper** - Password cracking tool
- **hashcat** - Advanced password recovery (CPU mode)

### Development Tools
- **Python 3** with pip
- **Go** runtime and compiler
- **git**, **curl**, **wget**
- **nano** text editor

## Docker Configuration Requirements

- **Base Image**: Use a minimal Linux distribution (e.g., `debian:stable-slim` or `alpine:latest`)
- **Working Directory**: Set container workdir to `/workspace`
- **Volume Mounting**: Mount the current host directory to `/workspace` in the container
- **User Permissions**: Run as non-root user where possible for security
- **Package Management**: Install all tools via official package repositories when available

## Usage Example
```bash
docker run -it -v "$(pwd)":/workspace security-toolkit:latest
```

## Deliverables
- `Dockerfile` that builds the specified image
- Basic documentation on tool usage within the container