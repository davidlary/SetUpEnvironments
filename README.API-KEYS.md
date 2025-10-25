# API Keys Management

This environment uses a YAML file to securely store API keys separate from your code.

## Key Files

- `.env-keys.yml`: Stores your API keys with secure permissions (only you can read/write)
- `load_api_keys.sh`: Script to load keys from the YAML file into your environment
- `~/.ecmwfapirc`: JSON file for ECMWF API access (generated from YAML values)

## Security Benefits

1. **Separation of Concerns**: Keys are stored separately from code
2. **Permission Control**: Files have 600 permissions (only you can read/write)
3. **Not Version Controlled**: These files should be in your .gitignore
4. **Single Source of Truth**: Only one file to update when keys change

## How to Use

1. Edit your API keys in `.env-keys.yml`:
   ```yaml
   openai_api_key: 'your-actual-key-here'
   anthropic_api_key: 'your-actual-key-here'
   ```

2. Load the keys in your terminal:
   ```bash
   source load_api_keys.sh
   ```

3. The keys are automatically loaded when you run the environment setup script:
   ```bash
   ./setup_base_env.sh
   ```

## Available Keys

The following keys/credentials are set up:

- `OPENAI_API_KEY`: For OpenAI GPT models
- `ANTHROPIC_API_KEY`: For Anthropic Claude models
- `XAI_API_KEY`: For xAI Grok models
- `GOOGLE_API_KEY`: For Google Gemini models
- `GITHUB_TOKEN`: For GitHub API access (repos, gists, actions)
- `CENSUS_API_KEY`: For US Census API access
- `IPUMS_USERNAME`: IPUMS account username
- `IPUMS_PASSWORD`: IPUMS account password
- `ECMWF_URL`, `ECMWF_KEY`, `ECMWF_EMAIL`: For ECMWF API access

## ECMWF API Access

The ECMWF API requires credentials to be stored in `~/.ecmwfapirc`. This file is created automatically based on the values in `.env-keys.yml`. For more information, visit:
- https://confluence.ecmwf.int/display/WEBAPI/Access+ECMWF+Public+Datasets
- https://www.ecmwf.int/en/computing/software/ecmwf-web-api

## Adding New Keys

To add new API keys, simply add them to the `.env-keys.yml` file and update the loader script.
