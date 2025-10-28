#!/bin/bash
# ============================================================================
# OTP Authentication API Testing Script
# ============================================================================

BASE_URL="http://localhost:5000/api"
PHONE="+919894596364"
EMAIL="test@example.com"

# Colors for output
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# ============================================================================
# Function to generate timestamp
# ============================================================================
get_timestamp() {
    echo $(date +%s)000
}

# ============================================================================
# Function to generate hash key (requires openssl)
# ============================================================================
generate_hash() {
    local identifier=$1
    local timestamp=$2
    local combined="${identifier}:${timestamp}"
    echo -n "$combined" | openssl dgst -sha256 -hex | awk '{print $2}'
}

# ============================================================================
# TEST 1: Send SMS OTP
# ============================================================================
echo -e "${YELLOW}=== TEST 1: Send SMS OTP ===${NC}"

TIMESTAMP=$(get_timestamp)
HASH=$(generate_hash "$PHONE" "$TIMESTAMP")

echo "Phone: $PHONE"
echo "Timestamp: $TIMESTAMP"
echo "Hash Key: $HASH"
echo ""

curl -X POST "$BASE_URL/auth/otp/send" \
  -H "Content-Type: application/json" \
  -d "{
    \"phone\": \"$PHONE\",
    \"method\": \"sms\",
    \"hashKey\": \"$HASH\",
    \"timestamp\": \"$TIMESTAMP\"
  }"

echo -e "\n"

# ============================================================================
# TEST 2: Send WhatsApp OTP
# ============================================================================
echo -e "${YELLOW}=== TEST 2: Send WhatsApp OTP ===${NC}"

TIMESTAMP=$(get_timestamp)
HASH=$(generate_hash "$PHONE" "$TIMESTAMP")

echo "Phone: $PHONE"
echo "Timestamp: $TIMESTAMP"
echo "Hash Key: $HASH"
echo ""

curl -X POST "$BASE_URL/auth/otp/send" \
  -H "Content-Type: application/json" \
  -d "{
    \"phone\": \"$PHONE\",
    \"method\": \"whatsapp\",
    \"hashKey\": \"$HASH\",
    \"timestamp\": \"$TIMESTAMP\"
  }"

echo -e "\n"

# ============================================================================
# TEST 3: Send Email OTP
# ============================================================================
echo -e "${YELLOW}=== TEST 3: Send Email OTP ===${NC}"

TIMESTAMP=$(get_timestamp)
HASH=$(generate_hash "$EMAIL" "$TIMESTAMP")

echo "Email: $EMAIL"
echo "Timestamp: $TIMESTAMP"
echo "Hash Key: $HASH"
echo ""

curl -X POST "$BASE_URL/auth/otp/send" \
  -H "Content-Type: application/json" \
  -d "{
    \"email\": \"$EMAIL\",
    \"method\": \"email\",
    \"hashKey\": \"$HASH\",
    \"timestamp\": \"$TIMESTAMP\"
  }"

echo -e "\n"

# ============================================================================
# TEST 4: Verify OTP (Interactive)
# ============================================================================
echo -e "${YELLOW}=== TEST 4: Verify OTP ===${NC}"
echo "Enter the OTP code you received:"
read OTP_CODE

TIMESTAMP=$(get_timestamp)
HASH=$(generate_hash "$PHONE" "$TIMESTAMP")

echo "Phone: $PHONE"
echo "OTP: $OTP_CODE"
echo "Timestamp: $TIMESTAMP"
echo "Hash Key: $HASH"
echo ""

curl -X POST "$BASE_URL/auth/otp/verify" \
  -H "Content-Type: application/json" \
  -d "{
    \"identifier\": \"$PHONE\",
    \"code\": \"$OTP_CODE\",
    \"hashKey\": \"$HASH\",
    \"timestamp\": \"$TIMESTAMP\"
  }"

echo -e "\n"

# ============================================================================
# TEST 5: Username/Password Login
# ============================================================================
echo -e "${YELLOW}=== TEST 5: Username/Password Login ===${NC}"

USERNAME="testuser"
PASSWORD="testpass123"
TIMESTAMP=$(get_timestamp)

# Hash password with SHA-256
PASSWORD_HASH=$(echo -n "$PASSWORD" | openssl dgst -sha256 -hex | awk '{print $2}')

# Create auth data and hash
AUTH_DATA="${USERNAME}:${PASSWORD_HASH}"
AUTH_HASH=$(generate_hash "$AUTH_DATA" "$TIMESTAMP")

echo "Username: $USERNAME"
echo "Password Hash: $PASSWORD_HASH"
echo "Timestamp: $TIMESTAMP"
echo "Auth Hash: $AUTH_HASH"
echo ""

curl -X POST "$BASE_URL/auth/login" \
  -H "Content-Type: application/json" \
  -d "{
    \"identifier\": \"$USERNAME\",
    \"passwordHash\": \"$PASSWORD_HASH\",
    \"authHashKey\": \"$AUTH_HASH\",
    \"timestamp\": \"$TIMESTAMP\"
  }"

echo -e "\n"

# ============================================================================
# Manual Testing Instructions
# ============================================================================
echo -e "${GREEN}=== Manual Testing Guide ===${NC}"
echo ""
echo "Test with correct timestamp (should succeed):"
echo "================================================"
echo "1. Generate fresh timestamp:"
echo "   TIMESTAMP=\$(date +%s)000"
echo ""
echo "2. Generate hash key:"
echo "   HASH=\$(echo -n \"+919894596364:\$TIMESTAMP\" | openssl dgst -sha256 -hex | awk '{print \$2}')"
echo ""
echo "3. Send request:"
echo "   curl -X POST http://localhost:5000/api/auth/otp/send \\"
echo "     -H \"Content-Type: application/json\" \\"
echo "     -d '{\"phone\":\"+919894596364\",\"method\":\"sms\",\"hashKey\":\"'\$HASH'\",\"timestamp\":\"'\$TIMESTAMP'\"}'"
echo ""
echo "Test with old timestamp (should fail):"
echo "================================================"
echo "curl -X POST http://localhost:5000/api/auth/otp/verify \\"
echo "  -H \"Content-Type: application/json\" \\"
echo "  -d '{\"identifier\":\"+919894596364\",\"code\":\"123456\",\"hashKey\":\"old-hash\",\"timestamp\":\"1697500000000\"}'"
echo ""
echo "Expected: {\"success\":false,\"message\":\"Request expired. Timestamp outside 300s window.\"}"
echo ""

# ============================================================================
# Python Hash Generator (for testing)
# ============================================================================
cat > generate_hash.py << 'EOF'
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
EOF

chmod +x generate_hash.py

echo -e "${GREEN}Python hash generator created: generate_hash.py${NC}"
echo "Usage: python generate_hash.py +919894596364"
echo ""

# ============================================================================
# Node.js Hash Generator (for testing)
# ============================================================================
cat > generate_hash.js << 'EOF'
#!/usr/bin/env node
/**
 * Hash Key Generator for OTP Authentication Testing
 * Usage: node generate_hash.js <identifier> [timestamp]
 */

const crypto = require('crypto');

function generateHash(identifier, timestamp = null) {
    if (!timestamp) {
        timestamp = Date.now().toString();
    }
    
    const combined = `${identifier}:${timestamp}`;
    const hashKey = crypto.createHash('sha256').update(combined).digest('hex');
    
    console.log(`Identifier: ${identifier}`);
    console.log(`Timestamp: ${timestamp}`);
    console.log(`Combined: ${combined}`);
    console.log(`Hash Key: ${hashKey}`);
    console.log();
    console.log('cURL Command:');
    console.log(`curl -X POST http://localhost:5000/api/auth/otp/send \\`);
    console.log(`  -H "Content-Type: application/json" \\`);
    console.log(`  -d '{"phone":"${identifier}","method":"sms","hashKey":"${hashKey}","timestamp":"${timestamp}"}'`);
    
    return { hashKey, timestamp };
}

if (process.argv.length < 3) {
    console.log('Usage: node generate_hash.js <identifier> [timestamp]');
    process.exit(1);
}

const identifier = process.argv[2];
const timestamp = process.argv[3] || null;

generateHash(identifier, timestamp);
EOF

chmod +x generate_hash.js

echo -e "${GREEN}Node.js hash generator created: generate_hash.js${NC}"
echo "Usage: node generate_hash.js +919894596364"
echo ""

echo -e "${GREEN}=== Testing complete! ===${NC}"