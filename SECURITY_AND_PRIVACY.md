# Security and Privacy - Private Data Management

**Last Updated:** October 16, 2025
**Status:** ✅ Secure Configuration with Single Source of Truth

## Private Data Storage Summary

### Primary Storage: `.env-keys.yml`

**Location:** `~/Dropbox/Environments/.env-keys.yml`
**Permissions:** `600` (owner read/write only)
**Purpose:** Single source of truth for all private credentials

**Contains:**
- API Keys (6): OpenAI, Anthropic, xAI, Google/Gemini, GitHub Token, Census
- GitHub Profile: token, email, username, full name
- IPUMS Credentials: username, password
- ECMWF Credentials: URL, key, email

**Security Features:**
- ✅ 600 permissions (only you can access)
- ✅ Separate from code
- ✅ Should be in `.gitignore`
- ✅ Backed up by `setup_keys.sh` before modifications

### Secondary Storage Locations

#### 1. `base-env/.venv/bin/activate`

**Purpose:** Auto-load keys when activating virtualenv
**Source:** Copied from `.env-keys.yml` by `setup_base_env.sh`
**Contains:** All environment variables (OPENAI_API_KEY, GITHUB_TOKEN, etc.)

**Security Notes:**
- ⚠️ This file also contains your private keys (as a convenience copy)
- ✅ Should be in `.gitignore` (automatically via `.venv/` pattern)
- 🔄 Regenerated each time you run `setup_base_env.sh`

#### 2. `~/.ecmwfapirc`

**Purpose:** ECMWF API client configuration (required by their library)
**Source:** Created from `.env-keys.yml` by `setup_keys.sh`
**Format:** JSON file with ECMWF credentials

**Security Notes:**
- ⚠️ Located in home directory (not in Dropbox)
- ✅ 600 permissions
- 🔄 Updated when running `setup_keys.sh`

## Complete Private Data Inventory

| Data Type | Storage Location | Permissions | Source |
|-----------|------------------|-------------|--------|
| **API Keys (6)** | `.env-keys.yml` | 600 | User edits |
| | `.venv/bin/activate` | (varies) | Copied from YAML |
| **GitHub Token** | `.env-keys.yml` | 600 | User edits |
| | `.venv/bin/activate` | (varies) | Copied from YAML |
| **GitHub Email** | `.env-keys.yml` | 600 | User edits |
| | `.venv/bin/activate` | (varies) | Copied from YAML |
| **GitHub Username** | `.env-keys.yml` | 600 | User edits |
| | `.venv/bin/activate` | (varies) | Copied from YAML |
| **GitHub Full Name** | `.env-keys.yml` | 600 | User edits |
| | `.venv/bin/activate` | (varies) | Copied from YAML |
| **IPUMS Credentials** | `.env-keys.yml` | 600 | User edits |
| **ECMWF Credentials** | `.env-keys.yml` | 600 | User edits |
| | `~/.ecmwfapirc` | 600 | Copied from YAML |

## Data Flow Diagram

```
┌─────────────────────────────┐
│   .env-keys.yml             │ ← YOU EDIT THIS
│   (600 permissions)         │   (Single Source of Truth)
│                             │
│ • API Keys (6)              │
│ • GitHub: token, email,     │
│   username, name            │
│ • IPUMS: username, password │
│ • ECMWF: url, key, email    │
└──────────────┬──────────────┘
               │
               │ Read by:
               │
     ┌─────────┼──────────┬──────────────┐
     │         │          │              │
     ▼         ▼          ▼              ▼
┌──────────┐ ┌────────┐ ┌──────────┐ ┌──────────┐
│ setup_   │ │ setup_ │ │ load_api │ │ Runtime  │
│ base_env │ │ keys   │ │ _keys.sh │ │ Scripts  │
└────┬─────┘ └───┬────┘ └────┬─────┘ └──────────┘
     │           │            │
     ▼           ▼            ▼
┌──────────┐ ┌──────────┐ ┌──────────┐
│ .venv/   │ │ ~/.ecmwf │ │ Env Vars │
│ bin/     │ │ apirc    │ │ (Current │
│ activate │ │          │ │  Shell)  │
└──────────┘ └──────────┘ └──────────┘
     ↑
     └─ COPY of credentials (convenience)
```

## Security Best Practices

### ✅ Current Protections

1. **File Permissions:**
   - `.env-keys.yml`: 600 (owner only)
   - `~/.ecmwfapirc`: 600 (owner only)

2. **Separation of Concerns:**
   - Credentials separate from code
   - Single source of truth
   - Scripts never hardcode secrets

3. **Automatic Backups:**
   - `setup_keys.sh` creates timestamped backups before modifications

4. **Version Control Protection:**
   - Should be in `.gitignore`
   - Never committed to repositories

### ⚠️ Important Security Notes

1. **`.venv/bin/activate` Contains Your Keys**
   - This is by design for convenience
   - Automatically loaded when activating virtualenv
   - Also should be in `.gitignore` via `.venv/` pattern

2. **Dropbox Sync**
   - `.env-keys.yml` is in Dropbox and syncs across devices
   - ✅ Good: Available on all your machines
   - ⚠️ Consider: Dropbox account security is critical

3. **~/.ecmwfapirc is System-Wide**
   - Located in home directory
   - Not synced via Dropbox
   - Created/updated by `setup_keys.sh`

## Recommended `.gitignore` Entries

```gitignore
# API Keys and Credentials
.env-keys.yml
.env-keys.yml.bak.*

# Virtual Environment (contains copied keys in activate script)
.venv/
base-env/.venv/

# ECMWF Config
.ecmwfapirc

# Other sensitive files
*.key
*.pem
credentials.json
```

## How to Update Your Private Data

### Updating API Keys

**Method 1: Edit YAML directly**
```bash
nano ~/Dropbox/Environments/.env-keys.yml
# Edit the values
source ~/Dropbox/Environments/load_api_keys.sh  # Reload
```

**Method 2: Re-run setup**
```bash
# Edit .env-keys.yml first
./setup_base_env.sh  # Re-injects keys into .venv/bin/activate
```

### Updating GitHub Profile

```bash
nano ~/Dropbox/Environments/.env-keys.yml
# Update github section:
#   token: "..."
#   email: "..."
#   username: "..."
#   name: "..."

source load_api_keys.sh  # Reload into current shell
```

### After Updating

1. Keys are immediately available in new shells via `load_api_keys.sh`
2. Existing virtualenv needs reactivation or re-run `setup_base_env.sh`
3. `~/.ecmwfapirc` needs `setup_keys.sh` to update

## Emergency: Credentials Compromised

If you suspect your credentials have been compromised:

1. **Immediate Actions:**
   ```bash
   # Revoke all API keys at their providers
   # - OpenAI: https://platform.openai.com/api-keys
   # - Anthropic: https://console.anthropic.com/settings/keys
   # - GitHub: https://github.com/settings/tokens
   # - Google: https://console.cloud.google.com/apis/credentials
   ```

2. **Generate New Keys:**
   ```bash
   # Get new keys from each provider
   nano ~/Dropbox/Environments/.env-keys.yml  # Update with new keys
   ```

3. **Update All Locations:**
   ```bash
   source load_api_keys.sh           # Reload into shell
   ./setup_base_env.sh --force-reinstall  # Update .venv/bin/activate
   ./setup_keys.sh                   # Update ~/.ecmwfapirc
   ```

4. **Verify:**
   ```bash
   ./verify_api_key_consistency.sh   # Check all scripts updated
   ```

## Privacy Considerations

### Data Stored in `.env-keys.yml`

**Sensitive (High Risk):**
- API Keys and Tokens (can access services in your name)
- IPUMS Password
- GitHub Token (can access your repositories)

**Personal (Medium Risk):**
- Email addresses
- Full name
- Usernames

**Public (Low Risk):**
- ECMWF API URL (public endpoint)

### Who Has Access?

1. **You** - Full access via file ownership
2. **Dropbox** - Encrypted storage, but they hold encryption keys
3. **Any device logged into your Dropbox** - Gets synced copy

### Best Practices:

1. ✅ Use strong Dropbox password + 2FA
2. ✅ Regularly rotate API keys
3. ✅ Use minimal scope tokens (don't grant more permissions than needed)
4. ✅ Monitor API usage for suspicious activity
5. ⚠️ Consider encrypting `.env-keys.yml` for extra protection (but reduces convenience)

## Summary

### ✅ You Are Correct

**Yes, all private data is in `.env-keys.yml`** with these clarifications:

1. **Primary Storage:** `.env-keys.yml` (single source of truth)
2. **Copies Created:**
   - `.venv/bin/activate` (for convenience)
   - `~/.ecmwfapirc` (required by ECMWF client)
3. **Security:** All locations have proper file permissions
4. **Maintenance:** Easy to update - just edit `.env-keys.yml`

### Current Configuration (9 Credentials)

1. OPENAI_API_KEY
2. ANTHROPIC_API_KEY
3. XAI_API_KEY
4. GOOGLE_API_KEY
5. GITHUB_TOKEN
6. GITHUB_EMAIL
7. GITHUB_USERNAME
8. GITHUB_NAME ← **NEW**
9. CENSUS_API_KEY

Plus: IPUMS credentials, ECMWF credentials

---

**Questions?** Check:
- `API_KEY_CONSISTENCY_REPORT.md` - Technical details
- `CONSISTENCY_VERIFICATION_SUMMARY.md` - Verification results
- `README.API-KEYS.md` - Usage guide
