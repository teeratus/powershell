# Powershell Script to configure local user, create folder, share it on the network, and display network paths.
# IMPORTANT: Run this script in PowerShell as an Administrator.

# --- Configurations ---
$Username = "teeratus2"
$Password = "7654321"
$FolderPath = "C:\scan-canon2"
$ShareName = "scan-canon2"

Write-Host "==========================================" -ForegroundColor Cyan
Write-Host "Starting Windows Share Configuration Setup" -ForegroundColor Cyan
Write-Host "==========================================" -ForegroundColor Cyan

# 1. Create User
$PasswordSecure = ConvertTo-SecureString $Password -AsPlainText -Force

if (Get-LocalUser -Name $Username -ErrorAction SilentlyContinue) {
    Write-Host "User '$Username' already exists. Skipping creation." -ForegroundColor Yellow
} else {
    Write-Host "Creating user '$Username'..." -ForegroundColor Green
    New-LocalUser -Name $Username -Password $PasswordSecure -PasswordNeverExpires -Description "Account for network scanner access" | Out-Null
    Write-Host "User '$Username' created successfully." -ForegroundColor Green
}

# 2. Create Folder
if (-not (Test-Path -Path $FolderPath)) {
    Write-Host "Creating directory '$FolderPath'..." -ForegroundColor Green
    New-Item -Path $FolderPath -ItemType Directory | Out-Null
} else {
    Write-Host "Directory '$FolderPath' already exists." -ForegroundColor Yellow
}

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

# 4. Create SMB Share
if (Get-SmbShare -Name $ShareName -ErrorAction SilentlyContinue) {
    Write-Host "SMB Share '$ShareName' already exists. Skipping share creation." -ForegroundColor Yellow
} else {
    Write-Host "Sharing folder '$FolderPath' as '$ShareName' with Change permissions for '$Username'..." -ForegroundColor Green
    # -ChangeAccess allows Read/Write/Delete but not permission changes
    New-SmbShare -Name $ShareName -Path $FolderPath -ChangeAccess $Username -Description "Scanner network share folder" | Out-Null
    Write-Host "SMB Share '$ShareName' created successfully." -ForegroundColor Green
}

# 5. Get IP Address and Computer Name
$ComputerName = $env:COMPUTERNAME
# Get active IPv4 addresses (excluding loopback and APIPA)
$IPAddresses = (Get-NetIPAddress -AddressFamily IPv4 | Where-Object { 
    $_.IPAddress -notlike "127.0.0.1" -and 
    $_.IPAddress -notlike "169.254.*" -and 
    $_.InterfaceAlias -notlike "*Loopback*" 
}).IPAddress

Write-Host "`n==========================================" -ForegroundColor Cyan
Write-Host "Setup Completed! Network Share Details:" -ForegroundColor Cyan
Write-Host "==========================================" -ForegroundColor Cyan
Write-Host "Computer Name: $ComputerName" -ForegroundColor White
Write-Host "IP Address(es):" -ForegroundColor White
foreach ($IP in $IPAddresses) {
    Write-Host "  - $IP" -ForegroundColor White
}

Write-Host "`nUse the following UNC paths to configure your scanner:" -ForegroundColor Cyan
Write-Host "`n--- Share: $ShareName (User: $Username) ---" -ForegroundColor Yellow
Write-Host "Via Computer Name:" -ForegroundColor White
Write-Host "  \\$ComputerName\$ShareName" -ForegroundColor Green
Write-Host "Via IP Address:" -ForegroundColor White
foreach ($IP in $IPAddresses) {
    Write-Host "  \\$IP\$ShareName" -ForegroundColor Green
}
Write-Host "==========================================" -ForegroundColor Cyan