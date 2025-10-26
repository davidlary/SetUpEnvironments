#!/bin/bash
#
# Environment Verification Script
# Run this after setup to verify everything works
#

set -e

ENV_DIR="$HOME/Dropbox/Environments/base-env"

echo "╔════════════════════════════════════════════════════════════════╗"
echo "║         Base Environment Verification                          ║"
echo "╚════════════════════════════════════════════════════════════════╝"
echo ""

# Check if environment exists
if [ ! -d "$ENV_DIR/.venv" ]; then
    echo "❌ Environment not found at: $ENV_DIR/.venv"
    echo "   Please run: cd ~/Dropbox/Environments && ./setup_base_env.sh"
    exit 1
fi

echo "✅ Environment directory exists"

# Activate environment
source "$ENV_DIR/.venv/bin/activate"
echo "✅ Environment activated"

# Check Python version
PYTHON_VERSION=$(python --version 2>&1)
echo "✅ $PYTHON_VERSION"

# Check pip version
PIP_VERSION=$(pip --version | awk '{print $2}')
echo "✅ pip $PIP_VERSION"

echo ""
echo "Testing core packages..."
echo "----------------------------------------"

# Run comprehensive test
python << 'PYTHON_EOF'
import sys

tests = [
    ("pandas", "Data manipulation"),
    ("numpy", "Numerical computing"),
    ("sklearn", "Machine learning (scikit-learn)"),
    ("matplotlib", "Plotting"),
    ("jupyter", "Interactive notebooks"),
    ("plotly", "Interactive visualization"),
    ("geopandas", "Geospatial data"),
]

failed = []
for module, description in tests:
    try:
        mod = __import__(module)
        version = getattr(mod, "__version__", "unknown")
        print(f"✅ {module:15s} {version:15s} - {description}")
    except ImportError as e:
        print(f"❌ {module:15s} FAILED - {description}")
        failed.append((module, str(e)))

if failed:
    print("\n" + "=" * 60)
    print(f"❌ {len(failed)} package(s) failed to import:")
    for module, error in failed:
        print(f"   • {module}: {error}")
    sys.exit(1)
PYTHON_EOF

echo ""
echo "╔════════════════════════════════════════════════════════════════╗"
echo "║  ✅ ALL TESTS PASSED - Environment is ready!                   ║"
echo "╚════════════════════════════════════════════════════════════════╝"
echo ""
echo "📝 To use this environment:"
echo "   1. Activate: source ~/Dropbox/Environments/activate_base_env.sh"
echo "   2. Or manually: cd ~/Dropbox/Environments/base-env && source .venv/bin/activate"
echo "   3. Deactivate when done: deactivate"
echo ""
