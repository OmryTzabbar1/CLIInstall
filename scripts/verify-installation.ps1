<#
.SYNOPSIS
    Verifies AI CLI Tools installation on Windows.

.DESCRIPTION
    This script checks that all components were installed correctly:
    - Node.js and npm
    - Git
    - Claude Code accessibility via npx
    - API keys configuration
    - Environment PATH configuration

.OUTPUTS
    Displays verification results and returns exit code (0 = success, 1 = failure).

.EXAMPLE
    .\verify-installation.ps1
    Runs full verification of the installation.

.NOTES
    Author: AI CLI Setup Project
    Version: 1.0
    Last Updated: 2025-11-03
#>

[CmdletBinding()]
param()

# ============================================================================
# Script Configuration
# ============================================================================
$script:VerificationResults = @()
$script:PassedChecks = 0
$script:FailedChecks = 0
$script:WarningChecks = 0

# ============================================================================
# Helper Functions
# ============================================================================

function Test-CommandExists {
    param([string]$Command)
    $null -ne (Get-Command $Command -ErrorAction SilentlyContinue)
}

function Add-VerificationResult {
    param(
        [string]$Component,
        [ValidateSet('PASS','FAIL','WARN')]
        [string]$Status,
        [string]$Message,
        [string]$Details = ""
    )

    $result = [PSCustomObject]@{
        Component = $Component
        Status = $Status
        Message = $Message
        Details = $Details
    }

    $script:VerificationResults += $result

    # Update counters
    switch ($Status) {
        'PASS' { $script:PassedChecks++ }
        'FAIL' { $script:FailedChecks++ }
        'WARN' { $script:WarningChecks++ }
    }

    # Display result
    $symbol = switch ($Status) {
        'PASS' { '✓'; $color = 'Green' }
        'FAIL' { '✗'; $color = 'Red' }
        'WARN' { '⚠'; $color = 'Yellow' }
    }

    Write-Host "  $symbol $Component" -ForegroundColor $color -NoNewline
    Write-Host " - $Message" -ForegroundColor Gray

    if ($Details) {
        Write-Host "      $Details" -ForegroundColor DarkGray
    }
}

# ============================================================================
# Verification Functions
# ============================================================================

function Test-NodeJS {
    Write-Host "`n[Node.js Verification]" -ForegroundColor Cyan

    if (Test-CommandExists "node") {
        try {
            $version = node --version 2>&1
            if ($LASTEXITCODE -eq 0) {
                Add-VerificationResult -Component "Node.js" -Status "PASS" `
                    -Message "Installed and working" -Details "Version: $version"
                return $true
            } else {
                Add-VerificationResult -Component "Node.js" -Status "FAIL" `
                    -Message "Command exists but not responding correctly"
                return $false
            }
        } catch {
            Add-VerificationResult -Component "Node.js" -Status "FAIL" `
                -Message "Error executing command" -Details $_.Exception.Message
            return $false
        }
    } else {
        Add-VerificationResult -Component "Node.js" -Status "FAIL" `
            -Message "Not found in PATH"
        return $false
    }
}

function Test-NPM {
    Write-Host "`n[npm Verification]" -ForegroundColor Cyan

    if (Test-CommandExists "npm") {
        try {
            $version = npm --version 2>&1
            if ($LASTEXITCODE -eq 0) {
                Add-VerificationResult -Component "npm" -Status "PASS" `
                    -Message "Installed and working" -Details "Version: $version"

                # Also check npx
                if (Test-CommandExists "npx") {
                    $npxVersion = npx --version 2>&1
                    Add-VerificationResult -Component "npx" -Status "PASS" `
                        -Message "Available" -Details "Version: $npxVersion"
                } else {
                    Add-VerificationResult -Component "npx" -Status "WARN" `
                        -Message "Not found (usually comes with npm)"
                }

                return $true
            } else {
                Add-VerificationResult -Component "npm" -Status "FAIL" `
                    -Message "Command exists but not responding correctly"
                return $false
            }
        } catch {
            Add-VerificationResult -Component "npm" -Status "FAIL" `
                -Message "Error executing command" -Details $_.Exception.Message
            return $false
        }
    } else {
        Add-VerificationResult -Component "npm" -Status "FAIL" `
            -Message "Not found in PATH"
        return $false
    }
}

function Test-Git {
    Write-Host "`n[Git Verification]" -ForegroundColor Cyan

    if (Test-CommandExists "git") {
        try {
            $version = git --version 2>&1
            if ($LASTEXITCODE -eq 0) {
                Add-VerificationResult -Component "Git" -Status "PASS" `
                    -Message "Installed and working" -Details $version
                return $true
            } else {
                Add-VerificationResult -Component "Git" -Status "FAIL" `
                    -Message "Command exists but not responding correctly"
                return $false
            }
        } catch {
            Add-VerificationResult -Component "Git" -Status "FAIL" `
                -Message "Error executing command" -Details $_.Exception.Message
            return $false
        }
    } else {
        Add-VerificationResult -Component "Git" -Status "FAIL" `
            -Message "Not found in PATH"
        return $false
    }
}

function Test-ClaudeCode {
    Write-Host "`n[Claude Code Verification]" -ForegroundColor Cyan

    if (Test-CommandExists "npx") {
        Write-Host "  Testing Claude Code accessibility..." -ForegroundColor Gray

        try {
            # Test if we can invoke Claude Code help (with timeout)
            $testJob = Start-Job -ScriptBlock {
                npx @anthropic-ai/claude-code --help 2>&1
            }

            # Wait for 15 seconds max
            $completed = Wait-Job -Job $testJob -Timeout 15

            if ($completed) {
                $output = Receive-Job -Job $testJob
                Remove-Job -Job $testJob -Force

                if ($output -match "claude-code|Claude|Anthropic" -or $LASTEXITCODE -eq 0) {
                    Add-VerificationResult -Component "Claude Code" -Status "PASS" `
                        -Message "Accessible via npx" -Details "Can be invoked with: npx @anthropic-ai/claude-code"
                    return $true
                } else {
                    Add-VerificationResult -Component "Claude Code" -Status "WARN" `
                        -Message "npx command completed but output unexpected" `
                        -Details "Try running manually: npx @anthropic-ai/claude-code --help"
                    return $false
                }
            } else {
                # Timeout occurred
                Stop-Job -Job $testJob
                Remove-Job -Job $testJob -Force

                Add-VerificationResult -Component "Claude Code" -Status "WARN" `
                    -Message "Test timed out (may need first-time setup)" `
                    -Details "Try running: npx @anthropic-ai/claude-code --help"
                return $false
            }
        } catch {
            Add-VerificationResult -Component "Claude Code" -Status "WARN" `
                -Message "Could not test automatically" -Details $_.Exception.Message
            return $false
        }
    } else {
        Add-VerificationResult -Component "Claude Code" -Status "FAIL" `
            -Message "npx not available (required to run Claude Code)"
        return $false
    }
}

function Test-APIKeys {
    Write-Host "`n[API Keys Verification]" -ForegroundColor Cyan

    $scriptRoot = Split-Path -Parent (Split-Path -Parent $PSScriptRoot)
    $credDir = Join-Path $scriptRoot ".credentials"

    if (Test-Path $credDir) {
        Add-VerificationResult -Component ".credentials directory" -Status "PASS" `
            -Message "Directory exists" -Details $credDir

        # Check for actual API key files
        $anthropicKey = Join-Path $credDir "anthropic.key"
        $googleKey = Join-Path $credDir "google.key"

        if (Test-Path $anthropicKey) {
            $keyContent = Get-Content $anthropicKey -Raw -ErrorAction SilentlyContinue
            if ($keyContent -and $keyContent.Trim().Length -gt 0) {
                Add-VerificationResult -Component "Anthropic API Key" -Status "PASS" `
                    -Message "Key file exists and not empty"
            } else {
                Add-VerificationResult -Component "Anthropic API Key" -Status "WARN" `
                    -Message "Key file exists but appears empty"
            }
        } else {
            Add-VerificationResult -Component "Anthropic API Key" -Status "WARN" `
                -Message "Key file not found" -Details "Create: $anthropicKey"
        }

        if (Test-Path $googleKey) {
            $keyContent = Get-Content $googleKey -Raw -ErrorAction SilentlyContinue
            if ($keyContent -and $keyContent.Trim().Length -gt 0) {
                Add-VerificationResult -Component "Google API Key" -Status "PASS" `
                    -Message "Key file exists and not empty"
            } else {
                Add-VerificationResult -Component "Google API Key" -Status "WARN" `
                    -Message "Key file exists but appears empty"
            }
        } else {
            Add-VerificationResult -Component "Google API Key" -Status "WARN" `
                -Message "Key file not found" -Details "Create: $googleKey"
        }
    } else {
        Add-VerificationResult -Component ".credentials directory" -Status "FAIL" `
            -Message "Directory not found" -Details "Expected at: $credDir"
    }
}

function Test-EnvironmentPath {
    Write-Host "`n[PATH Configuration]" -ForegroundColor Cyan

    $pathDirs = $env:Path -split ';'

    # Check for common Node.js paths
    $nodePaths = $pathDirs | Where-Object { $_ -match 'nodejs|npm' }
    if ($nodePaths) {
        Add-VerificationResult -Component "Node.js in PATH" -Status "PASS" `
            -Message "Found in environment PATH"
    } else {
        Add-VerificationResult -Component "Node.js in PATH" -Status "WARN" `
            -Message "No Node.js paths detected in PATH"
    }

    # Check for Git paths
    $gitPaths = $pathDirs | Where-Object { $_ -match 'Git' }
    if ($gitPaths) {
        Add-VerificationResult -Component "Git in PATH" -Status "PASS" `
            -Message "Found in environment PATH"
    } else {
        Add-VerificationResult -Component "Git in PATH" -Status "WARN" `
            -Message "No Git paths detected in PATH"
    }
}

# ============================================================================
# Main Execution
# ============================================================================

Clear-Host
Write-Host ""
Write-Host "╔════════════════════════════════════════════════════════════╗" -ForegroundColor Cyan
Write-Host "║                                                            ║" -ForegroundColor Cyan
Write-Host "║        AI CLI Tools Installation Verification              ║" -ForegroundColor Cyan
Write-Host "║                                                            ║" -ForegroundColor Cyan
Write-Host "╚════════════════════════════════════════════════════════════╝" -ForegroundColor Cyan
Write-Host ""

# Run all verification tests
Test-NodeJS
Test-NPM
Test-Git
Test-ClaudeCode
Test-APIKeys
Test-EnvironmentPath

# ============================================================================
# Summary
# ============================================================================
Write-Host "`n" -NoNewline
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  Verification Summary" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

Write-Host "Passed:  " -NoNewline -ForegroundColor Gray
Write-Host "$script:PassedChecks" -ForegroundColor Green

Write-Host "Failed:  " -NoNewline -ForegroundColor Gray
Write-Host "$script:FailedChecks" -ForegroundColor Red

Write-Host "Warnings: " -NoNewline -ForegroundColor Gray
Write-Host "$script:WarningChecks" -ForegroundColor Yellow

Write-Host ""

# Determine overall status
if ($script:FailedChecks -eq 0) {
    if ($script:WarningChecks -eq 0) {
        Write-Host "✓ All checks passed! Installation is complete and verified." -ForegroundColor Green
        Write-Host ""
        Write-Host "You can now use Claude Code with:" -ForegroundColor White
        Write-Host "  npx @anthropic-ai/claude-code" -ForegroundColor Cyan
        Write-Host ""
        $exitCode = 0
    } else {
        Write-Host "⚠ Installation verified with warnings." -ForegroundColor Yellow
        Write-Host "  Review the warnings above and address if needed." -ForegroundColor White
        Write-Host ""
        $exitCode = 0
    }
} else {
    Write-Host "✗ Installation verification failed." -ForegroundColor Red
    Write-Host "  Please review the failed checks above and:" -ForegroundColor White
    Write-Host "  1. Re-run the installation script" -ForegroundColor White
    Write-Host "  2. Check the installation log for errors" -ForegroundColor White
    Write-Host "  3. See docs/TROUBLESHOOTING.md for help" -ForegroundColor White
    Write-Host ""
    $exitCode = 1
}

# Export results to file for reference
$resultsFile = Join-Path $env:TEMP "ai-cli-verification-$(Get-Date -Format 'yyyyMMdd-HHmmss').txt"
$script:VerificationResults | Format-Table -AutoSize | Out-File $resultsFile
Write-Host "Verification results saved to: $resultsFile" -ForegroundColor Gray
Write-Host ""

exit $exitCode
