# Version 3.3 Changelog (October 2025)

## Summary

Version 3.3 adds 5 new enhancements (bringing total to 21) and 12 essential packages (bringing total to 125), with focus on **ROBUSTNESS > COMPLEXITY**.

## New Enhancements (5)

### Enhancement 17: Undefined Variable Detection
- **Feature:** `set -u` flag catches undefined variables instantly
- **Benefit:** Prevents silent failures from typos in variable names
- **Status:** Already existed in script (`set -euo pipefail`)
- **Location:** Line 20 of setup_base_env.sh

### Enhancement 18: Security Vulnerability Scanning
- **Feature:** pip-audit scans for known CVEs post-installation
- **Benefit:** Proactive security monitoring, identifies known vulnerabilities
- **Implementation:** Non-blocking warnings with remediation guidance
- **Location:** Lines 2741-2753 (Check 5 in health checks)

### Enhancement 19: Extended Error Context
- **Feature:** Error messages now include function name, line number, failed command, exit code, and last 3 log lines
- **Benefit:** Much faster debugging with detailed failure context
- **Implementation:** Enhanced trap_failure() function
- **Location:** Lines 816-839

### Enhancement 20: Graceful Degradation for R/Julia
- **Feature:** R and Julia installation failures no longer block Python environment setup
- **Benefit:** Python environment succeeds even if R/Julia fail, better user experience
- **Implementation:** Temporary error exit disable with success tracking
- **Location:** Lines 2825-2912

### Enhancement 21: Package Expansion
- **Feature:** Added 12 essential packages for deep learning, scientific data, LLM, NLP
- **Packages:** torch, tensorflow, keras, xarray, zarr, h5py, pint, rpy2, langchain, spacy, jupyterlab, papermill
- **Total packages:** 125 (from 113)

## New Packages (12)

### Deep Learning Frameworks (3)
1. **torch** - PyTorch for dynamic neural networks
2. **tensorflow** - Production ML platform
3. **keras** - High-level neural networks API

### Scientific Data Formats (4)
4. **xarray** - N-dimensional labeled arrays (essential for climate/atmospheric research)
5. **zarr** - Cloud-native chunked array storage
6. **h5py** - HDF5 binary data format
7. **pint** - Physical units and conversions

### Modern Tools (5)
8. **jupyterlab** - Modern notebook interface (replaces classic jupyter notebook UI)
9. **papermill** - Parameterize and execute notebooks
10. **rpy2** - Python-R bridge for Jupyter
11. **langchain** - LLM application framework
12. **spacy** - Industrial-strength NLP

## Files Modified

### Core Script
- `setup_base_env.sh` - Updated to v3.3 with all enhancements

### Requirements
- `requirements.in` - Added 12 new packages (125 total)

### Documentation
- `README_setup_base_env.md` - Updated to v3.3 with new features
- `README_how_to_update_setup_base_env.md` - Updated with v3.3 process

### Research
- `ENHANCEMENTS_V3.3_RESEARCH.md` - Research document for the 4 new enhancements

## Version History

- **v3.1:** 10 enhancements (102 packages)
- **v3.2:** +6 refinements (113 packages, +11)
- **v3.3:** +5 enhancements (125 packages, +12)
- **Total:** 21 enhancements, 125 packages

## Testing Status

- ✅ All enhancements implemented
- ✅ Script version updated
- ✅ Documentation updated
- ✅ Git exclusions verified (Code/, Class/, Docker/)
- ⏳ End-to-end testing pending
- ⏳ Git commit and push pending

## Compatibility

- Python: 3.12 (managed via pyenv)
- Platforms: macOS (Intel/ARM), Linux (Ubuntu, RHEL, Fedora)
- R: Optional (gracefully skips if installation fails)
- Julia: Optional (gracefully skips if installation fails)

## Breaking Changes

None. All changes are additive and backward compatible.
