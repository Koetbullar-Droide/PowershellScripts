# Author: Jannik Luethi
# Log file erstellen
$logFile = ".\SystemInfoLog.txt"

# Start log
"===== Log gestartet am $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss') =====" | Out-File -FilePath $logFile

# Funktion um Text anzuzeigen und zu loggen
function Show-AndLog {
    param(
        [string]$header,
        [scriptblock]$command
    )
    Write-Host "`n--- $header ---" -ForegroundColor Yellow
    $result = & $command | Out-String
    Write-Host $result
    $datum = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    "$datum - --- $header ---`n$result" | Out-File -FilePath $logFile -Append
}

do {
    Clear-Host
    # Menue anzeigen
    Write-Host "********** System Info Menue **********" -ForegroundColor Cyan
    Write-Host "1. Computername"
    Write-Host "2. Betriebssystem (kurz)"
    Write-Host "3. Genaues Betriebssystem"
    Write-Host "4. RAM anzeigen"
    Write-Host "5. Freier Speicher C:"
    Write-Host "6. Prozesse"
    Write-Host "7. IP-Adressen"
    Write-Host "8. Nur IPv4 Adressen"
    Write-Host "9. IPv4 ohne Loopback"
    Write-Host "10. Benutzer erstellen"
    Write-Host "11. Benutzer löschen"
    Write-Host "12. Passwort ändern"
    Write-Host "13. Letzter Systemstart"
    Write-Host "14. Programme"
    Write-Host "15. Netzwerkadapter"
    Write-Host "16. BIOS Info"
    Write-Host "17. Alle lokalen Benutzer anzeigen"
    Write-Host "0. Beenden"

    $auswahl = Read-Host "`nBitte Zahl eingeben (0-17):"

    switch ($auswahl) {
        "1" { Show-AndLog "Computername" { $env:COMPUTERNAME } }
        "2" { Show-AndLog "Betriebssystem (Windows_NT)" { $env:OS } }
        "3" { Show-AndLog "Genaues Betriebssystem" { Get-CimInstance Win32_OperatingSystem | Select-Object Caption, Version } }
        "4" { 
            Show-AndLog "RAM" { 
                $ram = (Get-CimInstance Win32_OperatingSystem).TotalVisibleMemorySize
                "{0:N2} GB" -f ($ram / 1MB)
            }
        }
        "5" { Show-AndLog "Freier Speicher C:" { "{0:N2} GB" -f ((Get-PSDrive C).Free / 1GB) } }
        "6" { Show-AndLog "Prozesse" { Get-Process | Select-Object ProcessName, Id, CPU } }
        "7" { Show-AndLog "IP-Adressen" { Get-NetIPAddress } }
        "8" { 
            Write-Host "`n--- Nur IPv4 ---" -ForegroundColor Yellow
            $ipListe = ""
            $ips = Get-NetIPAddress | Where-Object { $_.AddressFamily -eq "IPv4" }
            foreach ($ip in $ips) {
                if ($ip.InterfaceAlias -match "Loopback") {
                    $ipListe += "Loopback: $($ip.IPAddress)`n"
                } else {
                    $ipListe += "IPv4: $($ip.IPAddress)`n"
                }
            }
            Write-Host $ipListe
            $zeit = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
            "$zeit - --- Nur IPv4 ---`n$ipListe" | Out-File -FilePath $logFile -Append
        }
        "9" { Show-AndLog "IPv4 ohne Loopback" { (Get-NetIPAddress | Where-Object { $_.AddressFamily -eq "IPv4" -and $_.InterfaceAlias -notmatch "Loopback" }).IPAddress } }
        "10" { 
            $name = Read-Host "Benutzername:"
            $pw = Read-Host "Passwort:" -AsSecureString
            New-LocalUser -Name $name -Password $pw -FullName $name -Description "Schueler User"
            Write-Host "`nBenutzer $name erstellt." -ForegroundColor Green
            "$((Get-Date -Format 'yyyy-MM-dd HH:mm:ss')) - Benutzer $name erstellt." | Out-File -FilePath $logFile -Append
        }
        "11" { 
            $name = Read-Host "Benutzername:"
            Remove-LocalUser -Name $name
            Write-Host "`nBenutzer $name geloescht." -ForegroundColor Green
            "$((Get-Date -Format 'yyyy-MM-dd HH:mm:ss')) - Benutzer $name geloescht." | Out-File -FilePath $logFile -Append
        }
        "12" { 
            $name = Read-Host "Benutzername:"
            $pw = Read-Host "Neues Passwort:" -AsSecureString
            Set-LocalUser -Name $name -Password $pw
            Write-Host "`nPasswort von $name geaendert." -ForegroundColor Green
            "$((Get-Date -Format 'yyyy-MM-dd HH:mm:ss')) - Passwort von $name geaendert." | Out-File -FilePath $logFile -Append
        }
        "13" { Show-AndLog "Letzter Systemstart" { (Get-CimInstance Win32_OperatingSystem).LastBootUpTime } }
        "14" { Show-AndLog "Installierte Programme" { Get-WmiObject -Class Win32_Product | Select-Object Name, Version } }
        "15" { Show-AndLog "Netzwerkadapter" { Get-NetAdapter | Select-Object Name, Status, MacAddress } }
        "16" { Show-AndLog "BIOS Info" { Get-CimInstance Win32_BIOS | Select-Object Manufacturer, SMBIOSBIOSVersion, ReleaseDate } }
        "17" { Show-AndLog "Lokale Benutzer" { Get-LocalUser | Select-Object Name, Enabled, LastLogon } }  # <-- NEUE FUNKTION
        "0" { 
            Write-Host "`nBeende Programm..." -ForegroundColor Green
            "$((Get-Date -Format 'yyyy-MM-dd HH:mm:ss')) - Programm beendet." | Out-File -FilePath $logFile -Append
            exit
        }
        default { Write-Host "`nFalsche Eingabe. Bitte nochmal (0-17)." -ForegroundColor Red }
    }

    Write-Host "`nDrücke eine Taste für Menue..."
    $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
} while ($true)
