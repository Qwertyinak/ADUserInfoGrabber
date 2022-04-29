<#
Get-ExecutionPolicy
Set-ExecutionPolicy RemoteSigned
#>

# initial setup
# get current directory
$current_dir = (Get-Location).Path
# check if log.txt exists in the current directory and if not, create it
if (!(Test-Path $current_dir\log.txt)) {
    New-Item -Path $current_dir\log.txt -Force
    # write "new log file created" to host 
    Write-Host "new log file created" -ForegroundColor Yellow
    Start-Sleep -s 1
    # write "new log file created" to log file
    Add-Content "new log file created" -Path $current_dir\log.txt
    Start-Sleep -s 1
}
# if log log exists, write "using existing log" to the host
if (Test-Path $current_dir\log.txt) {
    Write-Host "using existing log" -ForegroundColor Green
    Start-Sleep -s 1
    # write "using existing log" to log file
    Add-Content "" -Path $current_dir\log.txt
    Add-Content "" -Path $current_dir\log.txt
    Add-Content "" -Path $current_dir\log.txt
    Add-Content "----------------------------------------" -Path $current_dir\log.txt
    Add-Content "using existing log" -Path $current_dir\log.txt
}
# get the current time down to the second
$current_time = Get-Date -Format "yyyy-MM-dd_HH-mm-ss"
# log the current time and directory
Add-Content "current time: $current_time" -Path $current_dir\log.txt
Add-Content "current directory: $current_dir" -Path $current_dir\log.txt
# check if active directory is running
$ad_service = Get-WmiObject -Class Win32_Service -Filter "Name='kdc'"
Add-Content "checking if active directory is running" -Path $current_dir\log.txt
# if it is not running, tell the user and exit
if ($ad_service.State -ne 'Running') {
    Write-Host "Active Directory is not running. Exiting." -ForegroundColor Red
    # write "Active Directory is not running. Exiting." to log file
    Add-Content "Active Directory is not running. Exiting." -Path $current_dir\log.txt
    exit 1
}

# ask the user to select a number
Write-Host "Please select a number from the following list:" -ForegroundColor Green
Write-Host "1. List all ADUsers details"
Write-Host "2. List all expired ADUsers"
Write-Host "3. Compare 2 files and list the differences"
Add-Content "asked for a number" -Path $current_dir\log.txt

$choice = Read-Host "Enter your choice: "
# log the user's choice
Add-Content "user's choice: $choice" -Path $current_dir\log.txt

# if the user's choice is not 1, 2 or 3, tell the user and exit
if ($choice -ne 1 -and $choice -ne 2 -and $choice -ne 3) {
    Write-Host "Invalid choice. Exiting." -ForegroundColor Red
    # write "Invalid choice. Exiting." to log file
    Add-Content "Invalid choice. Exiting." -Path $current_dir\log.txt
    exit 1
}

# if the user selects 1, list all ADUsers details
try {
    if ( $choice -eq 1 ) {
        Write-Host "listing all ADUsers" -ForegroundColor Yellow
        # write "listing all ADUsers" to log file
        Add-Content "listing all ADUsers" -Path $current_dir\log.txt
        Start-Sleep -s 1
        Get-ADUser -filter * -properties * | sort Name | ft Name, LastBadPasswordAttempt, LastLogonDate, LockedOut, PasswordLastSet, PasswordExpired, PasswordNeverExpires
        Start-Sleep -s 1
        $fileName = "ADUsers_details_" + $current_time + ".txt"
        Get-ADUser -filter * -properties * | sort Name | ft Name, LastBadPasswordAttempt, LastLogonDate, LockedOut, PasswordLastSet, PasswordExpired, PasswordNeverExpires > $fileName
        Get-Content $fileName | Add-Content -Path $current_dir\log.txt
        Write-Host "saved to" $fileName -ForegroundColor Yellow
        Add-Content $fileName -Path $current_dir\log.txt
        Write-Host "done" -ForegroundColor Green
        Add-Content "done" -Path $current_dir\log.txt
    }
}
catch {
    Write-Host "ERROR:" $error[0] -ForegroundColor Red
    # write "Error: $ErrorMessage" to log file
    Add-Content "vvvERRORvvv" -Path $current_dir\log.txt
    Add-Content $error[0] -Path $current_dir\log.txt
    Add-Content "^^^ERROR^^^" -Path $current_dir\log.txt
}

# if the user selects 2, list all expired ADUsers
try {
    if ( $choice -eq 2 ) {
        Write-Host "listing all expired ADUsers" -ForegroundColor Yellow
        # write "listing all expired ADUsers" to log file
        Add-Content "listing all expired ADUsers" -Path $current_dir\log.txt
        Start-Sleep -s 1
        Get-ADUser -filter * -properties * | Where-Object {($_.'msDS-User-Account-Control-Computed' -band 0x800000) -eq 0x800000} | Sort Name | ft Name, LastBadPasswordAttempt, LastLogonDate, LockedOut, PasswordLastSet, PasswordExpired, PasswordNeverExpires
        Start-Sleep -s 1
        $fileName = "ADUsers_expired_" + $current_time + ".txt"
        Get-ADUser -filter * -properties * | Where-Object {($_.'msDS-User-Account-Control-Computed' -band 0x800000) -eq 0x800000} | Sort Name | ft Name, LastBadPasswordAttempt, LastLogonDate, LockedOut, PasswordLastSet, PasswordExpired, PasswordNeverExpires > $fileName
        Get-Content $fileName | Add-Content -Path $current_dir\log.txt
        Write-Host "saved to" $fileName -ForegroundColor Yellow
        Add-Content $fileName -Path $current_dir\log.txt
        Write-Host "done" -ForegroundColor Green
        Add-Content "done" -Path $current_dir\log.txt
    }
}
catch {
    Write-Host "ERROR:" $error[0] -ForegroundColor Red
    # write "Error: $ErrorMessage" to log file
    Add-Content "vvvERRORvvv" -Path $current_dir\log.txt
    Add-Content $error[0] -Path $current_dir\log.txt
    Add-Content "^^^ERROR^^^" -Path $current_dir\log.txt
}

# ask the user to select 2 files to compare
# compare the 2 files and list the differences in a new file named ADUsers_diff.txt
try {
    if ( $choice -eq 3 ) {
        $file1 = Read-Host "Enter the first file to compare: "
        $file2 = Read-Host "Enter the second file to compare: "
        # log the 2 files
        Add-Content "first file: $file1" -Path $current_dir\log.txt
        Add-Content "second file: $file2" -Path $current_dir\log.txt
        Write-Host "comparing 2 files" -ForegroundColor Yellow
        # write "comparing 2 files" to log file
        Add-Content "comparing 2 files" -Path $current_dir\log.txt
        Start-Sleep -s 1
        Compare-Object (Get-Content $file1) (Get-Content $file2)
        Start-Sleep -s 1
        $fileName = "ADUsers_diff_" + $current_time + ".txt"
        Compare-Object (Get-Content $file1) (Get-Content $file2) | Out-File $fileName
        Get-Content $fileName | Add-Content -Path $current_dir\log.txt
        Write-Host "saved to" $fileName -ForegroundColor Yellow
        Add-Content $fileName -Path $current_dir\log.txt
        Write-Host "done" -ForegroundColor Green
        Add-Content "done" -Path $current_dir\log.txt
    }
}
catch {
    Write-Host "ERROR:" $error[0] -ForegroundColor Red
    # write "Error: $ErrorMessage" to log file
    Add-Content "vvvERRORvvv" -Path $current_dir\log.txt
    Add-Content $error[0] -Path $current_dir\log.txt
    Add-Content "^^^ERROR^^^" -Path $current_dir\log.txt
}



# end of script
Write-Host "script completed" -ForegroundColor Green
# write "script completed" to log file
Add-Content "script completed" -Path $current_dir\log.txt






# if the user selects 2,

<#
Get-ADUser -filter * -properties * | sort Name | Format-Table Name, LastBadPasswordAttepmt, LastLogonDate, LockedOut, PasswordLastSet, PasswordExpired, PasswordNeverExpires > ADUsers_details.txt
Write-Output "done"
#>