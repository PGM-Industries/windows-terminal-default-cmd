# Script explanation for the user
Write-Host "======================================================================================================================="
Write-Host "[i] This script updates the Windows terminal configuration file to customize the default terminal application."
Write-Host "[i] Old: Powershell | New: Command Prompt"
Write-Host "[!] It may not be terminated during execution."
Start-Sleep -Seconds 5
Write-Host "[i] Start script..."
Write-Host ""

# Start Log
Start-Transcript -Path "C:\Logs\wt.log" -Append -IncludeInvocationHeader

# VARIABLES
$username = $env:USERNAME
$windowsTerminalInstalled = Get-Command "wt" -ErrorAction SilentlyContinue
$jsonFilePath = "C:\Users\$username\AppData\Local\Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState\settings.json"
$configFolderPath = "C:\Users\$username\AppData\Local\Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState\"
$cmdGuid = "{0caa0dad-35be-5f56-a8ff-afceeeaa6101}"



# Protection
try {


    # Check if Windows Terminal is installed
    Write-Host "[...] Search for Windows Terminal"
    if (!$windowsTerminalInstalled) {
        # Statusmeldung
        Write-Host "Windows Terminal is not installed!"
        Exit
    }
    Write-Host "[OK] Windows Terminal found"


    # Remove existing configurations
    Write-Host "[...] Remove existing configurations"
    if (Test-Path -Path $configFolderPath -PathType Container) {
        Get-ChildItem -Path $configFolderPath | ForEach-Object {
            if (-not $_.PSIsContainer) {
                Remove-Item -Path $_.FullName -Force
            }
        }
    }
    Write-Host "[OK] Existing configurations were removed"


    # Create new configuration file
    Write-Host "[...] Create new configuration"
    Start-Process "wt.exe"
    while (-not (Test-Path -Path $jsonFilePath)) {
        Start-Sleep -Milliseconds 500
    }
    Stop-Process -Name "WindowsTerminal" -Force
    Write-Host "[OK] New configuration was created"


    # Reading the JSON file
    Write-Host "[...] Read configuration content"
    $jsonContent = Get-Content -Path $jsonFilePath


    # Look for the line with the GUID for the command prompt
    Write-Host "[...] Replace default terminal application"
    $lineToReplace = $jsonContent | Where-Object { $_ -match ".*""guid"":.*""$cmdGuid"".*" }
    if ($lineToReplace) {
        $jsonContent = $jsonContent -replace ".*""defaultProfile"":.*", "    `"defaultProfile`": `"$cmdGuid`","
        $jsonContent | Set-Content -Path $jsonFilePath
    } else {
        Add-Content -Path $logFilePath -Value $logMessage
    }
    Write-Host "[OK] Default terminal application was replaced"


# End of Protection
} catch {
    Write-Host ""
    Write-Host "[!] Error message:"
    Write-Host "[!] $PSItem"
    Write-Host ""
    Write-Host "[!] Advanced information:"
    Write-Host "[!]" $_.ScriptStackTrace
    Exit
}


#End of Log
Stop-Transcript


Write-Host ""
Write-Host "[i] The execution of the script is completed."
Write-Host "======================================================================================================================="
Start-Sleep -Seconds 5
Exit
