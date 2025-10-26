# Enhancement Plan for v3.2: Additional Robustness Features

**Date:** October 25, 2025
**Status:** Planning Document
**Priority:** Robustness > Complexity

## New Packages Added (7)

1. **sqlalchemy** - SQL toolkit and ORM (>=2.0.0)
2. **psycopg2-binary** - PostgreSQL adapter (>=2.9.0)
3. **polars** - Fast DataFrame library in Rust (>=0.19.0)
4. **statsmodels** - Statistical models and tests (>=0.14.0)
5. **joblib** - Parallel computing library (>=1.3.0)
6. **boto3** - AWS SDK for Python (>=1.28.0)
7. **feedparser** - RSS/Atom feed parser (>=6.0.0)

**Total Package Count:** 102 → 109 direct packages

---

## 6 Additional Robustness Enhancements

### Enhancement 11: Adaptive Parallel Streams (CPU + Memory Aware)

**Current State:** Hardcoded `PIP_PARALLEL_BUILDS=4`

**Enhancement:**
```bash
# Detect CPU cores (cross-platform)
CPU_CORES=$(sysctl -n hw.ncpu || nproc || echo "4")

# Calculate optimal: min(cores/2, 8) with memory check
if [ "$FREE_MEM_GB" -ge 4 ]; then
  OPTIMAL_PARALLEL=$(( CPU_CORES / 2 ))
  [ "$OPTIMAL_PARALLEL" -lt 2 ] && OPTIMAL_PARALLEL=2
  [ "$OPTIMAL_PARALLEL" -gt 8 ] && OPTIMAL_PARALLEL=8
else
  OPTIMAL_PARALLEL=1  # Safety first
fi

# Allow user override
OPTIMAL_PARALLEL=${PIP_PARALLEL_BUILDS:-$OPTIMAL_PARALLEL}
```

**Benefits:**
- Optimizes for available hardware
- Prevents OOM on low-memory systems
- Conservative limits (max 8) for robustness
- User override for expert control

**Robustness Trade-off:** ✅ FAVORS ROBUSTNESS
- Defaults to 1 if memory < 4GB
- Uses conservative formula (cores/2, not cores)
- Maximum cap of 8 even on 64-core systems

---

### Enhancement 12: Network Resilience with Retries

**Current State:** Single-try network operations

**Enhancement:**
```bash
# Exponential backoff retry function
retry_with_backoff() {
  local max_attempts=3
  local timeout=2
  local attempt=1

  while [ $attempt -le $max_attempts ]; do
    if "$@"; then
      return 0
    fi

    echo "⚠️  Attempt $attempt failed, retrying in ${timeout}s..."
    sleep $timeout
    timeout=$(( timeout * 2 ))
    attempt=$(( attempt + 1 ))
  done

  return 1
}

# Use PyPI mirrors on failure
PIP_INDEX_URLS=(
  "https://pypi.org/simple"
  "https://mirrors.aliyun.com/pypi/simple/"
  "https://pypi.tuna.tsinghua.edu.cn/simple"
)
```

**Benefits:**
- Handles transient network failures
- Exponential backoff prevents server overload
- Mirror fallback for geographic/political issues
- Automatic recovery from temporary outages

**Robustness Trade-off:** ✅ FAVORS ROBUSTNESS
- Conservative 3 attempts max
- Long timeouts to avoid false negatives
- Mirrors only used as fallback

---

### Enhancement 13: Pip Cache Corruption Detection

**Current State:** Assumes cache is always valid

**Enhancement:**
```bash
# Detect and fix corrupted pip cache
check_pip_cache_health() {
  local cache_dir="$PIP_CACHE_DIR"

  # Check for .tmp files (interrupted downloads)
  local tmp_count=$(find "$cache_dir" -name "*.tmp" 2>/dev/null | wc -l)
  if [ "$tmp_count" -gt 50 ]; then
    echo "⚠️  Found $tmp_count incomplete downloads in cache"
    echo "🧹 Cleaning corrupted cache files..."
    find "$cache_dir" -name "*.tmp" -delete
    log_warn "Cleaned $tmp_count corrupted cache files"
  fi

  # Check cache size (>10GB is suspicious)
  local cache_size=$(du -sg "$cache_dir" 2>/dev/null | awk '{print $1}')
  if [ "$cache_size" -gt 10 ]; then
    echo "⚠️  Pip cache is ${cache_size}GB (unusually large)"
    echo "💡 Consider running: pip cache purge"
  fi
}
```

**Benefits:**
- Prevents installation failures from corrupted cache
- Automatic cleanup of incomplete downloads
- Warns about bloated caches
- No data loss (only removes .tmp files)

**Robustness Trade-off:** ✅ FAVORS ROBUSTNESS
- Only removes clearly bad files (.tmp)
- Warns but doesn't auto-delete large caches
- Conservative 50-file threshold

---

### Enhancement 14: System Package Manager Lock Detection

**Current State:** No detection of apt/yum locks

**Enhancement:**
```bash
# Check if system package manager is locked (Linux)
check_package_manager_lock() {
  if [ "$OS_PLATFORM" != "linux" ]; then
    return 0
  fi

  local locked=0

  # Check for apt lock
  if command -v apt-get &>/dev/null; then
    if fuser /var/lib/dpkg/lock >/dev/null 2>&1; then
      echo "⚠️  apt package manager is locked (another process using it)"
      locked=1
    fi
  fi

  # Check for yum/dnf lock
  if command -v yum &>/dev/null || command -v dnf &>/dev/null; then
    if [ -f /var/run/yum.pid ]; then
      echo "⚠️  yum package manager is locked"
      locked=1
    fi
  fi

  if [ "$locked" = "1" ]; then
    echo "💡 Wait for system updates to complete, then re-run this script"
    return 1
  fi

  return 0
}
```

**Benefits:**
- Prevents mysterious failures during Python compilation
- Clear error messages
- Avoids conflicts with system updates
- Specific to Linux (where this is common)

**Robustness Trade-off:** ✅ FAVORS ROBUSTNESS
- Fails fast instead of mysterious errors
- Gives clear instructions
- Linux-specific (doesn't affect macOS)

---

### Enhancement 15: Enhanced DNS/Network Diagnostics

**Current State:** Simple ping check

**Enhancement:**
```bash
# Comprehensive network diagnostics
check_network_connectivity() {
  echo "🌐 Enhanced network connectivity check..."

  # Test 1: DNS resolution
  if ! host pypi.org >/dev/null 2>&1 && ! nslookup pypi.org >/dev/null 2>&1; then
    echo "❌ DNS resolution failed for pypi.org"
    echo "💡 Check DNS settings (/etc/resolv.conf on Linux)"
    return 1
  fi

  # Test 2: HTTPS connectivity
  if ! curl -Is --connect-timeout 5 https://pypi.org >/dev/null 2>&1; then
    echo "❌ HTTPS connection to pypi.org failed"
    echo "💡 Check firewall/proxy settings"
    return 1
  fi

  # Test 3: Download speed test (optional)
  if command -v curl &>/dev/null; then
    local speed=$(curl -o /dev/null -s -w '%{speed_download}' https://pypi.org/simple/ 2>/dev/null)
    echo "✅ Network OK (download speed: ${speed} bytes/sec)"
  fi

  return 0
}
```

**Benefits:**
- Diagnoses DNS vs connectivity vs firewall issues
- Specific error messages for each failure type
- Optional speed test for performance issues
- Uses multiple tools (host/nslookup/curl)

**Robustness Trade-off:** ✅ FAVORS ROBUSTNESS
- Multiple fallback checks
- Timeouts to prevent hangs
- Clear diagnostic messages

---

### Enhancement 16: Python Version Compatibility Pre-check

**Current State:** Installs packages, may fail

**Enhancement:**
```bash
# Check Python version compatibility for packages
check_python_compatibility() {
  local python_version=$(python --version 2>&1 | awk '{print $2}')
  local python_major=$(echo $python_version | cut -d. -f1)
  local python_minor=$(echo $python_version | cut -d. -f2)

  echo "🐍 Python version compatibility check: $python_version"

  # Check for known incompatibilities
  if [ "$python_major" -eq 3 ] && [ "$python_minor" -ge 13 ]; then
    echo "⚠️  Python 3.13+ detected - some packages may have compatibility issues"
    echo "💡 Consider using Python 3.12 for maximum compatibility"
  fi

  # Check if python version matches venv
  local venv_python=$(cat .venv/pyvenv.cfg 2>/dev/null | grep "version" | awk '{print $3}')
  if [ -n "$venv_python" ] && [ "$venv_python" != "$python_version" ]; then
    echo "⚠️  Python version mismatch:"
    echo "   Active: $python_version"
    echo "   Venv:   $venv_python"
    echo "💡 Consider rebuilding venv with: ./setup_base_env.sh --force-reinstall"
  fi
}
```

**Benefits:**
- Early warning about version compatibility
- Detects venv/python mismatches
- Specific recommendations
- Non-blocking (warnings only)

**Robustness Trade-off:** ✅ FAVORS ROBUSTNESS
- Warnings, not errors
- Doesn't prevent installation
- Provides clear remediation steps

---

## Implementation Priority (Robustness-First)

1. **CRITICAL:** Enhancement 11 (Adaptive Parallel) - User specifically requested
2. **HIGH:** Enhancement 13 (Pip Cache) - Prevents mysterious failures
3. **HIGH:** Enhancement 15 (Network Diagnostics) - Better error messages
4. **MEDIUM:** Enhancement 12 (Network Retry) - Handles transient failures
5. **MEDIUM:** Enhancement 16 (Python Compatibility) - Early warnings
6. **LOW:** Enhancement 14 (Package Manager Lock) - Linux-specific edge case

---

## Robustness Analysis

**All enhancements follow the principle: ROBUSTNESS > COMPLEXITY**

✅ Conservative defaults (e.g., max 8 parallel streams)
✅ Fail-safe fallbacks (e.g., sequential mode if low memory)
✅ Clear error messages with remediation steps
✅ No destructive operations (e.g., only delete .tmp files)
✅ User overrides available for experts
✅ Cross-platform compatibility maintained
✅ Backward compatible (no breaking changes)

---

## Testing Plan

1. **Low-memory test:** 2GB RAM system → should use sequential mode
2. **High-core test:** 16-core system → should cap at 8 parallel
3. **Network failure test:** Disconnect, verify retries work
4. **Cache corruption test:** Create .tmp files, verify cleanup
5. **Python mismatch test:** Different venv Python, verify warning
6. **Cross-platform test:** macOS (Intel/ARM) and Linux (x86_64/ARM64)

---

## Documentation Updates Needed

1. **README.md:** Add "16 Total Enhancements" section
2. **README_setup_base_env.md:** Update package count (102→109)
3. **README_how_to_update_setup_base_env.md:** Add v3.2 section
4. **setup_base_env.sh:** Inline comments for each enhancement

---

**Next Steps:** Implement Enhancement 11 (Adaptive Parallel) first as user specifically requested this feature.
