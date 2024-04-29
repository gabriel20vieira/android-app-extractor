Param($application)

if (!$application) {
    Write-Host -ForegroundColor Red "Provide an application."
    Write-Host -ForegroundColor Yellow "Exiting"
    RETURN
}

Write-Host -NoNewline "Extract: "
Write-Host -ForegroundColor Green "$application"

Function Test-CommandExists {
    Param ($command)
    $oldPreference = $ErrorActionPreference
    $ErrorActionPreference = 'stop'
    try { if (Get-Command $command) { RETURN $true } }
    Catch { RETURN $false }
    Finally { $ErrorActionPreference = $oldPreference }
}

function Wait-EnterKey {
    while ($Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown").VirtualKeyCode -ne 13 ) {
        Start-Sleep -Milliseconds 100
    }
}

function ExtractDataFrom {
    param ($path)
    
    $app_path = $path + "/" + $application + "/"
    $timestamp = Get-Date -Format "yyyyMMddHHmmss"
    $zip_name = $timestamp + $path.replace('/', '.') + $application + ".tgz"
    $save_to = "/sdcard/Download/" + $zip_name

    adb shell "su 0 tar -cvzf $save_to $app_path" *>$null
    adb pull $save_to *>$null
}

function ExtractFolderExists {
    param ($path)
    if ((adb shell "if test -d $path; then echo 'exist'; fi")) {
        RETURN $true
    }
    RETURN $false
}

function CanExtractPermissions {
    Param ($path)
    if (!(adb shell "su 0 ls $path | grep 'denied'")) {
        RETURN $true
    }
    RETURN $false
}

function ExtractSuite {
    Param($location)
    $extractFolder = $location
    $canExtract = CanExtractPermissions($extractFolder)
    $folderExists = ExtractFolderExists($extractFolder)
    
    Write-Host ""
    Write-Host -NoNewline "Folder`t`t"
    Write-Host $extractFolder
    Write-Host -NoNewline "Exists`t`t"
    if ($folderExists) { Write-Host -ForegroundColor Green "Yes" } else { Write-Host -ForegroundColor Red "No" }
    Write-Host -NoNewline "Permission`t"
    if ($canExtract) { Write-Host -ForegroundColor Green "Yes" } else { Write-Host -ForegroundColor Red "No" }

    ExtractDataFrom($extractFolder)

    Write-Host -NoNewline "Extracted`t"
    if ($canExtract) { Write-Host -ForegroundColor Green "Yes" } else { Write-Host -ForegroundColor Red "No" }
}

$adb_exec = "adb"

If (Test-CommandExists($adb_exec)) {
    Write-Host -NoNewline "ADB Exists: "
    Write-Host -ForegroundColor Green "Yes"
    Write-Host "Script will always use the first device in adb, make sure only one is active.`nEnter to continue..."
    Wait-EnterKey

    Write-Host -NoNewline "Application installed on device: "
    if (!(adb shell cmd package list packages | findstr $application)) {
        Write-Host -ForegroundColor Red "No"
        Write-Host -ForegroundColor Yellow "Exiting"
    }
    else {
        Write-Host -ForegroundColor Green "Yes"
    }

    Write-Host "Starting extration ..."

    ExtractSuite("/data/data")
    ExtractSuite("/data/user_de/0")
    ExtractSuite("/data/user/0")

}
else {
    Write-Host -NoNewline "ADB Exists: "
    Write-Host -ForegroundColor Red "No"
    "'$adb_exec' does not exist. Please install it on the machine or check the environment variables."
}

# adb shell "su 0 tar -cvzf /sdcard/Download/data.data.com.azure.authenticator.tgz /data/data/com.azure.authenticator/"
# adb pull /sdcard/Download/data.data.com.azure.authenticator.tgz

# adb shell "su 0 tar -cvzf /sdcard/Download/data.user_de.0.com.azure.authenticator.tgz /data/user_de/0/com.azure.authenticator/"
# adb pull /sdcard/Download/data.user_de.0.com.azure.authenticator.tgz

# adb shell "su 0 tar -cvzf /sdcard/Download/data.user.0.com.azure.authenticator.tgz /data/user/0/com.azure.authenticator/"
# adb pull /sdcard/Download/data.user.0.com.azure.authenticator.tgz