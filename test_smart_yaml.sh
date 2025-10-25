#!/bin/bash
# Test script to verify smart YAML auto-repair functionality

echo "=========================================="
echo "Testing Smart YAML Auto-Repair"
echo "=========================================="
echo ""

# Backup original file
cp ~/.local/share/claude/Dropbox/Environments/.env-keys.yml /tmp/.env-keys.yml.original

# Test 1: Remove github_token
echo "Test 1: Removing github_token from YAML..."
grep -v "^github_token:" /tmp/.env-keys.yml.original | grep -v "^# GitHub Token" > /tmp/.env-keys-test.yml
cp /tmp/.env-keys-test.yml ~/Dropbox/Environments/.env-keys.yml

echo "Running the smart YAML loading code..."

# Source the functions from setup_base_env.sh
API_KEYS_YAML="$HOME/Dropbox/Environments/.env-keys.yml"

function get_yaml_value {
  local key=$1
  grep "^\s*$key:\s*'.*'" "$API_KEYS_YAML" | sed "s/^\s*$key:\s*'\(.*\)'/\1/"
}

function yaml_key_exists {
  local key=$1
  if grep -q "^\s*$key:" "$API_KEYS_YAML"; then
    return 0
  else
    return 1
  fi
}

function add_yaml_key {
  local key=$1
  local comment=$2
  local placeholder=$3

  echo "" >> "$API_KEYS_YAML"
  echo "# $comment" >> "$API_KEYS_YAML"
  echo "$key: '$placeholder'" >> "$API_KEYS_YAML"
}

# Check and repair
MISSING_KEYS=()

if ! yaml_key_exists "github_token"; then
  add_yaml_key "github_token" "GitHub Token - Used for GitHub API access (repos, gists, etc.)" "your-github-token-here"
  MISSING_KEYS+=("github_token")
  echo "✅ Auto-added github_token"
fi

# Verify it was added
if yaml_key_exists "github_token"; then
  echo "✅ github_token now exists in YAML"
  echo "Value: $(get_yaml_value "github_token")"
else
  echo "❌ github_token still missing!"
fi

# Show the last few lines
echo ""
echo "Last 10 lines of repaired YAML:"
tail -10 "$API_KEYS_YAML"

# Restore original
echo ""
echo "Restoring original YAML file..."
cp /tmp/.env-keys.yml.original ~/Dropbox/Environments/.env-keys.yml
echo "✅ Original file restored"
