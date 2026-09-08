#
# This script configures advanced sharing settings on Windows 10.
# Teeratus R. 2026-09-08
# Tested on Windows 10 Pro \\office-5
#
# Usage:
#   Run this script with administrative privileges to apply the desired
#   advanced sharing settings on your Windows 10 machine.
#
# Example:
#   .\Win10-Advanced_sharing_settings.ps1

# Private
# -Network discovery
# --Turn on network discovery
netsh advfirewall firewall set rule group="Network Discovery" new enable=Yes
Get-Service -Name "fdPHost", "FDResPub", "SSDPSRV", "upnphost" | Set-Service -StartupType Automatic
Get-Service -Name "fdPHost", "FDResPub", "SSDPSRV", "upnphost" | Start-Service



# -file and printer sharing
# --Turn on file and printer sharing
netsh advfirewall firewall set rule group="File and Printer Sharing" new enable=Yes
Set-Service -Name "LanmanServer" -StartupType Automatic
Start-Service -Name "LanmanServer"


# All networks
# -public folder sharing
# --Turn on sharing so anyone with network access can read and write files in the Public folders.
$PublicPath = "$env:SystemDrive\Users\Public"
if (Get-SmbShare -Name "Public" -ErrorAction SilentlyContinue) {
    Grant-SmbShareAccess -Name "Public" -AccountName "Everyone" -AccessRight Change -Force | Out-Null
} else {
    New-SmbShare -Name "Public" -Path $PublicPath -ChangeAccess "Everyone" -Description "Public Folder Sharing" | Out-Null
}

$Acl = Get-Acl -Path $PublicPath
$AccessRule = New-Object System.Security.AccessControl.FileSystemAccessRule(
    "Everyone",
    "Modify",
    "ContainerInherit, ObjectInherit",
    "None",
    "Allow"
)
$Acl.SetAccessRule($AccessRule)
Set-Acl -Path $PublicPath -AclObject $Acl


# -media streaming

# -File sharing connections
# --Use 128-bit encryption to help protect file sharing connections
#$msvPath = "HKLM:\SYSTEM\CurrentControlSet\Control\Lsa\MSV1_0"
#if (-not (Test-Path $msvPath)) { New-Item -Path $msvPath -Force | Out-Null }
#Set-ItemProperty -Path $msvPath -Name "NtlmMinClientSec" -Value 0x20000000 -Type DWord
#Set-ItemProperty -Path $msvPath -Name "NtlmMinServerSec" -Value 0x20000000 -Type DWord
#
# --Enable file sharing for devices that use 40- or 56-bit encryption
$msvPath = "HKLM:\SYSTEM\CurrentControlSet\Control\Lsa\MSV1_0"
if (-not (Test-Path $msvPath)) { New-Item -Path $msvPath -Force | Out-Null }
Set-ItemProperty -Path $msvPath -Name "NtlmMinClientSec" -Value 0 -Type DWord
Set-ItemProperty -Path $msvPath -Name "NtlmMinServerSec" -Value 0 -Type DWord


# -Password protected sharing
# --Turn on password protected sharing
#$guest = Get-LocalUser | Where-Object { $_.SID -like "*-501" }
#net user $guest.Name /active:no
#Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\Lsa" -Name "LimitBlankPasswordUse" -Value 1 -Type DWord
#Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\Lsa" -Name "everyoneincludesanonymous" -Value 0 -Type DWord
#Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Services\LanmanServer\Parameters" -Name "RestrictNullSessAccess" -Value 1 -Type DWord
#
# --Turn off password protected sharing
$guest = Get-LocalUser | Where-Object { $_.SID -like "*-501" }
net user $guest.Name ""
net user $guest.Name /active:yes
Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\Lsa" -Name "LimitBlankPasswordUse" -Value 0 -Type DWord
Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\Lsa" -Name "everyoneincludesanonymous" -Value 1 -Type DWord
Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Services\LanmanServer\Parameters" -Name "RestrictNullSessAccess" -Value 0 -Type DWord