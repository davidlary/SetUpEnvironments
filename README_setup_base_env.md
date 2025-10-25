# Base Environment Setup Script

**Version:** 3.0 (October 2025)
**Script:** `setup_base_env.sh`
**Python Version:** 3.12 (managed via pyenv)

## Overview

This script creates a comprehensive, reproducible data science environment with Python, R, and Julia support. It features sophisticated package management with smart constraints, hybrid conflict resolution, and performance optimizations.

## Quick Start

```bash
# Navigate to wherever you've placed this script
cd /path/to/your/environments/directory

# 1. Configure API keys (optional but recommended)
./setup_keys.sh

# 2. Run installation
./setup_base_env.sh

# 3. Activate the environment
source base-env/.venv/bin/activate

# 4. Verify it works
python -c "import pandas, numpy, sklearn; print('✅ Environment ready!')"

# 5. Now you can work from any directory!
cd ~/your-project-directory
```

**Additional Options:**

```bash
# With adaptive conflict resolution (if needed)
./setup_base_env.sh --adaptive

# Force reinstall everything
./setup_base_env.sh --force-reinstall

# Check for latest package versions and resolve old conflicts
./setup_base_env.sh --update

# Show help
./setup_base_env.sh --help
```

## Key Features

### 🎯 Smart Package Management
- **Smart Constraints System**: Pre-defined version pins for 8 historically problematic packages
- **Hybrid Conflict Resolution**: Two-tier conflict resolution strategy
- **Backtracking Prevention**: Optimized constraints reduce pip solver time
- **Obsolescence Management**: Automatic removal of deprecated packages (jupyter-dash, nose)

### ⚡ Performance Optimizations
- **Early Exit Detection**: Skip reinstallation if environment already exists
- **Smart Filtering**: Only process changed constraints
- **Wheel Pre-compilation**: Cache compiled wheels for faster reinstalls
- **Pip Caching**: Leverage pip's built-in download cache
- **Pip Version Pinning**: pip < 25.2 for compatibility with pip-tools 7.5.1

### 🔧 Comprehensive Coverage
- **101 Direct Python Packages** (+ dependencies): ML, visualization, geospatial, web deployment, APIs, testing, web scraping, graph databases, documentation
  - Note: gremlinpython excluded due to unresolvable aenum dependency conflicts
- **13 R Packages**: tidyverse, bibliometrix, reticulate, and more
- **Julia Environment**: IJulia kernel with automatic setup

### 🛡️ Production-Grade Safety Features
- **Pre-flight Checks**: Validates disk space (10GB minimum), internet connectivity, write permissions, and system dependencies before installation
- **Operating System Detection**: Automatically detects macOS/Linux and adjusts commands accordingly
- **Cross-Platform Compatibility**: Full support for macOS and Linux (Ubuntu, RHEL, Fedora, etc.)
- **Environment Snapshots**: Automatic backup of working environment before making changes
- **Automatic Rollback**: Restores previous state if installation fails
- **Post-installation Health Checks**: Validates Python interpreter, critical packages (numpy, pandas, matplotlib, jupyter), and Jupyter kernels
- **Installation Metadata**: Tracks installation history, timestamps, package counts, conflict status, and OS information in `.env_metadata.json`
- **Snapshot Management**: Automatically cleans up old snapshots (keeps 2 most recent) and removes snapshot after successful installation

### 🔑 API Key Management
Automatically configures environment variables for:
- OpenAI API
- xAI API (Grok)
- Google API (Gemini)
- GitHub API (repos, gists, actions)
- Census Bureau API

**Note:** ANTHROPIC_API_KEY is intentionally **not** exported to avoid conflicts with Claude Code CLI, which uses its own authentication system via the Anthropic Console.

## API Key Configuration

### 🔑 Single Source of Truth: `.env-keys.yml`

All API keys and credentials are managed through a single YAML file with secure 600 permissions.

**Managed Credentials (8 environment variables):**
- `OPENAI_API_KEY` - OpenAI GPT models
- `XAI_API_KEY` - xAI Grok models
- `GOOGLE_API_KEY` - Google Gemini models
- `GITHUB_TOKEN` - GitHub API access
- `GITHUB_EMAIL` - Git commits and documentation
- `GITHUB_USERNAME` - Git configuration
- `GITHUB_NAME` - Full name for attribution
- `CENSUS_API_KEY` - US Census Bureau API

Plus: IPUMS credentials, ECMWF credentials

**Note:** `ANTHROPIC_API_KEY` is stored in `.env-keys.yml` but is **not** exported to the environment to prevent conflicts with Claude Code CLI, which manages its own authentication via the Anthropic Console.

### 🛠️ Smart YAML Auto-Repair

The setup script intelligently manages your API keys:

**✅ Automatic Detection**
- Loads existing keys from `.env-keys.yml`
- Detects missing keys automatically
- Creates file if it doesn't exist

**✅ Auto-Repair**
- Adds missing keys with placeholders
- Preserves existing values
- Notifies you what was added

**✅ Zero Configuration Errors**
- Script continues even with missing keys
- Clear messages about placeholders
- Explicit instructions for updating

**Example Auto-Repair Session:**

```bash
./setup_base_env.sh

🔑 Loading API keys from .env-keys.yml...
🔧 Auto-repaired YAML file - added missing keys:
   • google_api_key (placeholder added)
   • github_token (placeholder added)
   ⚠️  Please edit .env-keys.yml to add your actual API keys
✅ API keys loaded from YAML file
```

### 🔒 Security Best Practices

**Primary Storage Locations:**
1. **`.env-keys.yml`** - Single source of truth (600 permissions)
2. **`base-env/.venv/bin/activate`** - Convenience copy (auto-synced)
3. **`~/.ecmwfapirc`** - ECMWF API requirement (600 permissions)

**🚨 CRITICAL: Never Hardcode API Keys**

**DO NOT** put actual API keys in:
- Scripts or code files
- Git repositories
- Documentation files
- Chat conversations
- Screenshots or screen recordings

**Security Features:**
- ✅ 600 file permissions (owner read/write only)
- ✅ Separate from code
- ✅ Single source of truth
- ✅ Should be in `.gitignore` (automatically)
- ✅ Automatic backups by `setup_keys.sh`
- ✅ Placeholder detection

### Setting Real Keys

**Option 1: Use setup_keys.sh (Recommended)**

```bash
./setup_keys.sh
nano .env-keys.yml  # Edit with your actual keys
./setup_base_env.sh
```

**Option 2: Edit YAML directly**

```bash
nano /path/to/your/environments/directory/.env-keys.yml
# Update values, then run:
./setup_base_env.sh
```

**Option 3: Runtime loading**

```bash
source load_api_keys.sh  # Loads keys into current shell
```

### YAML File Structure

```yaml
# API Keys for this environment
# This file is only readable by you (chmod 600)

openai_api_key: 'sk-...'
anthropic_api_key: 'sk-ant-...'
xai_api_key: 'xai-...'
google_api_key: 'AIzaSyC...'

# GitHub credentials (used for API access, git operations, and documentation)
github:
  token: "ghp_..."
  email: "your-email@example.com"
  username: "your-github-username"
  name: "Your Name"

# API credentials
api_keys:
  census_api_key: "..."

# IPUMS credentials
ipums:
  username: "..."
  password: "..."

# ECMWF API credentials
ecmwf:
  url: "https://api.ecmwf.int/v1"
  key: "..."
  email: "..."
```

### Key Rotation & Emergency

**Regularly rotate your API keys at:**
- OpenAI: https://platform.openai.com/api-keys
- Anthropic: https://console.anthropic.com/settings/keys
- xAI: https://console.x.ai/
- Google/Gemini: https://makersuite.google.com/app/apikey
- GitHub: https://github.com/settings/tokens

**If keys are compromised:**
1. Immediately revoke exposed keys from provider dashboards
2. Generate new keys
3. Update `.env-keys.yml` with new keys
4. Run `./setup_base_env.sh --force-reinstall`
5. Review usage logs for unauthorized access

## Installation Requirements

### Prerequisites
- macOS (Darwin) or Linux
- [Homebrew](https://brew.sh/) (macOS)
- Git
- 10+ GB free disk space

### Automatic Installation
The script automatically installs:
- **pyenv** (Python version management)
- **Python 3.12** (via pyenv)
- **pip-tools** (for requirements compilation)
- **R** (via Homebrew on macOS)
- **Julia** (via Homebrew on macOS)

## Usage Guide

### Command-Line Options

```bash
./setup_base_env.sh [OPTIONS]

Options:
  --adaptive         Enable adaptive conflict resolution
  --force-reinstall  Remove existing environment and reinstall
  --update           Check for latest package versions and test if old conflicts are resolved
                     (automatically enables adaptive mode for intelligent resolution)
  --help             Show usage information
```

### First-Time Setup

**Important:** All setup commands must be run from the directory where you've placed the script. After activation, you can work from any directory.

1. **Navigate to the script directory**:
   ```bash
   cd /path/to/your/script/directory
   chmod +x setup_base_env.sh
   ```

2. **Configure API keys** (optional):
   ```bash
   ./setup_keys.sh
   ```
   See `README.API-KEYS.md` for details.

3. **Run the setup**:
   ```bash
   ./setup_base_env.sh
   ```

4. **Activate the environment**:
   ```bash
   source base-env/.venv/bin/activate
   ```

   Once activated, the environment is available from any directory:
   ```bash
   cd ~/your-project
   python your_script.py  # Uses the activated environment
   ```

### Updating the Environment

If `requirements.in` changes, navigate to the script directory first:

```bash
cd /path/to/your/script/directory

# Automatic detection and update
./setup_base_env.sh

# Force full reinstall
./setup_base_env.sh --force-reinstall
```

### Checking for Latest Versions (Update Mode)

The `--update` flag provides **comprehensive environment checking** for Python, R, Julia, and system dependencies:

```bash
cd /path/to/your/script/directory

# Comprehensive check of ALL environment components
./setup_base_env.sh --update
```

**What --update mode does:**

**Part 0: Homebrew Update**
1. **Updates Homebrew** package database (foundation for all checks)

**Part 1: Comprehensive Toolchain Check**
1. **Checks pyenv** version against Homebrew
2. **Checks Python** version (latest stable 3.12.x or 3.13.x)
3. **Checks pip-tools** and tests compatibility with latest pip in isolated environment
4. **Checks R** version via Homebrew
5. **Checks Julia** version via Homebrew
6. **Checks system dependencies** (libgit2, libpq, openssl@3) via Homebrew
7. **Reports comprehensive summary** of all toolchain components

**Part 2: Python Package Check**
1. **Backs up** current `requirements.in`
2. **Temporarily relaxes** smart constraints to test latest versions
3. **Compares** current vs. latest for all 8 smart constraint packages
4. **Creates temporary test environment** to check for conflicts
5. **Reports findings** with detailed version comparisons

**Part 3: Evaluate Results and Conditionally Apply Updates**
1. **Evaluates ALL test results** (toolchain + packages)
2. **ONLY offers updates if ALL tests pass** - maximum stability guarantee
3. **Automatic updates** (if tests passed):
   - Installs latest Python via pyenv
   - Updates pip and pip-tools
   - Updates requirements.in with latest package versions
4. **Manual updates recommended** (shown after automatic updates):
   - R: `brew upgrade r`
   - Julia: `brew upgrade julia`
   - System deps: `brew upgrade libgit2 libpq openssl@3`
5. **Offers 10-second timeout** to cancel before applying
6. **Refuses to apply** if any test fails, maintaining stability
7. **Provides detailed reasoning** when updates cannot be applied

**When to use:**
- Monthly or quarterly comprehensive maintenance
- After major Python, R, Julia, or Homebrew updates
- When investigating if old conflicts have been resolved
- Before starting new projects to ensure all components are current

**Note:** Update mode automatically enables adaptive conflict resolution for intelligent handling of any issues.

### Testing the Environment

```bash
source base-env/.venv/bin/activate

# Test Python packages
python -c "import pandas, numpy, sklearn, plotly; print('✅ Core packages work')"

# Test Jupyter kernel
jupyter kernelspec list

# Test R integration
python -c "from rpy2.robjects import r; print('✅ R integration works')"
```

## Production-Grade Safety Features

The setup script includes multiple layers of protection to ensure reliable, fail-safe installations:

### 🛡️ Pre-flight Checks

Before making any changes, the script validates:

1. **Operating System Detection**: Detects macOS or Linux, identifies architecture (x86_64, arm64, etc.)
2. **Platform Compatibility**: Ensures OS is supported (macOS, Linux); warns if running on Windows
3. **Disk Space**: Ensures at least 10GB of free space is available (cross-platform df command handling)
4. **Internet Connectivity**: Tests connection to PyPI and Google DNS
5. **Write Permissions**: Verifies script can write to the environment directory
6. **System Dependencies**: Checks for git, curl, and platform-specific package managers
7. **Build Tools**: On Linux, checks for gcc and make (needed for compiling Python packages)
8. **Metadata Loading**: Reads existing installation history if available

If any critical check fails, the script exits immediately before making changes.

**Cross-Platform Support:**
- **macOS**: Uses Homebrew for system packages, df -g for disk space
- **Linux**: Supports apt (Ubuntu/Debian), yum (RHEL/CentOS), dnf (Fedora), uses df -BG for disk space
- **Shell Detection**: Auto-detects zsh, bash, or sh and configures appropriately
- **Platform-Specific Commands**: Automatically adjusts sed syntax and other commands based on OS

### 📸 Environment Snapshots

**Automatic Backup Creation:**
- Before making any changes, the script creates a complete backup of your current `.venv` directory
- Snapshots are stored as `.venv.snapshot_YYYYMMDD_HHMMSS/`
- Each snapshot includes metadata:
  - Timestamp of snapshot creation
  - Python and pip versions
  - Package count
  - Copy of `requirements.txt` and `requirements.lock.txt`

**Automatic Cleanup:**
- Keeps only the 2 most recent snapshots to save disk space
- Removes snapshot after successful installation (no longer needed)
- Older snapshots are automatically pruned

### 🔄 Automatic Rollback

**Error Detection:**
- Error trapping is enabled during the installation phase (`set -e` and `trap`)
- Any command failure triggers automatic rollback
- Failures during pip-compile, wheel building, or package installation are caught

**Rollback Process:**
- Removes the failed `.venv` directory
- Restores the most recent snapshot
- Shows metadata about the restored environment
- Exits with clear error message

**Manual Rollback:**
If you need to manually restore a snapshot:
```bash
cd base-env
rm -rf .venv
mv .venv.snapshot_YYYYMMDD_HHMMSS .venv
source .venv/bin/activate
```

### 🏥 Post-Installation Health Checks

After successful package installation, the script validates:

1. **Python Interpreter**: Verifies Python can run and display version
2. **Critical Packages**: Tests imports of numpy, pandas, matplotlib, jupyter, ipykernel
3. **Jupyter Kernel**: Checks if Python3 kernel is available
4. **Environment Size**: Reports disk space used by environment

If critical checks fail, you're prompted to rollback or continue at your own risk.

### 📝 Installation Metadata

The script maintains a `.env_metadata.json` file that tracks:

```json
{
  "last_successful_install": "2025-10-25 14:30:00",
  "os_platform": "macos",
  "os_type": "Darwin",
  "os_arch": "arm64",
  "python_version": "3.12.7",
  "pip_version": "24.3.1",
  "packages_count": 450,
  "has_conflicts": false,
  "installation_mode": "adaptive"
}
```

**Use Cases:**
- Track when environment was last successfully updated
- Identify which mode was used for installation
- Monitor package count growth over time
- Quick conflict status check

**Location:** `base-env/.env_metadata.json` (excluded from git via `.gitignore`)

### 🧹 Excluded from Git

The following safety-related files are automatically excluded from version control:

```
.venv.snapshot_*/          # Snapshot backups
.env_metadata.json         # Installation metadata
*.log                      # Log files
```

This prevents bloating the repository while maintaining local safety features.

## Package Management Strategy

### Smart Constraints (8 packages)

These packages have historically caused dependency conflicts. We pin specific versions:

| Package | Version | Reason |
|---------|---------|--------|
| `numpy` | >=1.20.0 | Minimum version for core scientific computing compatibility |
| `ipywidgets` | 8.1.7 | Jupyter widget compatibility with notebook ecosystem |
| `geemap` | 0.36.4 | Pinned for Google Earth Engine API compatibility |
| `plotly` | 5.15.0 | v6+ has breaking changes - pinned to stable 5.x |
| `panel` | 1.8.2 | Dashboard framework pinned for stability |
| `bokeh` | 3.8.0 | Historical stability issues with newer versions |
| `voila` | 0.5.11 | Web app conversion stability with ipywidgets==8.1.7 |
| `selenium` | 4.36.0 | Browser automation - latest stable version |

**Removed**: `jupyter-dash` (obsolete), `nose` (deprecated since 2015), `bqplot` and `jupyterlab` (no longer require pinning)

### Special Package Installation

Some packages require installation from alternative sources because they are not available on PyPI:

| Package | Source | Installation Method | Reason |
|---------|--------|---------------------|--------|
| `ecmwfapi` | GitHub | `pip install git+https://github.com/ecmwf/ecmwf-api-client.git` | Not published to PyPI |

**🔧 Automatic Handling**: The setup script automatically detects and installs these special packages from their respective sources. You don't need to do anything manually.

**📝 Note**: If you encounter errors about missing packages that seem like they should be in `requirements.txt`, check if they might be special cases like `ecmwfapi`. The script handles these separately after the main package installation.

### Conflict Resolution

**Tier 1: Fast Strategy (Default)**
- Apply smart constraints before compilation
- Fast, deterministic resolution
- Prevents 95% of conflicts

**Tier 2: Adaptive Strategy (--adaptive)**
- Iterative constraint relaxation
- Used only when Fast strategy fails
- Slower but handles edge cases

### Requirements Files

- **`requirements.in`**: Human-maintained package list with smart constraints
- **`requirements.txt`**: Compiled with exact versions (auto-generated)
- **`constraints.txt`**: Smart constraints applied during compilation

## Project Structure

```
base-env/
├── .venv/                    # Python virtual environment
│   ├── bin/activate         # Activation script (includes API keys)
│   ├── lib/python3.12/      # Installed packages
│   └── .claude_env_marker   # Environment metadata
├── requirements.in          # Human-maintained package list
├── requirements.txt         # Compiled exact versions
└── constraints.txt          # Smart constraints
```

## Package Categories

### 📊 Data Manipulation (6)
numpy, pandas, pyarrow, duckdb, dask-geopandas

### 🤖 Machine Learning (5)
scikit-learn, xgboost, lightgbm, catboost, h2o

### 📈 Visualization (10)
matplotlib, seaborn, plotly, bokeh, altair, dash, fast-dash, dash-leaflet

### 🌍 Geospatial Tools (4)
geopandas, geemap, earthengine-api, spyndex

### 🧪 Interactive Development (5)
jupyter, ipython, ipywidgets, voila, nbgrader

### 🌐 Web Deployment (8)
streamlit, dash, panel, gradio, flask, fastapi, pywebio, nbconvert

### 🤖 API Clients (5)
openai, anthropic, requests, httpx, transformers

### 🌦️ Scientific Data APIs (3)
cdsapi, ecmwfapi (GitHub), netCDF4

### 💰 Financial Data APIs (3)
yfinance, yahoofinancials, pandas-datareader

### 🗺️ Census & Geographic Data (2)
census, us

### 🌐 Web Automation & Scraping (4)
selenium, beautifulsoup4, scholarly, tweepy

### 🎞️ Scientific Animation (5)
manim, pyvista, k3d, sympy, p5

### 🖼️ Media Processing (6)
Pillow, opencv-python, moviepy, imageio, ffmpeg-python, embedchain

### 📚 Bibliography Tools (2)
pybtex, pyplantuml

### 🧪 Testing & Autograding (4)
pytest, nbgrader, otter-grader, nbval

### 🔤 Natural Language Processing (1)
nltk

### 🔥 Scientific Computing (1)
cantera (thermodynamics/chemistry)

## Troubleshooting

### Installation Fails

**pyenv not found:**

```bash
# The script should auto-install, but if needed:
brew install pyenv
echo 'export PYENV_ROOT="$HOME/.pyenv"' >> ~/.zshrc
echo 'export PATH="$PYENV_ROOT/bin:$PATH"' >> ~/.zshrc
echo 'eval "$(pyenv init --path)"' >> ~/.zshrc
source ~/.zshrc
```

**Python 3.12 installation fails:**

```bash
# Install build dependencies
brew install openssl readline sqlite3 xz zlib
pyenv install 3.12
```

**Dependency conflicts:**

```bash
# Try adaptive resolution
./setup_base_env.sh --adaptive

# Or force reinstall
./setup_base_env.sh --force-reinstall
```

### Package Issues

**Import errors after installation:**

```bash
# Verify package installed
pip show <package-name>

# Try reinstalling specific package
pip install --force-reinstall <package-name>
```

**Jupyter kernel not found:**

```bash
source base-env/.venv/bin/activate
python -m ipykernel install --user --name base-env --display-name "Python 3.12 (base-env)"
```

**R kernel issues:**

```bash
# Reinstall IRkernel
R -e "install.packages('IRkernel', repos='https://cloud.r-project.org')"
R -e "IRkernel::installspec(name='ir', displayname='R')"
```

### Performance Issues

**Slow installation:**
- The script uses caching and wheel pre-compilation
- First run is slower (~5-10 minutes)
- Subsequent runs are faster (~2-3 minutes)

**Disk space:**

```bash
# Check environment size
du -sh base-env/

# Clean up pip cache if needed
pip cache purge
```

## Version History

See `Old/README.md` for historical versions:
- **V3** (October 2025): Current version with smart constraints, performance optimizations
- **V2** (June 2025): Introduced pip-tools and pyenv
- **V1** (March-April 2025): Original implementations

## Related Files

- **`setup_keys.sh`**: Interactive API key configuration
- **`README.API-KEYS.md`**: API key management documentation
- **`Old/README.md`**: Archive of previous versions
- **`requirements.in`**: Package list (edit this to add packages)

## Support & Maintenance

**Adding new packages:**
1. Edit `base-env/requirements.in`
2. Run `./setup_base_env.sh`
3. Test the environment

**Updating packages:**
1. Modify versions in `requirements.in`
2. Run `./setup_base_env.sh`
3. If conflicts occur, add to smart constraints

**Reporting issues:**
- Check `Old/README.md` for historical context
- Review troubleshooting section above
- Verify pyenv and Python 3.12 are working

---

**Last Updated:** October 25, 2025
**Maintained by:** David Lary
**Python Version:** 3.12
**Total Packages:** Python (101 direct + dependencies), R (13), Julia (IJulia)
**Note:** gremlinpython excluded due to unresolvable aenum dependency conflicts
