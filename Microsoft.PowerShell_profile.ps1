# --- UNIVERSAL MASTER PROFILE (v3.1 - The Hanselman Final) ---

# 1. THE 5.1 PATCH: Force UTF-8 Encoding (Fixes ?? and boxes)
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
[Console]::InputEncoding  = [System.Text.Encoding]::UTF8
$OutputEncoding = [System.Text.Encoding]::UTF8

# 2. Safety Logic: Windows Terminal/VS Code vs. Legacy ISE
if ($null -eq $psISE) {
    
    # Initialize Oh My Posh (Using internal theme + Silencing 5.1 Keybinding errors)
    if (Get-Command oh-my-posh -ErrorAction SilentlyContinue) {
        oh-my-posh init pwsh --config "jandedobbeleer" 2>$null | Invoke-Expression
    }

    # Import Modules
    Import-Module posh-git -ErrorAction SilentlyContinue
    Import-Module Terminal-Icons -ErrorAction SilentlyContinue

    # 3. Modern PSReadLine Check (Prediction & Ghost Text)
    # Only runs if the version we installed (2.1.0+) is detected
    $psr = Get-Module PSReadLine -ListAvailable | Sort-Object Version -Descending | Select-Object -First 1
    if ($psr.Version -ge [version]"2.1.0") {
        Set-PSReadLineOption -PredictionSource History -ErrorAction SilentlyContinue
        Set-PSReadLineOption -PredictionViewStyle ListView -ErrorAction SilentlyContinue
    }
} else {
    # Clean fallback for PowerShell ISE (Graphics disabled to prevent crashes)
    function prompt { "PS ISE > " }
}

# 4. Shared Aliases & Functions
Set-Alias -Name 'll' -Value 'ls' -Option AllScope
function Search-History { Get-History | Out-GridView }