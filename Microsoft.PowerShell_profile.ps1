# --- UNIVERSAL MASTER PROFILE (v5.0 - FINAL ROLL-UP) ---

# 1. THE ISE ESCAPE HATCH (Must be first to prevent handle errors)
if ($Host.Name -like "*ISE*") {
    function prompt { "PS ISE > " }
    return 
}

# 2. MODERN TERMINAL SETTINGS
try {
    # Force UTF-8 for clean icons in PS 5.1 and 7
    [Console]::OutputEncoding = [System.Text.Encoding]::UTF8
    [Console]::InputEncoding  = [System.Text.Encoding]::UTF8
    $OutputEncoding = [System.Text.Encoding]::UTF8
} catch {}

# 3. OH MY POSH & MODULES
if (Get-Command oh-my-posh -ErrorAction SilentlyContinue) {
    # Initialize jandedobbeleer theme (2>$null silences 5.1 keybinding warnings)
    oh-my-posh init pwsh --config "jandedobbeleer" 2>$null | Invoke-Expression
}

# Silent Module Imports
Import-Module posh-git -ErrorAction SilentlyContinue
Import-Module Terminal-Icons -ErrorAction SilentlyContinue

# 4. MODERN PSREADLINE (Ghost Text Predictions)
# We check the version to ensure 5.1 doesn't crash if 2.1.0+ isn't loaded
$psr = Get-Module PSReadLine -ListAvailable | Sort-Object Version -Descending | Select-Object -First 1
if ($psr.Version -ge [version]"2.1.0") {
    Set-PSReadLineOption -PredictionSource History -ErrorAction SilentlyContinue
    Set-PSReadLineOption -PredictionViewStyle ListView -ErrorAction SilentlyContinue
}

# 5. SHARED ALIASES
Set-Alias -Name 'll' -Value 'ls' -Option AllScope

# 6. KOREAN EASTER EGG & GREETING
function Start-Greeting { 
    Write-Host "`n안녕하세요, Charles! 🇰🇷" -ForegroundColor Cyan
    Write-Host "Terminal Ready for IT Service." -ForegroundColor Gray
}
Set-Alias -Name 'hi' -Value Start-Greeting

# 7. THE ULTIMATE GIT SYNC HELPER
function Sync-Profile {
    param([string]$Message = "Auto-sync from terminal")
    
    $ActualDocs = [System.Environment]::GetFolderPath('MyDocuments')
    $SharedPath = Join-Path $ActualDocs "PowerShell\Shared"
    $CurrentPath = Get-Location
    
    try {
        Set-Location $SharedPath
        Write-Host "📦 Syncing Master Profile to GitHub..." -ForegroundColor Cyan
        git add .
        git commit -m "$Message"
        git push origin master  # Change to 'main' if your branch is named main
        Write-Host "✅ Sync Complete!" -ForegroundColor Green
    }
    catch {
        Write-Host "❌ Sync Failed. Check internet/git status." -ForegroundColor Red
    }
    finally {
        Set-Location $CurrentPath
    }
}
Set-Alias -Name 'sync' -Value Sync-Profile

# --- AUTO-START ---
# Uncomment the line below if you want the greeting to show every time
 Start-Greeting