# 1. Dynamically find your OneDrive '문서' (Documents) folder
$ActualDocs = [System.Environment]::GetFolderPath('MyDocuments')
$MasterPath = Join-Path $ActualDocs "PowerShell\Shared\Microsoft.PowerShell_profile.ps1"

# 2. Ensure the Shared directory exists
$SharedDir = Split-Path $MasterPath
if (-not (Test-Path $SharedDir)) { New-Item -Path $SharedDir -Type Directory -Force }

# 3. Create the local profile if missing
if (-not (Test-Path $PROFILE)) { New-Item -Path $PROFILE -Type File -Force }

# 4. Link it up (with duplicate protection)
$LinkLine = ". `"$MasterPath`""
if ((Get-Content $PROFILE -ErrorAction SilentlyContinue) -notcontains $LinkLine) {
    Add-Content -Path $PROFILE -Value "`n$LinkLine"
    Write-Host "✅ Successfully linked to: $MasterPath" -ForegroundColor Green
} else {
    Write-Host "ℹ️ Profile already linked." -ForegroundColor Yellow
}