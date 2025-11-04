# Troubleshooting Guide

Comprehensive solutions to common issues encountered during installation and usage of AI CLI tools.

## Table of Contents

- [Quick Diagnostics](#quick-diagnostics)
- [Windows Issues](#windows-issues)
- [WSL Issues](#wsl-issues)
- [Node.js & npm Issues](#nodejs--npm-issues)
- [API Key Issues](#api-key-issues)
- [Claude Code Issues](#claude-code-issues)
- [Python & UV Issues](#python--uv-issues)
- [Network Issues](#network-issues)
- [Getting More Help](#getting-more-help)

---

## Quick Diagnostics

### Run These First

```powershell
# Windows - Check versions
node --version
npm --version
git --version
npx --version

# Run verification
.\scripts\verify-installation.ps1
```

```bash
# WSL - Check versions
node --version
npm --version
git --version
python3 --version
uv --version

# Run verification
bash scripts/verify-installation.sh
```

### Check Logs

**Windows:**
```powershell
# Find recent installation logs
Get-ChildItem $env:TEMP\ai-cli-setup-*.log | Sort-Object LastWriteTime -Descending | Select-Object -First 1

# View log
notepad "$env:TEMP\ai-cli-setup-latest.log"
```

**WSL:**
```bash
# Find recent installation logs
ls -t /tmp/ai-cli-setup-*.log | head -n 1

# View log
less /tmp/ai-cli-setup-*.log
```

---

## Windows Issues

### Execution Policy Error

**Error Message:**
```
install-windows.ps1 cannot be loaded because running scripts is disabled on this system
```

**Cause:** PowerShell's execution policy is preventing script execution.

**Solution 1 (Recommended):**
```powershell
# Run as Administrator
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser

# Verify
Get-ExecutionPolicy -List
```

**Solution 2 (Temporary):**
```powershell
# One-time bypass
PowerShell.exe -ExecutionPolicy Bypass -File .\install-windows.ps1
```

**Solution 3 (Least secure):**
```powershell
# Only if other methods fail
Set-ExecutionPolicy -ExecutionPolicy Unrestricted -Scope CurrentUser
```

### winget Not Found

**Error Message:**
```
winget: The term 'winget' is not recognized
```

**Causes:**
- App Installer not installed
- Windows version too old
- PATH not configured

**Solution 1 - Install App Installer:**
1. Open Microsoft Store
2. Search for "App Installer"
3. Click "Get" or "Update"
4. Restart PowerShell

**Solution 2 - Manual Download:**
1. Visit: https://github.com/microsoft/winget-cli/releases
2. Download latest `.msixbundle`
3. Double-click to install
4. Restart PowerShell

**Solution 3 - Update Windows:**
```powershell
# Check Windows version
winver

# Update via Settings > Update & Security > Windows Update
```

**Workaround - Manual Installation:**
If winget continues to fail, install tools manually:
1. **Node.js**: https://nodejs.org/ (download LTS installer)
2. **Git**: https://git-scm.com/download/win (download installer)

### Administrator Privileges

**Error Message:**
```
This operation requires elevation
```

**Solution:**
1. Close current PowerShell
2. Right-click PowerShell icon
3. Select "Run as Administrator"
4. Navigate back to project directory
5. Run installation script again

### PATH Not Updated

**Symptoms:**
- `node: command not found` after installation
- `npm: command not found` after installation

**Solution 1 - Restart PowerShell:**
```powershell
# Close and reopen PowerShell
exit
```

**Solution 2 - Refresh PATH:**
```powershell
# Manually refresh PATH
$env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User")

# Verify
node --version
npm --version
```

**Solution 3 - System Restart:**
- Some installations require a full reboot
- Save your work and restart Windows

### Long Path Issues

**Error Message:**
```
The specified path, file name, or both are too long
```

**Solution:**
```powershell
# Enable long paths (requires Admin)
New-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\FileSystem" `
-Name "LongPathsEnabled" -Value 1 -PropertyType DWORD -Force

# Restart computer
```

---

## WSL Issues

### WSL Not Installed

**Error Message:**
```
wsl: command not found
```

**Solution - Install WSL:**
```powershell
# In PowerShell as Administrator
wsl --install

# Specify Ubuntu (optional)
wsl --install -d Ubuntu-22.04

# Restart computer
```

**Verify Installation:**
```powershell
wsl --status
wsl --list --verbose
```

### WSL Version 1 (Should Upgrade to WSL 2)

**Check WSL Version:**
```powershell
wsl --list --verbose
# Look for "VERSION" column
```

**Upgrade to WSL 2:**
```powershell
# Set WSL 2 as default
wsl --set-default-version 2

# Convert existing distro
wsl --set-version Ubuntu 2

# Update WSL
wsl --update
```

### Ubuntu Not Starting

**Symptoms:**
- WSL opens but closes immediately
- Error codes displayed

**Solution 1 - Restart WSL:**
```powershell
# Shutdown WSL
wsl --shutdown

# Start again
wsl
```

**Solution 2 - Reinstall Distribution:**
```powershell
# List distros
wsl --list

# Unregister (WARNING: Deletes all data)
wsl --unregister Ubuntu

# Reinstall
wsl --install -d Ubuntu-22.04
```

**Solution 3 - Check Virtualization:**
```powershell
# Ensure Hyper-V is enabled
# Settings > Apps > Optional Features > More Windows Features
# Check: Hyper-V, Virtual Machine Platform, Windows Subsystem for Linux
```

### Permission Denied (sudo)

**Error Message:**
```
username is not in the sudoers file
```

**Solution:**
1. This usually indicates incorrect Ubuntu setup
2. Reinstall Ubuntu from Microsoft Store
3. During first-time setup, create a user with sudo access
4. Test: `sudo apt update`

### Permission Denied (scripts)

**Error Message:**
```
bash: ./install-wsl.sh: Permission denied
```

**Solution:**
```bash
# Make script executable
chmod +x install-wsl.sh
chmod +x scripts/verify-installation.sh

# Or run with bash explicitly
bash install-wsl.sh
```

### apt Package Manager Issues

**Error: Package Not Found**
```bash
# Update package lists
sudo apt update

# If update fails, check internet
ping google.com
```

**Error: apt-get lock**
```
E: Could not get lock /var/lib/dpkg/lock-frontend
```

**Solution:**
```bash
# Wait for automatic updates to finish
# Or force unlock (careful!)
sudo rm /var/lib/dpkg/lock-frontend
sudo rm /var/lib/dpkg/lock
sudo dpkg --configure -a
sudo apt update
```

---

## Node.js & npm Issues

### npm Command Not Found

**After Installing Node.js:**

**Windows:**
```powershell
# Verify Node.js installed
node --version

# Check npm directory exists
Test-Path "$env:ProgramFiles\nodejs\node_modules\npm"

# Reinstall Node.js if needed
winget uninstall OpenJS.NodeJS.LTS
winget install OpenJS.NodeJS.LTS
```

**WSL:**
```bash
# Check Node.js installed
node --version

# Check npm installed
which npm

# Reinstall if needed
sudo apt remove nodejs npm
sudo apt autoremove
# Then run install-wsl.sh again
```

### npx Command Not Found

**npx usually comes with npm >= 5.2.0**

**Solution:**
```bash
# Check npm version
npm --version

# Update npm
npm install -g npm@latest

# Verify npx
npx --version
```

### Package Installation Fails

**Error: EACCES permission denied**

**Solution (WSL/Linux):**
```bash
# Fix npm permissions
mkdir ~/.npm-global
npm config set prefix '~/.npm-global'
echo 'export PATH=~/.npm-global/bin:$PATH' >> ~/.bashrc
source ~/.bashrc

# Install packages
npm install -g <package-name>
```

**Solution (Windows):**
```powershell
# Run PowerShell as Administrator
# Then install packages
```

### Node Version Issues

**Error: Requires Node.js >= X.X.X**

**Check Version:**
```bash
node --version
```

**Update Node.js:**

**Windows:**
```powershell
winget upgrade OpenJS.NodeJS.LTS
```

**WSL:**
```bash
# Check current version
node --version

# Update via NodeSource
curl -fsSL https://deb.nodesource.com/setup_20.x | sudo -E bash -
sudo apt-get install -y nodejs

# Verify
node --version
```

---

## API Key Issues

### Key File Not Found

**Error:**
```
API key file not found: .credentials/anthropic.key
```

**Solution:**
```bash
# Check file exists
ls -la .credentials/

# Create key file if missing
echo -n "your-api-key-here" > .credentials/anthropic.key

# Verify permissions
chmod 600 .credentials/anthropic.key
```

### Invalid API Key Format

**Error:**
```
Invalid API key format
```

**Checklist:**

1. **No extra characters:**
   ```bash
   # Check for hidden characters
   cat .credentials/anthropic.key | od -c

   # Should show only the key, no quotes, spaces, or newlines
   ```

2. **Correct format:**
   - Anthropic: `sk-ant-api03-...` (108 chars)
   - Google: `AIza...` (39 chars)

3. **Recreate file:**
   ```bash
   # Delete and recreate
   rm .credentials/anthropic.key
   echo -n "sk-ant-api03-your-key" > .credentials/anthropic.key
   ```

### Authentication Failed

**Error:**
```
401 Unauthorized
```

**Solutions:**

1. **Verify key is active** in provider console
2. **Check key hasn't been revoked**
3. **Regenerate key** if needed
4. **Check API quotas** haven't been exceeded

---

## Claude Code Issues

### Claude Code Not Working

**Error:**
```
Command '@anthropic-ai/claude-code' not found
```

**Solution:**
```bash
# Try with full npx command
npx @anthropic-ai/claude-code --version

# Clear npm cache
npm cache clean --force

# Try again
npx @anthropic-ai/claude-code
```

### First Run Takes Forever

**Symptom:** `npx @anthropic-ai/claude-code` hangs on first run

**Explanation:** npx downloads the package on first use (this is normal)

**Solution:**
- **Be patient** (may take 2-5 minutes on first run)
- Check internet connection
- If truly stuck (> 10 minutes), Ctrl+C and try again

### Claude Code Crashes

**Check Logs:**
```bash
# Look for error messages
npx @anthropic-ai/claude-code --verbose 2>&1 | tee claude-error.log
```

**Common Causes:**
- Missing API key
- Outdated Node.js version
- Network connectivity issues
- Corrupted cache

**Solutions:**
```bash
# Update Node.js
# Clear npm cache
npm cache clean --force

# Reinstall Claude Code
npm uninstall -g @anthropic-ai/claude-code
npm install -g @anthropic-ai/claude-code
```

---

## Python & UV Issues

### Python Not Found (WSL)

**Error:**
```
python: command not found
```

**Solution:**
```bash
# Install Python 3
sudo apt update
sudo apt install -y python3 python3-pip

# Create alias
echo "alias python=python3" >> ~/.bashrc
echo "alias pip=pip3" >> ~/.bashrc
source ~/.bashrc

# Verify
python --version
```

### UV Not Found

**Error:**
```
uv: command not found
```

**Solution:**
```bash
# Install UV
pip3 install --user uv

# Add to PATH
echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.bashrc
source ~/.bashrc

# Verify
uv --version
```

### UV Installation Fails

**Error during pip install:**

**Solution:**
```bash
# Upgrade pip first
pip3 install --upgrade pip

# Install UV with verbose output
pip3 install --user -v uv

# Check PATH
echo $PATH | grep .local/bin
```

### bugFix Exercise Issues

**Scripts Won't Run:**

```bash
# Ensure you're in the correct directory
cd ~/bugFix

# Check Python version
python3 --version  # Should be 3.9+

# Make sure files exist
ls -la buggy_script.py

# Run with explicit python3
python3 buggy_script.py
```

---

## Network Issues

### Cannot Download Packages

**Symptoms:**
- Timeout errors
- Connection refused
- SSL certificate errors

**Solutions:**

1. **Check Internet Connection:**
   ```bash
   ping google.com
   curl -I https://npmjs.org
   ```

2. **Check Firewall/Antivirus:**
   - Temporarily disable to test
   - Add exceptions for: node.exe, npm, git

3. **Use Different DNS:**
   ```powershell
   # Windows - Change DNS to Google's
   # Settings > Network > Adapter Settings > Properties > IPv4
   # Set to: 8.8.8.8 and 8.8.4.4
   ```

4. **Proxy Settings:**
   ```bash
   # If behind corporate proxy
   npm config set proxy http://proxy.company.com:8080
   npm config set https-proxy http://proxy.company.com:8080
   ```

### SSL Certificate Errors

**Error:**
```
unable to verify the first certificate
```

**Temporary Workaround (NOT for production):**
```bash
# Disable SSL verification (risky!)
npm config set strict-ssl false

# Better solution: Install certificates
# Contact your IT department
```

---

## Getting More Help

### Before Asking for Help

1. **Check logs:**
   - Windows: `%TEMP%\ai-cli-setup-*.log`
   - WSL: `/tmp/ai-cli-setup-*.log`

2. **Run diagnostics:**
   ```powershell
   .\scripts\verify-installation.ps1
   ```

3. **Collect system info:**
   ```powershell
   # Windows
   systeminfo | findstr /B /C:"OS Name" /C:"OS Version"
   node --version
   npm --version
   git --version

   # WSL
   lsb_release -a
   node --version
   npm --version
   python3 --version
   ```

### Where to Get Help

1. **Documentation:**
   - [Main README](../README.md)
   - [API Key Setup](API_KEY_SETUP.md)
   - [PLANNING.MD](../PLANNING.MD)

2. **Official Resources:**
   - Claude Code Docs: https://docs.claude.com/claude-code
   - Node.js Docs: https://nodejs.org/docs/
   - WSL Docs: https://learn.microsoft.com/windows/wsl/

3. **Community:**
   - GitHub Issues (for this project)
   - Stack Overflow (for general tech issues)
   - Discord/Forums (check official websites)

### Creating a Good Issue Report

Include:

1. **System Info:**
   ```
   OS: Windows 11 22H2
   PowerShell: 7.3.0
   Node.js: v20.10.0
   npm: 10.2.0
   ```

2. **Steps to Reproduce:**
   ```
   1. Ran install-windows.ps1
   2. Saw error message: "..."
   3. Tried solution X, got error Y
   ```

3. **Error Messages:**
   - Full error text (not screenshots if possible)
   - Relevant log file excerpts
   - Command that failed

4. **What You've Tried:**
   - List troubleshooting steps attempted
   - Results of each attempt

---

## Common Error Codes

| Code | Meaning | Solution |
|------|---------|----------|
| **0x80070490** | Component not found | Update Windows, install prerequisites |
| **EACCES** | Permission denied | Check file permissions, use sudo (WSL) |
| **ENOENT** | File not found | Check paths, verify file exists |
| **ETIMEDOUT** | Network timeout | Check internet, firewall settings |
| **401** | Authentication failed | Check API key validity |
| **429** | Rate limit exceeded | Wait, upgrade API tier |
| **EPERM** | Operation not permitted | Run as Administrator (Windows) |

---

## Advanced Troubleshooting

### Clean Reinstall (Windows)

```powershell
# Uninstall everything
winget uninstall OpenJS.NodeJS.LTS
winget uninstall Git.Git

# Remove directories
Remove-Item "$env:ProgramFiles\nodejs" -Recurse -Force
Remove-Item "$env:APPDATA\npm" -Recurse -Force

# Clear cache
Remove-Item "$env:LocalAppData\npm-cache" -Recurse -Force

# Reinstall
.\install-windows.ps1
```

### Clean Reinstall (WSL)

```bash
# Remove packages
sudo apt remove --purge nodejs npm
sudo apt autoremove

# Remove directories
rm -rf ~/.npm
rm -rf ~/.node-gyp
rm -rf ~/bugFix

# Clear apt cache
sudo apt clean

# Reinstall
bash install-wsl.sh
```

### Debug Mode

**Windows:**
```powershell
# Run with verbose output
$VerbosePreference = "Continue"
.\install-windows.ps1
```

**WSL:**
```bash
# Run with debug output
bash -x install-wsl.sh
```

---

## Preventive Maintenance

### Regular Updates

**Monthly:**
```powershell
# Windows
winget upgrade --all

# WSL
sudo apt update && sudo apt upgrade
npm update -g
```

### Key Rotation

- Rotate API keys every 3-6 months
- See [API_KEY_SETUP.md](API_KEY_SETUP.md#key-rotation)

### Backup Configuration

```bash
# Backup .credentials (store securely!)
cp -r .credentials .credentials.backup

# Backup shell config
cp ~/.bashrc ~/.bashrc.backup
```

---

## Still Stuck?

If none of these solutions work:

1. **Review all documentation** thoroughly
2. **Search existing issues** on GitHub
3. **Create a new issue** with detailed information
4. **Ask in community forums** with context
5. **Consider** alternative tools or approaches

**Remember:** Most issues have been encountered and solved before. Don't hesitate to ask for help!

---

**Last Updated:** 2025-11-03
**Version:** 1.0

**Feedback:** Found a solution not listed here? Please contribute by opening a PR!
