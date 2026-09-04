# --- Configurations ---
$Username = "teeratus2"
$FolderPath = "C:\scan-canon2"
$ShareName = "scan-canon2"

# 4. Create SMB Share
if (Get-SmbShare -Name $ShareName -ErrorAction SilentlyContinue) {
    Write-Host "SMB Share '$ShareName' already exists. Skipping share creation." -ForegroundColor Yellow
} else {
    Write-Host "Sharing folder '$FolderPath' as '$ShareName' with Change permissions for '$Username'..." -ForegroundColor Green
    # -ChangeAccess allows Read/Write/Delete but not permission changes
    New-SmbShare -Name $ShareName -Path $FolderPath -ChangeAccess $Username -Description "Scanner network share folder" | Out-Null
    Write-Host "SMB Share '$ShareName' created successfully." -ForegroundColor Green
}