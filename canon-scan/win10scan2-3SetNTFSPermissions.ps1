# --- Configurations ---
$Username = "teeratus2"
$FolderPath = "C:\scan-canon2"

# 3. Set NTFS Permissions (Modify / Read-Write access)
Write-Host "Setting NTFS permissions for '$Username' on '$FolderPath'..." -ForegroundColor Green
$Acl = Get-Acl $FolderPath
$AccessRule = New-Object System.Security.AccessControl.FileSystemAccessRule(
    $Username, 
    "Modify", 
    "ContainerInherit, ObjectInherit", 
    "None", 
    "Allow"
)
$Acl.SetAccessRule($AccessRule)
Set-Acl $FolderPath $Acl