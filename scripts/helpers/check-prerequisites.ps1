<#
.SYNOPSIS
    Checks prerequisites for AI CLI Tools installation on Windows.

.DESCRIPTION
    This script verifies that the system meets all prerequisites for installing
    Claude Code and Gemini CLI tools. It checks:
    - PowerShell version
    - Administrator privileges
    - winget availability
    - Internet connection
    - Windows version

.OUTPUTS
    Returns a custom object with check results and overall status.

.EXAMPLE
    $result = .\check-prerequisites.ps1
    if ($result.AllChecksPassed) {
        Write-Host "All prerequisites met!"
    }

.NOTES
    Author: AI CLI Setup Project
    Version: 1.0
    Last Updated: 2025-11-03
#>

[CmdletBinding()]
param()

# Initialize result object
$result = [PSCustomObject]@{
    PowerShellVersion = $null
    PowerShellVersionOK = $false
    IsAdministrator = $false
    WingetAvailable = $false
    InternetConnected = $false
    WindowsVersion = $null
    WindowsVersionOK = $false
    AllChecksPassed = $false
    Errors = @()
    Warnings = @()
}

Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host "  Prerequisites Check" -ForegroundColor Cyan
Write-Host "========================================`n" -ForegroundColor Cyan

# ============================================================================
# Check 1: PowerShell Version
# ============================================================================
Write-Host "[1/5] Checking PowerShell version..." -NoNewline

try {
    $result.PowerShellVersion = $PSVersionTable.PSVersion

    # Require PowerShell 5.1 or higher
    if ($PSVersionTable.PSVersion.Major -ge 5) {
        $result.PowerShellVersionOK = $true
        Write-Host " ✓" -ForegroundColor Green
        Write-Host "      Version: $($PSVersionTable.PSVersion)" -ForegroundColor Gray
    } else {
        Write-Host " ✗" -ForegroundColor Red
        $result.Errors += "PowerShell version $($PSVersionTable.PSVersion) is too old. Requires 5.1 or higher."
        Write-Host "      Version: $($PSVersionTable.PSVersion) (Too old)" -ForegroundColor Red
    }
} catch {
    Write-Host " ✗" -ForegroundColor Red
    $result.Errors += "Failed to check PowerShell version: $_"
}

# ============================================================================
# Check 2: Administrator Privileges
# ============================================================================
Write-Host "[2/5] Checking administrator privileges..." -NoNewline

try {
    $currentPrincipal = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())
    $result.IsAdministrator = $currentPrincipal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)

    if ($result.IsAdministrator) {
        Write-Host " ✓" -ForegroundColor Green
        Write-Host "      Running as Administrator" -ForegroundColor Gray
    } else {
        Write-Host " ✗" -ForegroundColor Red
        $result.Errors += "Not running as Administrator. Installation requires elevated privileges."
        Write-Host "      Not running as Administrator" -ForegroundColor Red
    }
} catch {
    Write-Host " ✗" -ForegroundColor Red
    $result.Errors += "Failed to check administrator privileges: $_"
}

# ============================================================================
# Check 3: Winget Availability
# ============================================================================
Write-Host "[3/5] Checking winget availability..." -NoNewline

try {
    $wingetCmd = Get-Command "winget" -ErrorAction SilentlyContinue

    if ($wingetCmd) {
        $result.WingetAvailable = $true
        Write-Host " ✓" -ForegroundColor Green

        # Get winget version
        try {
            $wingetVersion = (winget --version) -replace 'v', ''
            Write-Host "      Version: $wingetVersion" -ForegroundColor Gray
        } catch {
            Write-Host "      Installed (version unknown)" -ForegroundColor Gray
        }
    } else {
        Write-Host " ✗" -ForegroundColor Red
        $result.Errors += "winget is not available. Please install App Installer from Microsoft Store."
        Write-Host "      winget not found" -ForegroundColor Red
    }
} catch {
    Write-Host " ✗" -ForegroundColor Red
    $result.Errors += "Failed to check winget availability: $_"
}

# ============================================================================
# Check 4: Internet Connection
# ============================================================================
Write-Host "[4/5] Checking internet connection..." -NoNewline

try {
    # Try to reach a reliable endpoint
    $testConnection = Test-Connection -ComputerName "8.8.8.8" -Count 1 -Quiet -ErrorAction SilentlyContinue

    if ($testConnection) {
        $result.InternetConnected = $true
        Write-Host " ✓" -ForegroundColor Green
        Write-Host "      Connected" -ForegroundColor Gray
    } else {
        # Try another method - web request to Microsoft
        try {
            $webTest = Invoke-WebRequest -Uri "https://www.microsoft.com" -UseBasicParsing -TimeoutSec 5 -ErrorAction Stop
            $result.InternetConnected = $true
            Write-Host " ✓" -ForegroundColor Green
            Write-Host "      Connected" -ForegroundColor Gray
        } catch {
            Write-Host " ✗" -ForegroundColor Red
            $result.Errors += "No internet connection detected. Installation requires internet access."
            Write-Host "      Not connected" -ForegroundColor Red
        }
    }
} catch {
    Write-Host " ✗" -ForegroundColor Red
    $result.Errors += "Failed to check internet connection: $_"
}

# ============================================================================
# Check 5: Windows Version
# ============================================================================
Write-Host "[5/5] Checking Windows version..." -NoNewline

try {
    $osInfo = Get-CimInstance -ClassName Win32_OperatingSystem
    $result.WindowsVersion = $osInfo.Version

    # Extract major and minor version
    $versionParts = $osInfo.Version.Split('.')
    $majorVersion = [int]$versionParts[0]
    $buildNumber = [int]$versionParts[2]

    # Require Windows 10 build 1809 or higher (for winget support)
    # Windows 10 is version 10.0.xxxxx
    if ($majorVersion -ge 10 -and $buildNumber -ge 17763) {
        $result.WindowsVersionOK = $true
        Write-Host " ✓" -ForegroundColor Green
        Write-Host "      $($osInfo.Caption) (Build $buildNumber)" -ForegroundColor Gray
    } else {
        Write-Host " ✗" -ForegroundColor Red
        $result.Errors += "Windows version is too old. Requires Windows 10 build 1809 or higher."
        Write-Host "      $($osInfo.Caption) (Build $buildNumber - Too old)" -ForegroundColor Red
    }
} catch {
    Write-Host " ?" -ForegroundColor Yellow
    $result.Warnings += "Failed to check Windows version: $_"
    # Don't fail on this check, but warn
}

# ============================================================================
# Summary
# ============================================================================
Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host "  Summary" -ForegroundColor Cyan
Write-Host "========================================`n" -ForegroundColor Cyan

# Determine if all critical checks passed
$criticalChecksPassed = $result.PowerShellVersionOK -and
                        $result.IsAdministrator -and
                        $result.WingetAvailable -and
                        $result.InternetConnected

$result.AllChecksPassed = $criticalChecksPassed

if ($result.AllChecksPassed) {
    Write-Host "✓ All prerequisites met!" -ForegroundColor Green
    Write-Host "  You can proceed with installation.`n" -ForegroundColor Green
} else {
    Write-Host "✗ Some prerequisites are not met:" -ForegroundColor Red
    foreach ($error in $result.Errors) {
        Write-Host "  • $error" -ForegroundColor Red
    }
    Write-Host "`n  Please resolve these issues before continuing.`n" -ForegroundColor Yellow
}

# Display warnings if any
if ($result.Warnings.Count -gt 0) {
    Write-Host "⚠ Warnings:" -ForegroundColor Yellow
    foreach ($warning in $result.Warnings) {
        Write-Host "  • $warning" -ForegroundColor Yellow
    }
    Write-Host ""
}

# Return result object for programmatic use
return $result
