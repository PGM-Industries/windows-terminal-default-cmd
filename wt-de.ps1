# Skript-Erklärung für den Benutzer
Write-Host "======================================================================================================================="
Write-Host "[i] Dieses Skript aktualisiert die Windows Terminal-Konfigurationsdatei, um die Standardterminalanwendung anzupassen."
Write-Host "[i] Alt: Powershell | Neu: Eingabeaufforderung"
Write-Host "[!] Es darf während der Ausführung nicht beendet werden."
Start-Sleep -Seconds 5
Write-Host "[i] Starte Skript..."
Write-Host ""

# Starte Log
Start-Transcript -Path "C:\Logs\wt.log" -Append -IncludeInvocationHeader

# VARIABLEN
$username = $env:USERNAME
$windowsTerminalInstalled = Get-Command "wt" -ErrorAction SilentlyContinue
$jsonFilePath = "C:\Users\$username\AppData\Local\Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState\settings.json"
$configFolderPath = "C:\Users\$username\AppData\Local\Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState\"
$cmdGuid = "{0caa0dad-35be-5f56-a8ff-afceeeaa6101}"



# Absicherung
try {


    # Überprüfen, ob Windows Terminal installiert ist
    Write-Host "[...] Suche nach Windows Terminal"
    if (!$windowsTerminalInstalled) {
        # Statusmeldung
        Write-Host "Windows Terminal ist nicht installiert!"
        Exit
    }
    Write-Host "[OK] Windows Terminal gefunden"


    # Entferne vorhandene Konfigurationen
    Write-Host "[...] Entferne vorhandene Konfigurationen"
    if (Test-Path -Path $configFolderPath -PathType Container) {
        Get-ChildItem -Path $configFolderPath | ForEach-Object {
            if (-not $_.PSIsContainer) {
                Remove-Item -Path $_.FullName -Force
            }
        }
    }
    Write-Host "[OK] Vorhandene Konfigurationen wurden entfernt"


    # Erstelle eine neue Konfigurationsdatei
    Write-Host "[...] Erstelle neue Konfiguration"
    Start-Process "wt.exe"
    while (-not (Test-Path -Path $jsonFilePath)) {
        Start-Sleep -Milliseconds 500
    }
    Stop-Process -Name "WindowsTerminal" -Force
    Write-Host "[OK] Neue Konfiguration wurde erstellt"


    # Lesen der JSON Datei
    Write-Host "[...] Lese Inhalt der Konfiguration"
    $jsonContent = Get-Content -Path $jsonFilePath


    # Suchen Sie nach der Zeile mit der GUID für die Eingabeaufforderung
    Write-Host "[...] Ersetze Standard Terminalanwendung"
    $lineToReplace = $jsonContent | Where-Object { $_ -match ".*""guid"":.*""$cmdGuid"".*" }
    if ($lineToReplace) {
        $jsonContent = $jsonContent -replace ".*""defaultProfile"":.*", "    `"defaultProfile`": `"$cmdGuid`","
        $jsonContent | Set-Content -Path $jsonFilePath
    } else {
        Add-Content -Path $logFilePath -Value $logMessage
    }
    Write-Host "[OK] Standard Terminalanwendung wurde ersetzt"


#Absicherung
} catch {
    Write-Host ""
    Write-Host "[!] Fehlermeldung:"
    Write-Host "[!] $PSItem"
    Write-Host ""
    Write-Host "[!] Erweiterte Informationen:"
    Write-Host "[!]" $_.ScriptStackTrace
    Exit
}


#Beende Log
Stop-Transcript


Write-Host ""
Write-Host "[i] Die Ausführung des Skriptes ist abgeschlossen."
Write-Host "======================================================================================================================="
Start-Sleep -Seconds 5
Exit
