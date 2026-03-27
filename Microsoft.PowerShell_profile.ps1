# --- UNIVERSAL MASTER PROFILE (v4.1 - The Final Fix) ---

# 1. THE ISE ESCAPE HATCH (Must be first!)
# If we are in the ISE, stop immediately before touching console handles.
if ($Host.Name -like "*ISE*") {
    function prompt { "PS ISE > " }
    return  # <--- Stops the script here for ISE
}

# 2. MODERN TERMINAL SETTINGS (Safe for PS 5.1 & 7)
# Force UTF-8 Encoding (Only runs in a real console/terminal)
try {
    [Console]::OutputEncoding = [System.Text.Encoding]::UTF8
    [Console]::InputEncoding  = [System.Text.Encoding]::UTF8
    $OutputEncoding = [System.Text.Encoding]::UTF8
} catch {
    # Silence any "Invalid Handle" errors if they still occur
}

# 3. Oh My Posh & Modules
if (Get-Command oh-my-posh -ErrorAction SilentlyContinue) {
    # Using 2>$null to hide keybinding errors in older PS 5.1 versions
    oh-my-posh init pwsh --config "jandedobbeleer" 2>$null | Invoke-Expression
}

# Import Modules Silently
Import-Module posh-git -ErrorAction SilentlyContinue
Import-Module Terminal-Icons -ErrorAction SilentlyContinue

# 4. Modern PSReadLine (Ghost Text Predictions)
$psr = Get-Module PSReadLine -ListAvailable | Sort-Object Version -Descending | Select-Object -First 1
if ($psr.Version -ge [version]"2.1.0") {
    Set-PSReadLineOption -PredictionSource History -ErrorAction SilentlyContinue
    Set-PSReadLineOption -PredictionViewStyle ListView -ErrorAction SilentlyContinue
}

# 5. Shared Aliases
Set-Alias -Name 'll' -Value 'ls' -Option AllScope