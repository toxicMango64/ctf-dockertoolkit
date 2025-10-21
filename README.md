# Security Toolkit Docker Container

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
