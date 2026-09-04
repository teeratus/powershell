# --- Configurations ---
$FolderPath = "C:\scan-canon2"

# 2. Create Folder
if (-not (Test-Path -Path $FolderPath)) {
    Write-Host "Creating directory '$FolderPath'..." -ForegroundColor Green
    New-Item -Path $FolderPath -ItemType Directory | Out-Null
} else {
    Write-Host "Directory '$FolderPath' already exists." -ForegroundColor Yellow
}