# --- Configurations ---
$Username = "teeratus2"
$ShareName = "scan-canon2"

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