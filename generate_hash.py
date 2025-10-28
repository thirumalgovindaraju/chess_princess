#!/usr/bin/env python3
"""
Hash Key Generator for OTP Authentication Testing
Usage: python generate_hash.py <identifier> [timestamp]
"""

import hashlib
import sys
import time

def generate_hash(identifier, timestamp=None):
    if timestamp is None:
        timestamp = str(int(time.time() * 1000))
    
    combined = f"{identifier}:{timestamp}"
    hash_key = hashlib.sha256(combined.encode()).hexdigest()
    
    print(f"Identifier: {identifier}")
    print(f"Timestamp: {timestamp}")
    print(f"Combined: {combined}")
    print(f"Hash Key: {hash_key}")
    print()
    print("cURL Command:")
    print(f'curl -X POST http://localhost:5000/api/auth/otp/send \\')
    print(f'  -H "Content-Type: application/json" \\')
    print(f'  -d \'{{"phone":"{identifier}","method":"sms","hashKey":"{hash_key}","timestamp":"{timestamp}"}}\'')
    
    return hash_key, timestamp

if __name__ == "__main__":
    if len(sys.argv) < 2:
        print("Usage: python generate_hash.py <identifier> [timestamp]")
        sys.exit(1)
    
    identifier = sys.argv[1]
    timestamp = sys.argv[2] if len(sys.argv) > 2 else None
    
    generate_hash(identifier, timestamp)
