# CLAUDE.MD - AI Assistant Training Guide

## Project Overview

**Project Name**: AI CLI Tools Installation Suite  
**Purpose**: Automated installation and setup system for Claude Code and Gemini CLI across Windows environments  
**Target Environments**: Windows CMD, PowerShell, WSL Ubuntu

## How to Work on This Project

### Core Principles

1. **Cross-Platform Compatibility First**: Every change must work in CMD, PowerShell, and WSL
2. **Security by Default**: Never commit API keys; always use templates and .gitignore
3. **User-Friendly Documentation**: Write for users with minimal technical background
4. **Idempotent Scripts**: All installation scripts should be safe to run multiple times
5. **Fail Gracefully**: Provide actionable error messages, never crash silently

### Project Context

This project serves Windows developers who want to use AI CLI tools but may be unfamiliar with:
- Node.js ecosystem
- WSL (Windows Subsystem for Linux)
- API key management
- Git workflows

**Our job**: Make the complex simple without sacrificing functionality.

## Architecture Understanding

### Key Components

1. **Installation Scripts**
   - `install-windows.ps1`: PowerShell script for Windows native environment
   - `install-wsl.sh`: Bash script for WSL Ubuntu environment
   - Both scripts are standalone and don't depend on each other

2. **API Key Management**
   - `.credentials/` directory stores sensitive keys
   - `.example` template files show format without real keys
   - `.gitignore` prevents accidental commits

3. **Verification System**
   - `verify-installation.ps1/sh`: Tests that installations succeeded
   - `test-all-environments.ps1`: Windows-only script that tests across all three terminals

4. **Practice Exercise**
   - `bugFix/` directory contains Python learning exercise
   - Uses UV for environment management
   - Demonstrates real AI CLI debugging workflow

## Working with Different File Types

### PowerShell Scripts (.ps1)

**When to edit**: Changes to Windows installation process

**Key considerations**:
- Check for admin privileges: `([Security.Principal.WindowsPrincipal]...)`
- Use `winget` or `chocolatey` for package management
- Handle both PowerShell 5.1 (Windows) and PowerShell 7+ (cross-platform)
- Test execution policy: Users may need `Set-ExecutionPolicy RemoteSigned`

**Common patterns**:
```powershell
# Check if command exists
if (Get-Command "node" -ErrorAction SilentlyContinue) {
    Write-Host "Node.js is already installed" -ForegroundColor Green
}

# Install via winget
winget install OpenJS.NodeJS.LTS

# Add to PATH
$env:Path += ";C:\Program Files\nodejs\"
```

### Bash Scripts (.sh)

**When to edit**: Changes to WSL/Ubuntu installation process

**Key considerations**:
- Use `apt` package manager for Ubuntu
- Update package lists before installing: `sudo apt update`
- Check for command existence: `command -v node`
- Modify `.bashrc` or `.zshrc` for PATH changes

**Common patterns**:
```bash
# Check if command exists
if command -v node &> /dev/null; then
    echo "Node.js is already installed"
fi

# Install Node.js via NodeSource
curl -fsSL https://deb.nodesource.com/setup_lts.x | sudo -E bash -
sudo apt-get install -y nodejs

# Add to PATH
echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.bashrc
```

### Markdown Documentation (.md)

**When to edit**: Any user-facing instruction changes

**Key considerations**:
- Use clear headers (H2 for major sections, H3 for subsections)
- Include code blocks with syntax highlighting
- Add "Expected Output" sections for commands
- Use emojis sparingly for visual markers (✅ ❌ ⚠️)
- Keep paragraphs short (3-4 sentences max)

**README.md structure**:
1. Quick Start (30-second overview)
2. Prerequisites
3. Installation
4. API Key Setup
5. Verification
6. Usage Examples
7. Troubleshooting
8. Contributing

## Common Tasks & How to Handle Them

### Adding a New CLI Tool

**Steps**:
1. Update PRD.md with new requirements
2. Add installation steps to both `install-windows.ps1` and `install-wsl.sh`
3. Update README.md with new tool documentation
4. Add verification steps to verification scripts
5. Update TASKS.md with completion status
6. Test in all three environments

**Example**:
If adding "Cursor CLI":
- Research installation method (npm, pip, binary, etc.)
- Add to prerequisites section if new dependency required
- Ensure cross-platform compatibility
- Document API key setup if needed

### Updating API Key Instructions

**Steps**:
1. Verify current API key creation process on provider's website
2. Take screenshots of key creation flow (for visual learners)
3. Update README.md "API Key Setup" section
4. Check `.credentials/*.example` templates are accurate
5. Test instructions with fresh account

**Critical**: Never include real API keys in examples or screenshots

### Fixing Installation Script Bugs

**Debugging checklist**:
1. Identify which environment(s) are affected
2. Check error messages in script output
3. Verify prerequisites are met
4. Test idempotency (run script twice)
5. Check PATH modifications persist after new terminal
6. Validate with verification scripts

**Testing protocol**:
- Test on clean Windows VM or fresh WSL installation
- Test with and without prerequisites installed
- Test with restricted and admin user accounts
- Document any edge cases found

### Modifying the bugFix Exercise

**Guidelines**:
- Bugs should be realistic (not contrived)
- Each bug should teach a different debugging skill
- Include at least one bug that requires reading documentation
- Ensure AI tools can actually help fix the bugs (test with both Claude and Gemini)
- Update SOLUTION.md with detailed explanations

**Bug difficulty scale**:
- **Easy**: Syntax error, typo, missing import
- **Medium**: Logic error, off-by-one, incorrect operator
- **Hard**: Race condition, subtle type coercion, algorithm flaw

## File-Specific Guidelines

### PRD.md (This file is read-only for AI)

**Purpose**: Source of truth for requirements

**When to reference**:
- Before starting any new feature
- When requirements seem unclear
- When making architectural decisions

**When NOT to edit**:
- Don't modify without explicit user request
- Requirements changes need stakeholder approval

### PLANNING.MD

**Purpose**: Technical architecture and design decisions

**When to update**:
- After making significant architectural decisions
- When adding new components or dependencies
- When discovering better patterns or approaches

**Content to include**:
- Technology choices with rationale
- Directory structure explanations
- Integration patterns
- Alternatives considered and rejected

### TASKS.MD

**Purpose**: Track implementation progress

**Update frequency**: After completing each task

**Format**:
```markdown
- [ ] Task description (Priority: P0/P1/P2)
- [x] Completed task description
  - Completed: 2025-11-03
  - Notes: Any relevant implementation details
```

**Priority levels**:
- **P0**: Blocking, must be done for MVP
- **P1**: Important for good user experience
- **P2**: Nice to have, future enhancement

### README.md

**Purpose**: User-facing documentation

**Writing style**:
- Conversational but professional
- Use "you" to address the reader
- Active voice ("Run this command" not "This command should be run")
- Short sentences and paragraphs
- Lots of examples with expected output

**Update triggers**:
- Any change to installation process
- New prerequisites
- API provider website changes
- User-reported confusion in GitHub issues

### .gitignore

**Critical patterns** (always include):
```
# API Keys and Credentials
.credentials/*
!.credentials/.gitkeep
!.credentials/*.example
*.key
*_key.txt
.env
.env.local

# Node.js
node_modules/
npm-debug.log
package-lock.json

# Python
__pycache__/
*.py[cod]
.venv/
venv/

# OS
.DS_Store
Thumbs.db
desktop.ini

# IDE
.vscode/
.idea/
*.swp
*.swo
```

**Never remove**: API key patterns (most critical for security)

## Testing Checklist

Before considering any change complete:

### Installation Scripts
- [ ] Runs successfully on Windows 10
- [ ] Runs successfully on Windows 11
- [ ] Runs successfully in WSL Ubuntu 20.04
- [ ] Runs successfully in WSL Ubuntu 22.04
- [ ] Idempotent (safe to run twice)
- [ ] Fails gracefully with helpful errors
- [ ] Respects existing installations

### Documentation
- [ ] No broken links
- [ ] Code examples are copy-paste ready
- [ ] Screenshots are current and clear
- [ ] Tested by non-technical user
- [ ] Grammar and spelling checked

### CLI Tools Functionality
- [ ] Claude Code works in CMD
- [ ] Claude Code works in PowerShell
- [ ] Claude Code works in WSL Ubuntu
- [ ] Gemini CLI works in CMD
- [ ] Gemini CLI works in PowerShell
- [ ] Gemini CLI works in WSL Ubuntu

### Security
- [ ] No API keys in git history
- [ ] .gitignore patterns are comprehensive
- [ ] Template files don't contain sensitive data
- [ ] Documentation warns about key security

## Common Pitfalls to Avoid

### ❌ Don't Do This

1. **Hardcode paths**: `/c/Users/Username/...` won't work for other users
2. **Assume tools exist**: Always check before using `git`, `curl`, etc.
3. **Use relative paths in scripts**: May break depending on where script is run
4. **Commit API keys**: Even fake ones can be confusing
5. **Skip verification steps**: User might think it worked when it didn't
6. **Write Windows-only commands in WSL script**: `dir` vs `ls`
7. **Forget to update all docs**: Change in script → change in README

### ✅ Do This Instead

1. **Use environment variables**: `$env:USERPROFILE`, `$HOME`
2. **Check and install**: `if ! command -v git; then install git; fi`
3. **Use absolute paths**: `$PSScriptRoot` in PowerShell, `$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )` in Bash
4. **Use .example templates**: Clear and safe
5. **Run verification scripts**: Build confidence
6. **Use cross-platform tools**: `npm` works everywhere
7. **Update TASKS.md with documentation tasks**: Track comprehensively

## Code Style Guidelines

### PowerShell
- Use approved verbs (Get-, Set-, New-, Remove-, etc.)
- PascalCase for functions
- Include comment-based help
- Use `Write-Host` with colors for user feedback
- Prefer `[CmdletBinding()]` for advanced functions

### Bash
- Use snake_case for function names
- Include usage documentation in comments
- Use `set -euo pipefail` for safer scripts
- Quote variables: `"$variable"` not `$variable`
- Use `readonly` for constants

### Python (bugFix exercise)
- Follow PEP 8
- Use type hints
- Include docstrings
- Keep functions small and focused
- Intentional bugs should be realistic

## Getting Help

### When stuck on a task:

1. **Check PRD.md**: Is this actually required?
2. **Review PLANNING.MD**: Has this been architecturally solved?
3. **Look at existing code**: Find similar patterns
4. **Test in isolation**: Simplify to minimal reproduction
5. **Ask user**: They may have preferences or additional context

### When requirements are unclear:

1. **State assumptions**: "I'm assuming X based on Y"
2. **Propose options**: "We could do A, B, or C. I recommend B because..."
3. **Ask specific questions**: Not "What should I do?" but "Should this support PowerShell 5.1 or only 7+?"

## Version Control Best Practices

### Commit messages:
```
<type>: <description>

[optional body]

[optional footer]
```

**Types**:
- `feat`: New feature
- `fix`: Bug fix
- `docs`: Documentation only
- `refactor`: Code change that neither fixes bug nor adds feature
- `test`: Adding or updating tests
- `chore`: Maintenance tasks

**Examples**:
- `feat: add Gemini CLI installation to WSL script`
- `fix: correct Node.js version check in PowerShell`
- `docs: update API key setup instructions with screenshots`

### When to commit:
- After completing a discrete task
- When all tests pass
- Before switching to different task
- Before major refactoring

## Emergency Protocols

### If API keys are accidentally committed:

1. **Immediately revoke keys** on provider websites
2. **Remove from git history**: Use `git filter-repo` or BFG Repo-Cleaner
3. **Generate new keys**
4. **Update .gitignore** to prevent recurrence
5. **Document incident** in TASKS.md for learning

### If installation script breaks production:

1. **Revert to last working version**
2. **Create hotfix branch**
3. **Test extensively** before redeploying
4. **Document what broke** and why
5. **Add regression test** to prevent recurrence

## Resources

### Official Documentation
- **Claude Code**: https://docs.claude.com/en/docs/claude-code
- **Gemini CLI**: https://ai.google.dev/
- **Node.js**: https://nodejs.org/docs/
- **WSL**: https://learn.microsoft.com/en-us/windows/wsl/

### Testing Environments
- **Windows VM**: Use Windows Sandbox or Hyper-V
- **WSL**: `wsl --install` for fresh testing
- **PowerShell**: Test both 5.1 and 7+

### Tools
- **ShellCheck**: Bash script linting
- **PSScriptAnalyzer**: PowerShell script linting
- **Markdownlint**: Documentation formatting

## Success Criteria for AI Assistance

You've done a good job when:
1. ✅ User can follow instructions without asking questions
2. ✅ All three environments work identically (as much as possible)
3. ✅ Security best practices are followed
4. ✅ Documentation is clear and tested
5. ✅ Code is maintainable and well-commented
6. ✅ Edge cases are handled gracefully
7. ✅ Testing checklist is fully completed

---

**Remember**: This project's success is measured by user success. If users struggle, we've failed. Always prioritize clarity, safety, and reliability over cleverness or brevity.

**Last Updated**: 2025-11-03  
**Document Version**: 1.0
