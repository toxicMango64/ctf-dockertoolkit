#!/bin/bash

echo "==================================="
echo "Security Toolkit - Tool Verification"
echo "==================================="
echo ""

echo "Testing ffuf..."
docker run --rm security-toolkit:latest ffuf -V
echo ""

echo "Testing gobuster..."
docker run --rm security-toolkit:latest gobuster version 2>&1 | head -3
echo ""

echo "Testing dirb..."
docker run --rm security-toolkit:latest bash -c "which dirb && dirb 2>&1 | head -5"
echo ""

echo "Testing John the Ripper..."
docker run --rm security-toolkit:latest /opt/john/run/john 2>&1 | head -5
echo ""

echo "Testing hashcat..."
docker run --rm security-toolkit:latest hashcat --version 2>&1 | head -3
echo ""

echo "Testing Python..."
docker run --rm security-toolkit:latest python3 --version
echo ""

echo "Testing Go..."
docker run --rm security-toolkit:latest go version
echo ""

echo "==================================="
echo "All tools verified!"
echo "==================================="
echo ""
echo "To use the container interactively:"
echo "  docker run -it -v \"\$(pwd)\":/workspace security-toolkit:latest"
echo ""
echo "Note: John the Ripper is located at /opt/john/run/john"
echo "      You can create an alias: alias john='/opt/john/run/john'"
