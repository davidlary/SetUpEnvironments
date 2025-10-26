# Base Environment - Quick Reference Card

## 🚀 Daily Usage

### Option 1: Use Helper Script (Easiest)
```bash
source ~/Dropbox/Environments/activate_base_env.sh
```

### Option 2: Manual Activation
```bash
cd ~/Dropbox/Environments/base-env
source .venv/bin/activate
```

### Verify It Works
```bash
# After activation, test it:
python -c "import pandas, numpy, sklearn; print('✅ Environment ready!')"

# Or run comprehensive verification:
~/Dropbox/Environments/verify_env.sh
```

### Deactivate When Done
```bash
deactivate
```

---

## 📋 Common Commands

### Check What's Installed
```bash
# Must activate first!
source ~/Dropbox/Environments/activate_base_env.sh

# List all packages
pip list

# Check specific package
pip show pandas

# Check Python version
python --version
```

### Install Additional Packages
```bash
source ~/Dropbox/Environments/activate_base_env.sh
pip install package-name
```

### Update Environment
```bash
cd ~/Dropbox/Environments
./setup_base_env.sh --update
```

---

## ❌ Troubleshooting

### "ModuleNotFoundError: No module named 'pandas'"
**Cause:** Environment not activated
**Solution:**
```bash
source ~/Dropbox/Environments/activate_base_env.sh
```

### How to Tell If Activated
1. Your prompt shows `(.venv)` or `(base-env)`
2. Run: `which python` → should show `.venv` in path
3. Run: `echo $VIRTUAL_ENV` → should show environment path

---

## 📍 Key Locations

- **Environment:** `~/Dropbox/Environments/base-env/.venv`
- **Packages:** `~/Dropbox/Environments/base-env/requirements.in`
- **Activation Helper:** `~/Dropbox/Environments/activate_base_env.sh`
- **Verification:** `~/Dropbox/Environments/verify_env.sh`
- **Setup Script:** `~/Dropbox/Environments/setup_base_env.sh`

---

## 🎓 Important Concepts

### Virtual Environment = Isolated Python
- Each virtual environment is self-contained
- Packages installed in one don't affect others
- **Must activate** before use (like opening an app)
- Can work in any directory once activated

### One-Time Setup vs. Daily Use
- **One-Time:** `./setup_base_env.sh` (installs everything)
- **Daily:** `source activate_base_env.sh` (activates for use)

---

## 📞 Getting Help

### Check Installation Status
```bash
~/Dropbox/Environments/verify_env.sh
```

### Reinstall Everything
```bash
cd ~/Dropbox/Environments
./setup_base_env.sh --force-reinstall
```

### View Full Documentation
```bash
cat ~/Dropbox/Environments/README_setup_base_env.md
```
