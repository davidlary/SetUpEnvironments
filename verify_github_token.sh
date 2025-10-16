#!/bin/bash
# Script to verify GitHub token is properly configured

echo "=========================================="
echo "GitHub Token Verification"
echo "=========================================="
echo ""

# Check if token is set
if [ -z "$GITHUB_TOKEN" ]; then
    echo "❌ GITHUB_TOKEN is not set in current environment"
    echo ""
    echo "To set it, run one of these commands in your terminal:"
    echo ""
    echo "Option 1: Export directly"
    echo "  export GITHUB_TOKEN='ghp_your_token_here'"
    echo ""
    echo "Option 2: Load from .env-keys.yml"
    echo "  cd ~/Dropbox/Environments"
    echo "  source load_api_keys.sh"
    echo ""
    exit 1
fi

echo "✅ GITHUB_TOKEN is set"
echo "   Length: ${#GITHUB_TOKEN} characters"
echo "   Starts with: ${GITHUB_TOKEN:0:7}..."
echo ""

# Test GitHub API access
echo "Testing GitHub API access..."
RESPONSE=$(curl -s -w "\n%{http_code}" -H "Authorization: token $GITHUB_TOKEN" https://api.github.com/user)
HTTP_CODE=$(echo "$RESPONSE" | tail -n1)
BODY=$(echo "$RESPONSE" | sed '$d')

if [ "$HTTP_CODE" = "200" ]; then
    echo "✅ GitHub API access successful!"
    echo ""
    USERNAME=$(echo "$BODY" | grep -o '"login":"[^"]*"' | cut -d'"' -f4)
    NAME=$(echo "$BODY" | grep -o '"name":"[^"]*"' | cut -d'"' -f4)
    echo "   Authenticated as: $USERNAME"
    if [ -n "$NAME" ]; then
        echo "   Name: $NAME"
    fi
    echo ""
    echo "✅ Your GitHub token is working correctly!"
else
    echo "❌ GitHub API access failed (HTTP $HTTP_CODE)"
    echo ""
    echo "Response:"
    echo "$BODY" | head -5
    echo ""
    echo "Possible issues:"
    echo "  - Token may be invalid or expired"
    echo "  - Token may lack required scopes"
    echo "  - Check token at: https://github.com/settings/tokens"
fi

echo "=========================================="
