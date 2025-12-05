#!/bin/bash

# CORS Testing Script
# Usage: ./scripts/test_cors.sh [API_URL] [ORIGIN]

API_URL="${1:-http://localhost:3000}"
ORIGIN="${2:-https://truek.xyz}"

echo "=================================="
echo "Testing CORS Configuration"
echo "=================================="
echo "API URL: $API_URL"
echo "Origin: $ORIGIN"
echo ""

# Test 1: Preflight Request (OPTIONS)
echo "📡 Test 1: Preflight Request (OPTIONS)"
echo "-----------------------------------"
curl -X OPTIONS "$API_URL/api/v1/auth/google" \
  -H "Origin: $ORIGIN" \
  -H "Access-Control-Request-Method: POST" \
  -H "Access-Control-Request-Headers: Content-Type, Authorization" \
  -i \
  -s | head -20

echo ""
echo ""

# Test 2: Simple GET Request
echo "📡 Test 2: Simple GET Request"
echo "-----------------------------------"
curl -X GET "$API_URL/up" \
  -H "Origin: $ORIGIN" \
  -i \
  -s | head -20

echo ""
echo ""

# Test 3: POST Request with Body
echo "📡 Test 3: POST Request with JSON Body"
echo "-----------------------------------"
curl -X POST "$API_URL/api/v1/auth/login" \
  -H "Origin: $ORIGIN" \
  -H "Content-Type: application/json" \
  -d '{"email":"test@example.com","password":"test123"}' \
  -i \
  -s | head -20

echo ""
echo ""

# Summary
echo "✅ Tests Completed!"
echo ""
echo "Expected headers in response:"
echo "  - Access-Control-Allow-Origin: $ORIGIN"
echo "  - Access-Control-Allow-Methods: ..."
echo "  - Access-Control-Allow-Headers: ..."
echo "  - Access-Control-Expose-Headers: Authorization"
echo ""
echo "If you see these headers, CORS is working! 🎉"
