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
