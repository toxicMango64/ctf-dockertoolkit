#!/bin/bash

echo "=========================================="
echo "Security Toolkit - Extended Demo Test"
echo "This will run several tests that take time"
echo "=========================================="
echo ""

# Create a test directory
mkdir -p test-workspace
cd test-workspace

echo "[1/5] Creating test wordlist..."
cat > wordlist.txt << 'EOF'
admin
administrator  
root
test
user
password
123456
letmein
welcome
EOF

echo "[2/5] Creating test hash for John the Ripper..."
# Create a simple hash to crack
echo 'testuser:$6$salt$IxDD3jeSOb5eB1CX5LBsqZFVkJdido3OUILO5Ifz5iwMuTS4XMS130MTSuDDl3aCI6WouIL9AjRbLCelDCy.g.' > test-hash.txt

echo "[3/5] Running hashcat benchmark (this takes time)..."
docker run --rm -v "$(pwd)":/workspace security-toolkit:latest \
    hashcat -b --benchmark-all 2>&1 | head -50

echo ""
echo "[4/5] Running John the Ripper with test wordlist..."
docker run --rm -v "$(pwd)":/workspace security-toolkit:latest \
    /opt/john/run/john --wordlist=/workspace/wordlist.txt /workspace/test-hash.txt 2>&1

echo ""
echo "[5/5] Testing Python security libraries..."
docker run --rm security-toolkit:latest python3 << 'PYTHON_SCRIPT'
import requests
import hashlib
import time
from Crypto.Cipher import AES
from Crypto.Random import get_random_bytes

print("Testing Python security libraries...")
print("- requests library:", requests.__version__)
print("- Generating random bytes...")
key = get_random_bytes(16)
print(f"  Generated key (hex): {key.hex()}")

print("- Testing hash functions...")
for i in range(5):
    data = f"test_data_{i}"
    sha256 = hashlib.sha256(data.encode()).hexdigest()
    print(f"  SHA256 of '{data}': {sha256[:32]}...")
    time.sleep(0.5)

print("\nAll Python tests completed successfully!")
PYTHON_SCRIPT

echo ""
echo "=========================================="
echo "Extended demo completed!"
echo "=========================================="

# Cleanup
cd ..
rm -rf test-workspace
