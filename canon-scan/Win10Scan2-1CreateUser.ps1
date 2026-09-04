# --- Configurations ---
$Username = "teeratus2"
$Password = "7654321"

# 1. Create User
$PasswordSecure = ConvertTo-SecureString $Password -AsPlainText -Force

if (Get-LocalUser -Name $Username -ErrorAction SilentlyContinue) {
    Write-Host "User '$Username' already exists. Skipping creation." -ForegroundColor Yellow
} else {
    Write-Host "Creating user '$Username'..." -ForegroundColor Green
    New-LocalUser 
        -Name $Username 
        -Password $PasswordSecure 
        -PasswordNeverExpires 
        -Description "Account for network scanner access" | Out-Null
    Write-Host "User '$Username' created successfully." -ForegroundColor Green
}

# บัญชีนี้ถูกสร้างมาเพื่อเป็น Service Account (Network Access เท่านั้น)
# จะไม่ไปแสดงเกะกะที่หน้าจอ Login ตอนเปิดเครื่องคอมพิวเตอร์ ทำให้ผู้ใช้งานทั่วไปไม่สับสน


# ถ้าในอนาคตต้องการให้แสดงในหน้า Login / GUI ทั่วไปด้วย:
Add-LocalGroupMember -Group "Users" -Member "teeratus2"

# Remove from Users group if no longer needed in GUI login
Remove-LocalGroupMember -Group "Users" -Member "teeratus2"