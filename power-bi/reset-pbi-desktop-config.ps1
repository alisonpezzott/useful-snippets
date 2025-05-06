# Script to remove all settings of Power BI Desktop

Write-Host "Stoping the Power BI Desktop..." -ForegroundColor Yellow
Stop-Process -Name "PBIDesktop" -ErrorAction SilentlyContinue

# Paths to remove
$pbiFolders = @(
    "$env:LOCALAPPDATA\Microsoft\Power BI Desktop",
    "$env:APPDATA\Microsoft\Power BI Desktop",
    "$env:APPDATA\Microsoft\Power BI Desktop Store App",
    "$env:USERPROFILE\Documents\Power BI Desktop",
    "$env:USERPROFILE\Microsoft\Power BI Desktop Store App"
)

# Deleting paths
foreach ($folder in $pbiFolders) {
    if (Test-Path $folder) {
        Write-Host "Removing folder: $folder" -ForegroundColor Cyan
        Remove-Item -Recurse -Force -Path $folder
    }
}

# Remove the registry key of Power BI Desktop
$pbiRegPath = "HKCU:\Software\Microsoft\Microsoft Power BI Desktop"
if (Test-Path $pbiRegPath) {
    Write-Host "Removing registry key: $pbiRegPath" -ForegroundColor Cyan
    Remove-Item -Recurse -Force -Path $pbiRegPath
}

Write-Host "`n✅ All Power BI settings were removed." -ForegroundColor Green
Write-Host "Start Power BI Desktop and reconfigure from zero."
