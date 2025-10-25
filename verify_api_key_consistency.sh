#!/bin/bash
# Verification script to ensure API key consistency across all scripts
# Tests that all three scripts handle the same 6 API keys consistently

echo "=========================================================="
echo "🔍 API Key Consistency Verification"
echo "=========================================================="
echo ""

# Define expected keys
EXPECTED_KEYS=(
  "OPENAI_API_KEY"
  "ANTHROPIC_API_KEY"
  "XAI_API_KEY"
  "GOOGLE_API_KEY"
  "GITHUB_TOKEN"
  "CENSUS_API_KEY"
)

YAML_FILE="$HOME/Dropbox/Environments/.env-keys.yml"
SETUP_BASE="$HOME/Dropbox/Environments/setup_base_env.sh"
SETUP_KEYS="$HOME/Dropbox/Environments/setup_keys.sh"
LOAD_KEYS="$HOME/Dropbox/Environments/load_api_keys.sh"

echo "📋 Expected API Keys (6 total):"
for key in "${EXPECTED_KEYS[@]}"; do
  echo "   • $key"
done
echo ""

# Check .env-keys.yml structure
echo "🔍 Checking .env-keys.yml..."
if [ ! -f "$YAML_FILE" ]; then
  echo "   ❌ File not found: $YAML_FILE"
  exit 1
fi

yaml_keys_found=0
for key in "${EXPECTED_KEYS[@]}"; do
  # Convert environment variable name to yaml key name
  yaml_key=$(echo "$key" | tr '[:upper:]' '[:lower:]')

  # Check both top-level and nested keys
  if grep -q "^[[:space:]]*${yaml_key}:" "$YAML_FILE" || \
     grep -A 5 "^[[:space:]]*api_keys:" "$YAML_FILE" | grep -q "^[[:space:]]*${yaml_key}:"; then
    echo "   ✅ Found: $yaml_key"
    ((yaml_keys_found++))
  else
    echo "   ❌ Missing: $yaml_key"
  fi
done
echo "   📊 Found $yaml_keys_found out of ${#EXPECTED_KEYS[@]} keys in YAML"
echo ""

# Check setup_base_env.sh
echo "🔍 Checking setup_base_env.sh..."
if [ ! -f "$SETUP_BASE" ]; then
  echo "   ❌ File not found: $SETUP_BASE"
  exit 1
fi

# Check if it loads from YAML
if grep -q "get_yaml_value" "$SETUP_BASE"; then
  echo "   ✅ Loads keys from YAML file"
else
  echo "   ❌ Does not load keys from YAML file"
fi

# Check if it injects all keys into activate
setup_base_keys_found=0
for key in "${EXPECTED_KEYS[@]}"; do
  if grep -q "$key" "$SETUP_BASE"; then
    echo "   ✅ Handles: $key"
    ((setup_base_keys_found++))
  else
    echo "   ❌ Missing: $key"
  fi
done
echo "   📊 Found $setup_base_keys_found out of ${#EXPECTED_KEYS[@]} keys in setup_base_env.sh"
echo ""

# Check setup_keys.sh
echo "🔍 Checking setup_keys.sh..."
if [ ! -f "$SETUP_KEYS" ]; then
  echo "   ❌ File not found: $SETUP_KEYS"
  exit 1
fi

setup_keys_found=0
for key in "${EXPECTED_KEYS[@]}"; do
  yaml_key=$(echo "$key" | tr '[:upper:]' '[:lower:]')
  if grep -q "$yaml_key" "$SETUP_KEYS"; then
    echo "   ✅ Creates: $yaml_key"
    ((setup_keys_found++))
  else
    echo "   ❌ Missing: $yaml_key"
  fi
done
echo "   📊 Found $setup_keys_found out of ${#EXPECTED_KEYS[@]} keys in setup_keys.sh"
echo ""

# Check load_api_keys.sh
echo "🔍 Checking load_api_keys.sh..."
if [ ! -f "$LOAD_KEYS" ]; then
  echo "   ❌ File not found: $LOAD_KEYS"
  exit 1
fi

load_keys_found=0
for key in "${EXPECTED_KEYS[@]}"; do
  if grep -q "export $key=" "$LOAD_KEYS"; then
    echo "   ✅ Exports: $key"
    ((load_keys_found++))
  else
    echo "   ❌ Missing: $key"
  fi
done
echo "   📊 Found $load_keys_found out of ${#EXPECTED_KEYS[@]} keys in load_api_keys.sh"
echo ""

# Summary
echo "=========================================================="
echo "📊 CONSISTENCY SUMMARY"
echo "=========================================================="
echo ""

total_checks=$((${#EXPECTED_KEYS[@]} * 4))
total_found=$((yaml_keys_found + setup_base_keys_found + setup_keys_found + load_keys_found))

echo "Total checks: $total_found / $total_checks"
echo ""

if [ $yaml_keys_found -eq ${#EXPECTED_KEYS[@]} ] && \
   [ $setup_base_keys_found -eq ${#EXPECTED_KEYS[@]} ] && \
   [ $setup_keys_found -eq ${#EXPECTED_KEYS[@]} ] && \
   [ $load_keys_found -eq ${#EXPECTED_KEYS[@]} ]; then
  echo "✅ ALL CHECKS PASSED - Perfect consistency!"
  echo ""
  echo "All three scripts handle the same 6 API keys consistently:"
  for key in "${EXPECTED_KEYS[@]}"; do
    echo "   • $key"
  done
  exit 0
else
  echo "⚠️  CONSISTENCY ISSUES DETECTED"
  echo ""
  echo "Summary by file:"
  echo "   .env-keys.yml:        $yaml_keys_found / ${#EXPECTED_KEYS[@]}"
  echo "   setup_base_env.sh:    $setup_base_keys_found / ${#EXPECTED_KEYS[@]}"
  echo "   setup_keys.sh:        $setup_keys_found / ${#EXPECTED_KEYS[@]}"
  echo "   load_api_keys.sh:     $load_keys_found / ${#EXPECTED_KEYS[@]}"
  exit 1
fi
