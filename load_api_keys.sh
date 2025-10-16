#!/bin/bash
# Script to load API keys from YAML file
# Usage: source load_api_keys.sh

# Define the YAML file location
API_KEYS_YAML="/Users/davidlary/Dropbox/Environments/.env-keys.yml"

echo "🔑 Loading API keys from $API_KEYS_YAML..."

if [ ! -f "$API_KEYS_YAML" ]; then
  echo "⚠️ API keys file $API_KEYS_YAML not found!"
  return 1
fi

# Function to extract value from YAML key
function get_yaml_value {
  local key=$1
  grep "^\s*$key:\s*'.*'" "$API_KEYS_YAML" | sed "s/^\s*$key:\s*'\(.*\)'/\1/"
}

# Function to extract value from nested YAML keys
function get_nested_yaml_value {
  local parent=$1
  local key=$2
  # Use grep with -A 1 to get the line after the parent, then extract the key value
  grep -A 5 "^\s*$parent:" "$API_KEYS_YAML" | grep "^\s*$key:" | sed 's/^[^:]*:[[:space:]]*"\(.*\)"/\1/'
}

# Set the basic environment variables
# NOTE: ANTHROPIC_API_KEY is intentionally excluded to avoid conflicts with Claude Code CLI
# Claude Code uses its own authentication system via the Anthropic Console
export OPENAI_API_KEY=$(get_yaml_value "openai_api_key")
export XAI_API_KEY=$(get_yaml_value "xai_api_key")
export GOOGLE_API_KEY=$(get_yaml_value "google_api_key")

# Set GitHub credentials
export GITHUB_TOKEN=$(get_nested_yaml_value "github" "token")
export GITHUB_EMAIL=$(get_nested_yaml_value "github" "email")
export GITHUB_USERNAME=$(get_nested_yaml_value "github" "username")
export GITHUB_NAME=$(get_nested_yaml_value "github" "name")

# Set additional API keys
export CENSUS_API_KEY=$(get_nested_yaml_value "api_keys" "census_api_key")

# Set IPUMS credentials
export IPUMS_USERNAME=$(get_nested_yaml_value "ipums" "username")
export IPUMS_PASSWORD=$(get_nested_yaml_value "ipums" "password")

# Set ECMWF credentials
export ECMWF_URL=$(get_nested_yaml_value "ecmwf" "url")
export ECMWF_KEY=$(get_nested_yaml_value "ecmwf" "key")
export ECMWF_EMAIL=$(get_nested_yaml_value "ecmwf" "email")

# Verify if keys were loaded
if [ -n "$OPENAI_API_KEY" ] && [ "$OPENAI_API_KEY" != "your-openai-key-here" ]; then
  echo "✅ Loaded OpenAI API key (starting with ${OPENAI_API_KEY:0:4}...)"
else
  echo "⚠️ OpenAI API key not set or contains default placeholder"
fi

# ANTHROPIC_API_KEY intentionally not loaded to avoid conflicts with Claude Code CLI
echo "ℹ️  ANTHROPIC_API_KEY not loaded (Claude Code uses its own authentication)"

if [ -n "$XAI_API_KEY" ] && [ "$XAI_API_KEY" != "your-xai-key-here" ]; then
  echo "✅ Loaded XAI API key (starting with ${XAI_API_KEY:0:4}...)"
else
  echo "⚠️ XAI API key not set or contains default placeholder"
fi

if [ -n "$GOOGLE_API_KEY" ] && [ "$GOOGLE_API_KEY" != "your-google-api-key-here" ]; then
  echo "✅ Loaded Google API key (starting with ${GOOGLE_API_KEY:0:4}...)"
else
  echo "⚠️ Google API key not set or contains default placeholder"
fi

if [ -n "$GITHUB_TOKEN" ] && [ "$GITHUB_TOKEN" != "your-github-token-here" ]; then
  echo "✅ Loaded GitHub token (starting with ${GITHUB_TOKEN:0:4}...)"
else
  echo "⚠️ GitHub token not set or contains default placeholder"
fi

if [ -n "$GITHUB_EMAIL" ] && [ "$GITHUB_EMAIL" != "your-email@example.com" ]; then
  echo "✅ Loaded GitHub email: $GITHUB_EMAIL"
else
  echo "⚠️ GitHub email not set or contains default placeholder"
fi

if [ -n "$GITHUB_USERNAME" ] && [ "$GITHUB_USERNAME" != "your-github-username" ]; then
  echo "✅ Loaded GitHub username: $GITHUB_USERNAME"
else
  echo "⚠️ GitHub username not set or contains default placeholder"
fi

if [ -n "$GITHUB_NAME" ] && [ "$GITHUB_NAME" != "Your Name" ]; then
  echo "✅ Loaded GitHub name: $GITHUB_NAME"
else
  echo "⚠️ GitHub name not set or contains default placeholder"
fi

if [ -n "$CENSUS_API_KEY" ] && [ "$CENSUS_API_KEY" != "your-census-api-key-here" ]; then
  echo "✅ Loaded Census API key (starting with ${CENSUS_API_KEY:0:4}...)"
else
  echo "⚠️ Census API key not set or contains default placeholder"
fi

if [ -n "$IPUMS_USERNAME" ] && [ "$IPUMS_USERNAME" != "your-ipums-username-here" ]; then
  echo "✅ Loaded IPUMS username: $IPUMS_USERNAME"
else
  echo "⚠️ IPUMS username not set or contains default placeholder"
fi

if [ -n "$IPUMS_PASSWORD" ] && [ "$IPUMS_PASSWORD" != "your-ipums-password-here" ]; then
  echo "✅ Loaded IPUMS password (hidden for security)"
else
  echo "⚠️ IPUMS password not set or contains default placeholder"
fi

if [ -n "$ECMWF_KEY" ] && [ "$ECMWF_KEY" != "your-ecmwf-key-here" ]; then
  echo "✅ Loaded ECMWF API key (starting with ${ECMWF_KEY:0:4}...)"
else
  echo "⚠️ ECMWF API key not set or contains default placeholder"
fi

if [ -n "$ECMWF_EMAIL" ] && [ "$ECMWF_EMAIL" != "your-email@example.com" ]; then
  echo "✅ Loaded ECMWF email: $ECMWF_EMAIL"
else
  echo "⚠️ ECMWF email not set or contains default placeholder"
fi

echo "🔑 API keys are now available as environment variables"
echo "   To use them in your scripts: ${OPENAI_API_KEY}, ${XAI_API_KEY}, etc."
echo "   (ANTHROPIC_API_KEY not exported to avoid conflicts with Claude Code)"
