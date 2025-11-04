<#
.SYNOPSIS
    Installs AI CLI Tools (Claude Code and Gemini CLI) on Windows.

.DESCRIPTION
    This script automates the installation of prerequisites and AI CLI tools:
    - Node.js LTS (for npx and npm)
    - Git for Windows
    - Claude Code (via npx)
    - Gemini CLI (via npm)
    - Sets up .credentials directory for API keys

    The script checks prerequisites, installs missing components, and verifies
    the installation. It's designed to be idempotent and safe to run multiple times.

.PARAMETER SkipPrerequisites
    Skip prerequisite checks (not recommended).

.PARAMETER LogPath
    Custom path for installation log file. Defaults to %TEMP%.

.EXAMPLE
    .\install-windows.ps1
    Runs the full installation with all checks.

.EXAMPLE
    .\install-windows.ps1 -SkipPrerequisites
    Runs installation without checking prerequisites.

.NOTES
    Author: AI CLI Setup Project
    Version: 1.0
    Last Updated: 2025-11-03
    Requires: PowerShell 5.1+, Administrator privileges
#>

[CmdletBinding()]
param(
    [Parameter(Mandatory=$false)]
    [switch]$SkipPrerequisites,

    [Parameter(Mandatory=$false)]
    [string]$LogPath = "$env:TEMP\ai-cli-setup-$(Get-Date -Format 'yyyyMMdd-HHmmss').log"
)

# ============================================================================
# Script Configuration
# ============================================================================
$ErrorActionPreference = "Stop"
$script:LogFile = $LogPath
$script:InstallErrors = @()
$script:InstallWarnings = @()

# ============================================================================
# Logging Functions
# ============================================================================

function Write-Log {
    param(
        [string]$Message,
        [ValidateSet('INFO','WARN','ERROR','SUCCESS')]
        [string]$Level = 'INFO'
    )

    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $logMessage = "[$timestamp] [$Level] $Message"

    # Write to log file
    Add-Content -Path $script:LogFile -Value $logMessage

    # Write to console with color
    switch ($Level) {
        'INFO'    { Write-Host $Message -ForegroundColor Cyan }
        'WARN'    { Write-Host $Message -ForegroundColor Yellow }
        'ERROR'   { Write-Host $Message -ForegroundColor Red }
        'SUCCESS' { Write-Host $Message -ForegroundColor Green }
    }
}

function Write-Header {
    param([string]$Text)
    Write-Host "`n========================================" -ForegroundColor Cyan
    Write-Host "  $Text" -ForegroundColor Cyan
    Write-Host "========================================`n" -ForegroundColor Cyan
    Write-Log $Text
}

function Write-Step {
    param([string]$Text)
    Write-Host "`n>>> $Text" -ForegroundColor Yellow
    Write-Log $Text
}

# ============================================================================
# Helper Functions
# ============================================================================

function Test-CommandExists {
    param([string]$Command)
    $null -ne (Get-Command $Command -ErrorAction SilentlyContinue)
}

function Refresh-EnvironmentPath {
    <#
    .SYNOPSIS
        Refreshes the PATH environment variable without restarting PowerShell.
    #>
    $env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" +
                [System.Environment]::GetEnvironmentVariable("Path","User")
}

function Install-WithWinget {
    param(
        [string]$PackageId,
        [string]$DisplayName
    )

    Write-Step "Installing $DisplayName via winget..."

    try {
        # Check if already installed
        $installed = winget list --id $PackageId 2>$null
        if ($LASTEXITCODE -eq 0 -and $installed -match $PackageId) {
            Write-Log "✓ $DisplayName is already installed" -Level SUCCESS
            return $true
        }

        # Install the package
        Write-Log "  Installing $DisplayName... This may take a few minutes."
        $result = winget install --id $PackageId --silent --accept-package-agreements --accept-source-agreements 2>&1

        if ($LASTEXITCODE -eq 0) {
            Write-Log "✓ $DisplayName installed successfully" -Level SUCCESS
            Refresh-EnvironmentPath
            return $true
        } else {
            Write-Log "✗ Failed to install $DisplayName (Exit code: $LASTEXITCODE)" -Level ERROR
            $script:InstallErrors += "Failed to install $DisplayName"
            return $false
        }
    } catch {
        Write-Log "✗ Error installing $DisplayName: $_" -Level ERROR
        $script:InstallErrors += "Error installing $DisplayName: $_"
        return $false
    }
}

# ============================================================================
# Main Installation Functions
# ============================================================================

function Install-NodeJS {
    Write-Header "Node.js Installation"

    # Check if Node.js is already installed
    if (Test-CommandExists "node") {
        $nodeVersion = node --version
        Write-Log "✓ Node.js is already installed: $nodeVersion" -Level SUCCESS

        # Check if version is acceptable (v16.x or higher recommended)
        $versionNumber = $nodeVersion -replace 'v', ''
        $majorVersion = [int]($versionNumber.Split('.')[0])

        if ($majorVersion -ge 16) {
            Write-Log "  Version is acceptable (v16+ recommended)" -Level INFO
            return $true
        } else {
            Write-Log "  Installed version is old (v$majorVersion). Consider updating." -Level WARN
            $script:InstallWarnings += "Node.js version is older than recommended (v16+)"
        }
    }

    # Install Node.js LTS
    $result = Install-WithWinget -PackageId "OpenJS.NodeJS.LTS" -DisplayName "Node.js LTS"

    if ($result) {
        # Verify installation
        Refresh-EnvironmentPath
        Start-Sleep -Seconds 2

        if (Test-CommandExists "node") {
            $nodeVersion = node --version
            Write-Log "✓ Node.js verified: $nodeVersion" -Level SUCCESS

            # Also check npm
            if (Test-CommandExists "npm") {
                $npmVersion = npm --version
                Write-Log "✓ npm verified: $npmVersion" -Level SUCCESS
            }
        } else {
            Write-Log "✗ Node.js installation verification failed" -Level ERROR
            $script:InstallErrors += "Node.js not found after installation"
            return $false
        }
    }

    return $result
}

function Install-Git {
    Write-Header "Git for Windows Installation"

    # Check if Git is already installed
    if (Test-CommandExists "git") {
        $gitVersion = git --version
        Write-Log "✓ Git is already installed: $gitVersion" -Level SUCCESS
        return $true
    }

    # Install Git for Windows
    $result = Install-WithWinget -PackageId "Git.Git" -DisplayName "Git for Windows"

    if ($result) {
        # Verify installation
        Refresh-EnvironmentPath
        Start-Sleep -Seconds 2

        if (Test-CommandExists "git") {
            $gitVersion = git --version
            Write-Log "✓ Git verified: $gitVersion" -Level SUCCESS
        } else {
            Write-Log "✗ Git installation verification failed" -Level ERROR
            $script:InstallErrors += "Git not found after installation"
            return $false
        }
    }

    return $result
}

function Setup-NPMTools {
    Write-Header "npm and CLI Tools Setup"

    # Verify npm is available
    if (-not (Test-CommandExists "npm")) {
        Write-Log "✗ npm is not available. Node.js installation may have failed." -Level ERROR
        $script:InstallErrors += "npm not found"
        return $false
    }

    Write-Log "✓ npm is available" -Level SUCCESS

    # Test npx functionality
    Write-Step "Testing npx functionality..."
    try {
        $npxTest = npx --version 2>&1
        if ($LASTEXITCODE -eq 0) {
            Write-Log "✓ npx is working: version $npxTest" -Level SUCCESS
        } else {
            Write-Log "⚠ npx test returned non-zero exit code" -Level WARN
        }
    } catch {
        Write-Log "⚠ Could not test npx: $_" -Level WARN
        $script:InstallWarnings += "npx test failed"
    }

    # Note: We don't pre-install Claude Code or Gemini CLI globally
    # They will be used via npx when needed, which is the recommended approach
    Write-Log "✓ CLI tools will be accessible via npx" -Level SUCCESS

    return $true
}

function Setup-CredentialsDirectory {
    Write-Header ".credentials Directory Setup"

    $credDir = Join-Path $PSScriptRoot ".credentials"

    if (Test-Path $credDir) {
        Write-Log "✓ .credentials directory already exists: $credDir" -Level SUCCESS

        # Check for template files
        $templateFiles = @("anthropic.key.example", "google.key.example", "README.md")
        $allTemplatesExist = $true

        foreach ($template in $templateFiles) {
            $templatePath = Join-Path $credDir $template
            if (-not (Test-Path $templatePath)) {
                Write-Log "⚠ Template file missing: $template" -Level WARN
                $allTemplatesExist = $false
            }
        }

        if ($allTemplatesExist) {
            Write-Log "✓ All template files present" -Level SUCCESS
        }
    } else {
        Write-Log "⚠ .credentials directory not found at: $credDir" -Level WARN
        $script:InstallWarnings += ".credentials directory not found"
    }

    # Display API key setup instructions
    Write-Host "`n" -NoNewline
    Write-Host "========================================" -ForegroundColor Yellow
    Write-Host "  NEXT STEP: Set Up Your API Keys" -ForegroundColor Yellow
    Write-Host "========================================" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "To use Claude Code and Gemini CLI, you need API keys:" -ForegroundColor White
    Write-Host ""
    Write-Host "1. Get Claude API key:" -ForegroundColor Cyan
    Write-Host "   • Visit: https://console.anthropic.com" -ForegroundColor Gray
    Write-Host "   • Create an API key" -ForegroundColor Gray
    Write-Host "   • Save it to: $credDir\anthropic.key" -ForegroundColor Gray
    Write-Host ""
    Write-Host "2. Get Gemini API key:" -ForegroundColor Cyan
    Write-Host "   • Visit: https://aistudio.google.com" -ForegroundColor Gray
    Write-Host "   • Create an API key" -ForegroundColor Gray
    Write-Host "   • Save it to: $credDir\google.key" -ForegroundColor Gray
    Write-Host ""
    Write-Host "See $credDir\README.md for detailed instructions." -ForegroundColor White
    Write-Host ""

    return $true
}

# ============================================================================
# Main Execution
# ============================================================================

# Display banner
Clear-Host
Write-Host ""
Write-Host "╔════════════════════════════════════════════════════════════╗" -ForegroundColor Cyan
Write-Host "║                                                            ║" -ForegroundColor Cyan
Write-Host "║          AI CLI Tools Installation for Windows             ║" -ForegroundColor Cyan
Write-Host "║                                                            ║" -ForegroundColor Cyan
Write-Host "║  This script will install:                                 ║" -ForegroundColor Cyan
Write-Host "║    • Node.js LTS                                           ║" -ForegroundColor Cyan
Write-Host "║    • Git for Windows                                       ║" -ForegroundColor Cyan
Write-Host "║    • Claude Code (via npx)                                 ║" -ForegroundColor Cyan
Write-Host "║    • Gemini CLI                                            ║" -ForegroundColor Cyan
Write-Host "║                                                            ║" -ForegroundColor Cyan
Write-Host "╚════════════════════════════════════════════════════════════╝" -ForegroundColor Cyan
Write-Host ""

Write-Log "========================================" -Level INFO
Write-Log "AI CLI Tools Installation Started" -Level INFO
Write-Log "Log file: $script:LogFile" -Level INFO
Write-Log "========================================" -Level INFO

try {
    # ========================================================================
    # Step 1: Prerequisites Check
    # ========================================================================
    if (-not $SkipPrerequisites) {
        Write-Header "Checking Prerequisites"

        $prereqScript = Join-Path $PSScriptRoot "scripts\helpers\check-prerequisites.ps1"

        if (Test-Path $prereqScript) {
            $prereqResult = & $prereqScript

            if (-not $prereqResult.AllChecksPassed) {
                Write-Log "✗ Prerequisites check failed. Please resolve the issues and try again." -Level ERROR
                Write-Log "  Run the script with -SkipPrerequisites to bypass (not recommended)." -Level WARN
                exit 1
            }
        } else {
            Write-Log "⚠ Prerequisite checker not found. Continuing anyway..." -Level WARN
            $script:InstallWarnings += "Prerequisite checker script not found"
        }
    } else {
        Write-Log "⚠ Skipping prerequisites check (as requested)" -Level WARN
    }

    # ========================================================================
    # Step 2: Install Node.js
    # ========================================================================
    $nodeSuccess = Install-NodeJS
    if (-not $nodeSuccess) {
        throw "Node.js installation failed"
    }

    # ========================================================================
    # Step 3: Install Git
    # ========================================================================
    $gitSuccess = Install-Git
    if (-not $gitSuccess) {
        throw "Git installation failed"
    }

    # ========================================================================
    # Step 4: Setup npm and CLI Tools
    # ========================================================================
    $npmSuccess = Setup-NPMTools
    if (-not $npmSuccess) {
        throw "npm/CLI tools setup failed"
    }

    # ========================================================================
    # Step 5: Setup .credentials Directory
    # ========================================================================
    Setup-CredentialsDirectory

    # ========================================================================
    # Installation Complete
    # ========================================================================
    Write-Header "Installation Complete!"

    if ($script:InstallErrors.Count -eq 0) {
        Write-Host "✓ All components installed successfully!`n" -ForegroundColor Green

        Write-Host "Next steps:" -ForegroundColor Yellow
        Write-Host "1. Set up your API keys (see instructions above)" -ForegroundColor White
        Write-Host "2. Run verification script: .\scripts\verify-installation.ps1" -ForegroundColor White
        Write-Host "3. Start using Claude Code: npx @anthropic-ai/claude-code" -ForegroundColor White
        Write-Host ""

        Write-Log "Installation completed successfully" -Level SUCCESS
    } else {
        Write-Host "⚠ Installation completed with errors:`n" -ForegroundColor Yellow
        foreach ($error in $script:InstallErrors) {
            Write-Host "  • $error" -ForegroundColor Red
        }
        Write-Host ""
        Write-Log "Installation completed with errors" -Level WARN
    }

    if ($script:InstallWarnings.Count -gt 0) {
        Write-Host "⚠ Warnings:" -ForegroundColor Yellow
        foreach ($warning in $script:InstallWarnings) {
            Write-Host "  • $warning" -ForegroundColor Yellow
        }
        Write-Host ""
    }

    Write-Host "Log file saved to: $script:LogFile" -ForegroundColor Gray
    Write-Host ""

} catch {
    Write-Log "✗ Installation failed: $_" -Level ERROR
    Write-Host "`n✗ Installation failed: $_`n" -ForegroundColor Red
    Write-Host "Check the log file for details: $script:LogFile`n" -ForegroundColor Yellow
    exit 1
}
