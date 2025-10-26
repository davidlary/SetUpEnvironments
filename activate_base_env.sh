#!/bin/bash
#
# Quick activation script for base-env
# Usage: source activate_base_env.sh
#

ENV_DIR="$HOME/Dropbox/Environments/base-env"

if [ ! -d "$ENV_DIR/.venv" ]; then
    echo "❌ Environment not found at: $ENV_DIR/.venv"
    echo "   Run setup_base_env.sh first"
    return 1 2>/dev/null || exit 1
fi

# Activate the environment
source "$ENV_DIR/.venv/bin/activate"

# Verify it worked
if [ -n "$VIRTUAL_ENV" ]; then
    echo "✅ Base environment activated!"
    echo "   Python: $(python --version)"
    echo "   Location: $VIRTUAL_ENV"
    echo ""
    echo "💡 Quick test: python -c \"import pandas, numpy, sklearn; print('Environment ready!')\""
    echo "💡 Deactivate: deactivate"
else
    echo "❌ Failed to activate environment"
    return 1 2>/dev/null || exit 1
fi
