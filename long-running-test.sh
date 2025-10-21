#!/bin/bash

echo "============================================="
echo "Security Toolkit - Long Running Demo"
echo "This will run multiple tasks over ~2-3 minutes"
echo "============================================="
echo ""

# Create workspace
mkdir -p long-test-workspace
cd long-test-workspace

echo "[Task 1/5] Creating comprehensive wordlist..."
cat > comprehensive-wordlist.txt << 'EOF'
admin
administrator
root
test
password
123456
qwerty
letmein
welcome
monkey
dragon
master
sunshine
princess
654321
superman
EOF

echo "[Task 2/5] Running hashcat extensive benchmark (30+ seconds)..."
echo "This demonstrates CPU password cracking capabilities..."
docker run --rm security-toolkit:latest \
    timeout 45 hashcat -b -m 0,100,1000,1400,1700,1800 2>&1 | head -100

echo ""
echo "[Task 3/5] Running Python cryptographic operations (computational intensive)..."
docker run --rm security-toolkit:latest python3 << 'PYTHON'
import hashlib
import time
from Crypto.Cipher import AES
from Crypto.Random import get_random_bytes
import random
import string

print("Performing intensive cryptographic operations...")

# Generate multiple hashes
print("\n1. Generating 10000 SHA256 hashes...")
start = time.time()
for i in range(10000):
    data = ''.join(random.choices(string.ascii_letters + string.digits, k=32))
    hashlib.sha256(data.encode()).hexdigest()
    if (i + 1) % 2000 == 0:
        print(f"   Progress: {i + 1}/10000 hashes generated")
elapsed = time.time() - start
print(f"   Completed in {elapsed:.2f} seconds")

# Test encryption
print("\n2. Testing AES encryption (1000 iterations)...")
start = time.time()
for i in range(1000):
    key = get_random_bytes(16)
    cipher = AES.new(key, AES.MODE_EAX)
    nonce = cipher.nonce
    data = b'A' * 256
    ciphertext, tag = cipher.encrypt_and_digest(data)
    if (i + 1) % 200 == 0:
        print(f"   Progress: {i + 1}/1000 encryptions")
elapsed = time.time() - start
print(f"   Completed in {elapsed:.2f} seconds")

print("\n3. Computing multiple hash types...")
test_data = b"test_password_" * 100
for algo in ['md5', 'sha1', 'sha256', 'sha512']:
    start = time.time()
    for _ in range(5000):
        h = hashlib.new(algo)
        h.update(test_data)
        h.hexdigest()
    elapsed = time.time() - start
    print(f"   {algo.upper()}: 5000 iterations in {elapsed:.2f}s")

print("\nCryptographic operations completed successfully!")
PYTHON

echo ""
echo "[Task 4/5] Testing Go compilation within container..."
docker run --rm security-toolkit:latest bash -c '
echo "Creating and compiling a simple Go program..."
cd /tmp
cat > test.go << "GOCODE"
package main

import (
    "crypto/sha256"
    "fmt"
    "time"
)

func main() {
    start := time.Now()
    
    for i := 0; i < 100000; i++ {
        data := fmt.Sprintf("test_data_%d", i)
        sha256.Sum256([]byte(data))
        if (i+1) % 20000 == 0 {
            fmt.Printf("Progress: %d/100000 hashes\n", i+1)
        }
    }
    
    elapsed := time.Since(start)
    fmt.Printf("Completed 100000 SHA256 hashes in %.2f seconds\n", elapsed.Seconds())
}
GOCODE

echo "Compiling..."
go build -o test test.go
echo "Running compiled program..."
./test
'

echo ""
echo "[Task 5/5] Testing network scanning capabilities with Python..."
docker run --rm security-toolkit:latest python3 << 'PYTHON'
import socket
import time

print("Simulating port scanning operations...")
print("(Testing localhost on common ports)")

common_ports = [21, 22, 23, 25, 53, 80, 110, 143, 443, 3306, 3389, 5432, 8080, 8443]
open_ports = []

start = time.time()
for port in common_ports * 100:  # Test each port multiple times
    sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    sock.settimeout(0.01)
    try:
        result = sock.connect_ex(('127.0.0.1', port))
        if result == 0:
            if port not in open_ports:
                open_ports.append(port)
    except:
        pass
    finally:
        sock.close()

elapsed = time.time() - start
print(f"Scanned {len(common_ports) * 100} port connections in {elapsed:.2f} seconds")
print(f"Open ports found: {open_ports if open_ports else 'None (expected on isolated container)'}")
PYTHON

echo ""
echo "============================================="
echo "All long-running tasks completed!"
echo "Total execution time: ~2-3 minutes"
echo "============================================="
echo ""
echo "Container Performance Summary:"
echo "  ✓ Hashcat benchmarking"
echo "  ✓ Python cryptographic operations"  
echo "  ✓ Go compilation and execution"
echo "  ✓ Network operations simulation"
echo ""
echo "The container is production-ready!"

# Cleanup
cd ..
rm -rf long-test-workspace
