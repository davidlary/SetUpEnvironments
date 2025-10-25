#!/bin/bash
# Script: setup_keys.sh
# Purpose: Set up API keys for data science environment before main environment setup

# Get the script directory
SCRIPT_DIR="$(pwd)"
echo "📁 Script is running from directory: $SCRIPT_DIR"

# Define the YAML file path
API_KEYS_YAML="$SCRIPT_DIR/.env-keys.yml"
API_KEYS_LOADER="$SCRIPT_DIR/load_api_keys.sh"
ECMWF_API_RC="$HOME/.ecmwfapirc"

echo "========================================================"
echo "🔑 API Keys Setup Script"
echo "========================================================"

# Check if the YAML file already exists
if [ -f "$API_KEYS_YAML" ]; then
  echo "✅ API keys YAML file already exists at: $API_KEYS_YAML"
  echo "   Preserving existing file to maintain your credentials."
  
  # Create a backup just in case
  BACKUP_FILE="${API_KEYS_YAML}.bak.$(date +%Y%m%d%H%M%S)"
  cp "$API_KEYS_YAML" "$BACKUP_FILE"
  echo "   Created backup at: $BACKUP_FILE"
  
  # Ensure file has secure permissions
  chmod 600 "$API_KEYS_YAML"
  echo "   Ensured secure permissions (only you can read/write it)."
else
  # Create the YAML file with placeholder credentials
  echo "📝 Creating $API_KEYS_YAML file with placeholder credentials..."

  # Create the file directly
  cat > "$API_KEYS_YAML" << 'EOF'
# API Keys for this environment
# This file is only readable by you (chmod 600)

# OpenAI API Key
# Used for accessing OpenAI models like GPT-4
openai_api_key: 'your-openai-key-here'

# Anthropic API Key
# Used for accessing Claude models via API
anthropic_api_key: 'your-anthropic-key-here'

# XAI API Key
# Used for other AI services
xai_api_key: 'your-xai-key-here'

# Google API Key (Gemini)
# Used for accessing Google's Gemini models
google_api_key: 'your-google-api-key-here'

# GitHub credentials (used for API access, git operations, and documentation)
github:
  token: "your-github-token-here"
  email: "your-email@example.com"
  username: "your-github-username"
  name: "Your Name"

# API credentials (these will be overridden by environment variables if set)
api_keys:
  census_api_key: "your-census-api-key-here"
  
# IPUMS credentials (these will be overridden by environment variables if set)
ipums:
  username: "your-ipums-username-here"
  password: "your-ipums-password-here"

# ECMWF API credentials (these will also be stored in ~/.ecmwfapirc)
ecmwf:
  url: "https://api.ecmwf.int/v1"
  key: "your-ecmwf-key-here"
  email: "your-email@example.com"
EOF

  # Set secure permissions
  chmod 600 "$API_KEYS_YAML"

  # Verify file creation
  if [ -f "$API_KEYS_YAML" ] && [ -s "$API_KEYS_YAML" ]; then
    echo "✅ Successfully created $API_KEYS_YAML file with placeholder credentials."
    echo "   File has secure permissions (only you can read/write it)."
    echo "   IMPORTANT: Replace the placeholder values with your actual API keys before using."
    ls -la "$API_KEYS_YAML"
  else
    echo "❌ Failed to create $API_KEYS_YAML file!"
    exit 1
  fi
fi

# Create a loader script for the API keys with extended capabilities
echo "📝 Creating API keys loader script..."
cat > "$API_KEYS_LOADER" <<EOF
#!/bin/bash
# Script to load API keys from YAML file
# Usage: source load_api_keys.sh

# Define the YAML file location
API_KEYS_YAML="$API_KEYS_YAML"

echo "🔑 Loading API keys from \$API_KEYS_YAML..."

if [ ! -f "\$API_KEYS_YAML" ]; then
  echo "⚠️ API keys file \$API_KEYS_YAML not found!"
  return 1
fi

# Function to extract value from YAML key
function get_yaml_value {
  local key=\$1
  grep "^\s*\$key:\s*'.*'" "\$API_KEYS_YAML" | sed "s/^\s*\$key:\s*'\(.*\)'/\1/"
}

# Function to extract value from nested YAML keys
function get_nested_yaml_value {
  local parent=\$1
  local key=\$2
  # Use grep with -A 1 to get the line after the parent, then extract the key value
  grep -A 5 "^\s*\$parent:" "\$API_KEYS_YAML" | grep "^\s*\$key:" | sed "s/^\s*\$key:\s*\"\(.*\)\"/\1/"
}

# Set the basic environment variables
export OPENAI_API_KEY=\$(get_yaml_value "openai_api_key")
export ANTHROPIC_API_KEY=\$(get_yaml_value "anthropic_api_key")
export XAI_API_KEY=\$(get_yaml_value "xai_api_key")
export GOOGLE_API_KEY=\$(get_yaml_value "google_api_key")

# Set GitHub credentials
export GITHUB_TOKEN=\$(get_nested_yaml_value "github" "token")
export GITHUB_EMAIL=\$(get_nested_yaml_value "github" "email")
export GITHUB_USERNAME=\$(get_nested_yaml_value "github" "username")
export GITHUB_NAME=\$(get_nested_yaml_value "github" "name")

# Set additional API keys
export CENSUS_API_KEY=\$(get_nested_yaml_value "api_keys" "census_api_key")

# Set IPUMS credentials
export IPUMS_USERNAME=\$(get_nested_yaml_value "ipums" "username")
export IPUMS_PASSWORD=\$(get_nested_yaml_value "ipums" "password")

# Set ECMWF credentials
export ECMWF_URL=\$(get_nested_yaml_value "ecmwf" "url")
export ECMWF_KEY=\$(get_nested_yaml_value "ecmwf" "key")
export ECMWF_EMAIL=\$(get_nested_yaml_value "ecmwf" "email")

# Verify if keys were loaded
if [ -n "\$OPENAI_API_KEY" ] && [ "\$OPENAI_API_KEY" != "your-openai-key-here" ]; then
  echo "✅ Loaded OpenAI API key (starting with \${OPENAI_API_KEY:0:4}...)"
else
  echo "⚠️ OpenAI API key not set or contains default placeholder"
fi

if [ -n "\$ANTHROPIC_API_KEY" ] && [ "\$ANTHROPIC_API_KEY" != "your-anthropic-key-here" ]; then
  echo "✅ Loaded Anthropic API key (starting with \${ANTHROPIC_API_KEY:0:4}...)"
else
  echo "⚠️ Anthropic API key not set or contains default placeholder"
fi

if [ -n "\$XAI_API_KEY" ] && [ "\$XAI_API_KEY" != "your-xai-key-here" ]; then
  echo "✅ Loaded XAI API key (starting with \${XAI_API_KEY:0:4}...)"
else
  echo "⚠️ XAI API key not set or contains default placeholder"
fi

if [ -n "\$GOOGLE_API_KEY" ] && [ "\$GOOGLE_API_KEY" != "your-google-api-key-here" ]; then
  echo "✅ Loaded Google API key (starting with \${GOOGLE_API_KEY:0:4}...)"
else
  echo "⚠️ Google API key not set or contains default placeholder"
fi

if [ -n "\$GITHUB_TOKEN" ] && [ "\$GITHUB_TOKEN" != "your-github-token-here" ]; then
  echo "✅ Loaded GitHub token (starting with \${GITHUB_TOKEN:0:4}...)"
else
  echo "⚠️ GitHub token not set or contains default placeholder"
fi

if [ -n "\$GITHUB_EMAIL" ] && [ "\$GITHUB_EMAIL" != "your-email@example.com" ]; then
  echo "✅ Loaded GitHub email: \$GITHUB_EMAIL"
else
  echo "⚠️ GitHub email not set or contains default placeholder"
fi

if [ -n "\$GITHUB_USERNAME" ] && [ "\$GITHUB_USERNAME" != "your-github-username" ]; then
  echo "✅ Loaded GitHub username: \$GITHUB_USERNAME"
else
  echo "⚠️ GitHub username not set or contains default placeholder"
fi

if [ -n "\$GITHUB_NAME" ] && [ "\$GITHUB_NAME" != "Your Name" ]; then
  echo "✅ Loaded GitHub name: \$GITHUB_NAME"
else
  echo "⚠️ GitHub name not set or contains default placeholder"
fi

if [ -n "\$CENSUS_API_KEY" ] && [ "\$CENSUS_API_KEY" != "your-census-api-key-here" ]; then
  echo "✅ Loaded Census API key (starting with \${CENSUS_API_KEY:0:4}...)"
else
  echo "⚠️ Census API key not set or contains default placeholder"
fi

if [ -n "\$IPUMS_USERNAME" ] && [ "\$IPUMS_USERNAME" != "your-ipums-username-here" ]; then
  echo "✅ Loaded IPUMS username: \$IPUMS_USERNAME"
else
  echo "⚠️ IPUMS username not set or contains default placeholder"
fi

if [ -n "\$IPUMS_PASSWORD" ] && [ "\$IPUMS_PASSWORD" != "your-ipums-password-here" ]; then
  echo "✅ Loaded IPUMS password (hidden for security)"
else
  echo "⚠️ IPUMS password not set or contains default placeholder"
fi

if [ -n "\$ECMWF_KEY" ] && [ "\$ECMWF_KEY" != "your-ecmwf-key-here" ]; then
  echo "✅ Loaded ECMWF API key (starting with \${ECMWF_KEY:0:4}...)"
else
  echo "⚠️ ECMWF API key not set or contains default placeholder"
fi

if [ -n "\$ECMWF_EMAIL" ] && [ "\$ECMWF_EMAIL" != "your-email@example.com" ]; then
  echo "✅ Loaded ECMWF email: \$ECMWF_EMAIL"
else
  echo "⚠️ ECMWF email not set or contains default placeholder"
fi

echo "🔑 API keys are now available as environment variables"
echo "   To use them in your scripts: \${OPENAI_API_KEY}, \${ANTHROPIC_API_KEY}, etc."
EOF

chmod +x "$API_KEYS_LOADER"
echo "✅ Created API keys loader script: $API_KEYS_LOADER"

# Test loading the keys
echo "🔍 Testing API keys loader..."
source "$API_KEYS_LOADER"

# Set up ECMWF API RC file only if it doesn't exist
echo "📝 Checking ECMWF API RC file at $ECMWF_API_RC..."

# Check if ecmwfapirc already exists
if [ -f "$ECMWF_API_RC" ]; then
  echo "✅ ECMWF API RC file already exists at: $ECMWF_API_RC"
  echo "   Preserving existing file."
  echo "   If you need to update it, you can edit it manually."
else
  # Create ecmwfapirc file with generic structure but using placeholders
  cat > "$ECMWF_API_RC" <<EOF
{
    "url"   : "https://api.ecmwf.int/v1",
    "key"   : "your-ecmwf-key-here",
    "email" : "your-email@example.com"
}
EOF
  chmod 600 "$ECMWF_API_RC"
  echo "✅ Created ECMWF API RC file with placeholder values at: $ECMWF_API_RC"
  echo "   Remember to update this file with your actual credentials."

  # Check if we have real values in YAML to update the RC file
  if [ -n "$ECMWF_KEY" ] && [ -n "$ECMWF_EMAIL" ]; then
    if [ "$ECMWF_KEY" != "your-ecmwf-key-here" ] && [ "$ECMWF_EMAIL" != "your-email@example.com" ]; then
      # Update ECMWF API RC file with values from YAML
      cat > "$ECMWF_API_RC" <<EOF
{
    "url"   : "$ECMWF_URL",
    "key"   : "$ECMWF_KEY",
    "email" : "$ECMWF_EMAIL"
}
EOF
      echo "✅ Updated ECMWF API RC file with values from YAML"
    fi
  fi
fi

# Create README for API keys
API_KEYS_README="README.API-KEYS.md"
cat > "$API_KEYS_README" <<EOF
# API Keys Management

This environment uses a YAML file to securely store API keys separate from your code.

## Key Files

- \`.env-keys.yml\`: Stores your API keys with secure permissions (only you can read/write)
- \`load_api_keys.sh\`: Script to load keys from the YAML file into your environment
- \`~/.ecmwfapirc\`: JSON file for ECMWF API access (generated from YAML values)

## Security Benefits

1. **Separation of Concerns**: Keys are stored separately from code
2. **Permission Control**: Files have 600 permissions (only you can read/write)
3. **Not Version Controlled**: These files should be in your .gitignore
4. **Single Source of Truth**: Only one file to update when keys change

## How to Use

1. Edit your API keys in \`.env-keys.yml\`:
   \`\`\`yaml
   openai_api_key: 'your-actual-key-here'
   anthropic_api_key: 'your-actual-key-here'
   \`\`\`

2. Load the keys in your terminal:
   \`\`\`bash
   source load_api_keys.sh
   \`\`\`

3. The keys are automatically loaded when you run the environment setup script:
   \`\`\`bash
   ./setup_base_env.sh
   \`\`\`

## Available Keys

The following keys/credentials are set up:

- \`OPENAI_API_KEY\`: For OpenAI GPT models
- \`ANTHROPIC_API_KEY\`: For Anthropic Claude models
- \`XAI_API_KEY\`: For xAI Grok models
- \`GOOGLE_API_KEY\`: For Google Gemini models
- \`GITHUB_TOKEN\`: For GitHub API access (repos, gists, actions)
- \`CENSUS_API_KEY\`: For US Census API access
- \`IPUMS_USERNAME\`: IPUMS account username
- \`IPUMS_PASSWORD\`: IPUMS account password
- \`ECMWF_URL\`, \`ECMWF_KEY\`, \`ECMWF_EMAIL\`: For ECMWF API access

## ECMWF API Access

The ECMWF API requires credentials to be stored in \`~/.ecmwfapirc\`. This file is created automatically based on the values in \`.env-keys.yml\`. For more information, visit:
- https://confluence.ecmwf.int/display/WEBAPI/Access+ECMWF+Public+Datasets
- https://www.ecmwf.int/en/computing/software/ecmwf-web-api

## Adding New Keys

To add new API keys, simply add them to the \`.env-keys.yml\` file and update the loader script.
EOF

echo "✅ Created API keys documentation: $API_KEYS_README"

echo "========================================================"
echo "✅ API Keys Setup Completed!"
echo "========================================================"
echo ""
echo "🔧 Keys are stored in: $API_KEYS_YAML"
echo "🔧 Loader script: $API_KEYS_LOADER"
echo "🔧 ECMWF API RC file: $ECMWF_API_RC"
echo ""
echo "📋 Next Steps:"
echo "1. Edit your API keys in the YAML file with your actual credentials:"
echo "   nano $API_KEYS_YAML"
echo ""
echo "2. Update your ECMWF API RC file if needed:"
echo "   nano $ECMWF_API_RC"
echo ""
echo "3. Run the main environment setup script:"
echo "   ./setup_base_env.sh"
echo ""
echo "========================================================"

# Create a marker file to indicate setup_keys.sh has been run
touch "$SCRIPT_DIR/.keys_setup_completed"
echo "✅ Created marker file to indicate keys setup is completed"
