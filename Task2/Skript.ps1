# Author: Jannik Lüthi
Import-Module ActiveDirectory
Import-Module GroupPolicy

# Domäne abfragen
$domainDN = Read-Host "Bitte geben Sie die Basis-Domaene ein (z.B. DC=bbw,DC=lab)"
# daraus FQDN erzeugen (z.B. bbw.lab)
$fqdn = $domainDN -replace 'DC=', '' -replace ',', '.'

function Pause {
    Write-Host "`nDruecken Sie eine beliebige Taste, um fortzufahren..."
    $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
}

# OU-Verwaltung
function OU-Menu {
    do {
        Clear-Host
        Write-Host "********** OU Verwaltung **********"
        Write-Host "1. OU erstellen"
        Write-Host "2. OU loeschen"
        Write-Host "3. OUs anzeigen"
        Write-Host "0. Zurueck"
        $c = Read-Host "Bitte Auswahl eingeben (0-3):"
        switch ($c) {
            "1" {
                $name = Read-Host "Name der neuen OU"
                try {
                    New-ADOrganizationalUnit -Name $name -Path $domainDN -ErrorAction Stop
                    Write-Host "OU erstellt: $name" -ForegroundColor Green
                } catch {
                    Write-Host "Fehler beim Erstellen der OU: $_" -ForegroundColor Red
                }
                Pause
            }
            "2" {
                $name = Read-Host "Name der zu loeschenden OU"
                $id   = "OU=$name,$domainDN"
                try {
                    Get-ADOrganizationalUnit -Identity $id | Set-ADObject -ProtectedFromAccidentalDeletion $false -ErrorAction Stop
                    Remove-ADOrganizationalUnit -Identity $id -Recursive -Confirm:$false -ErrorAction Stop
                    Write-Host "OU geloescht: $name" -ForegroundColor Green
                } catch {
                    Write-Host "Fehler beim Loeschen der OU: $_" -ForegroundColor Red
                }
                Pause
            }
            "3" {
                Clear-Host
                Write-Host "+++ OUs unter $domainDN +++" -ForegroundColor Cyan
                Get-ADOrganizationalUnit -Filter * -SearchBase $domainDN |
                    Select Name, DistinguishedName |
                    Format-Table -AutoSize
                Pause
            }
            "0" { break }
            default {
                Write-Host "Ungueltige Auswahl." -ForegroundColor Red
                Pause
            }
        }
    } until ($c -eq "0")
}

# Gruppen-Verwaltung
function Group-Menu {
    do {
        Clear-Host
        Write-Host "********** Gruppen Verwaltung **********"
        Write-Host "1. Gruppe erstellen"
        Write-Host "2. Gruppe loeschen"
        Write-Host "3. Benutzer zur Gruppe hinzufuegen"
        Write-Host "4. Gruppen anzeigen"
        Write-Host "0. Zurueck"
        $c = Read-Host "Bitte Auswahl eingeben (0-4):"
        switch ($c) {
            "1" {
                $grp  = Read-Host "Name der neuen Gruppe"
                $ou   = Read-Host "OU fuer Gruppe"
                $path = "OU=$ou,$domainDN"
                try {
                    New-ADGroup -Name $grp -GroupCategory Security -GroupScope DomainLocal -Path $path -ErrorAction Stop
                    Write-Host "Gruppe erstellt: $grp" -ForegroundColor Green
                } catch {
                    Write-Host "Fehler beim Erstellen der Gruppe: $_" -ForegroundColor Red
                }
                Pause
            }
            "2" {
                $grp = Read-Host "Name der zu loeschenden Gruppe"
                try {
                    Remove-ADGroup -Identity $grp -Confirm:$false -ErrorAction Stop
                    Write-Host "Gruppe geloescht: $grp" -ForegroundColor Green
                } catch {
                    Write-Host "Fehler beim Loeschen der Gruppe: $_" -ForegroundColor Red
                }
                Pause
            }
            "3" {
                $user = Read-Host "Benutzername"
                $grp  = Read-Host "Gruppenname"
                try {
                    Add-ADGroupMember -Identity $grp -Members $user -ErrorAction Stop
                    Write-Host "Benutzer $user hinzugefuegt." -ForegroundColor Green
                } catch {
                    Write-Host "Fehler beim Hinzufuegen: $_" -ForegroundColor Red
                }
                Pause
            }
            "4" {
                Clear-Host
                Write-Host "+++ Gruppen unter $domainDN +++" -ForegroundColor Cyan
                Get-ADGroup -Filter * -SearchBase $domainDN |
                    Select Name, GroupScope, GroupCategory, DistinguishedName |
                    Format-Table -AutoSize
                Pause
            }
            "0" { break }
            default {
                Write-Host "Ungueltige Auswahl." -ForegroundColor Red
                Pause
            }
        }
    } until ($c -eq "0")
}

# Benutzer-Verwaltung
function User-Menu {
    do {
        Clear-Host
        Write-Host "********** Benutzer Verwaltung **********"
        Write-Host "1. Benutzer erstellen"
        Write-Host "2. Benutzer loeschen"
        Write-Host "3. Aktivieren/Deaktivieren"
        Write-Host "4. Umbenennen"
        Write-Host "5. Verschieben"
        Write-Host "6. Passwort reset"
        Write-Host "7. Benutzer anzeigen"
        Write-Host "0. Zurueck"
        $c = Read-Host "Bitte Auswahl eingeben (0-7):"
        switch ($c) {
            "1" {
                $u   = Read-Host "Name des neuen Users"
                $ou  = Read-Host "OU fuer User"
                $upw = Read-Host "Passwort" -AsSecureString
                try {
                    New-ADUser -Name $u -AccountPassword $upw -Path "OU=$ou,$domainDN" -PassThru -ErrorAction Stop
                    Enable-ADAccount -Identity $u -ErrorAction Stop
                    Write-Host "User erstellt & aktiviert: $u" -ForegroundColor Green
                } catch {
                    Write-Host "Fehler beim Erstellen: $_" -ForegroundColor Red
                }
                Pause
            }
            "2" {
                $u = Read-Host "Benutzername"
                try {
                    Remove-ADUser -Identity $u -Confirm:$false -ErrorAction Stop
                    Write-Host "User geloescht: $u" -ForegroundColor Green
                } catch {
                    Write-Host "Fehler beim Loeschen: $_" -ForegroundColor Red
                }
                Pause
            }
            "3" {
                $u = Read-Host "Benutzername"
                $a = Read-Host "a=aktivieren, d=deaktivieren"
                try {
                    if ($a -eq 'a') { Enable-ADAccount -Identity $u -ErrorAction Stop; Write-Host "Aktiviert: $u" -ForegroundColor Green }
                    elseif ($a -eq 'd') { Disable-ADAccount -Identity $u -ErrorAction Stop; Write-Host "Deaktiviert: $u" -ForegroundColor Yellow }
                    else { Write-Host "Ungueltige Aktion." -ForegroundColor Red }
                } catch {
                    Write-Host "Fehler: $_" -ForegroundColor Red
                }
                Pause
            }
            "4" {
                $old = Read-Host "Alter Anzeigename"
                $ou  = Read-Host "OU des Users"
                $new = Read-Host "Neuer Anzeigename"
                $id  = "CN=$old,OU=$ou,$domainDN"
                try {
                    Rename-ADObject -Identity $id -NewName $new -ErrorAction Stop
                    Write-Host "Umbenannt in: $new" -ForegroundColor Green
                } catch {
                    Write-Host "Fehler: $_" -ForegroundColor Red
                }
                Pause
            }
            "5" {
                $u     = Read-Host "Benutzername"
                $from  = Read-Host "Aktuelle OU"
                $to    = Read-Host "Ziel-OU"
                $id    = "CN=$u,OU=$from,$domainDN"
                $tpath = "OU=$to,$domainDN"
                try {
                    Move-ADObject -Identity $id -TargetPath $tpath -ErrorAction Stop
                    Write-Host "Verschoben nach: $to" -ForegroundColor Green
                } catch {
                    Write-Host "Fehler: $_" -ForegroundColor Red
                }
                Pause
            }
            "6" {
                $u   = Read-Host "Benutzername"
                $npw = Read-Host "Neues Passwort" -AsSecureString
                try {
                    Set-ADAccountPassword -Identity $u -NewPassword $npw -Reset -ErrorAction Stop
                    Write-Host "Passwort reset fuer: $u" -ForegroundColor Green
                } catch {
                    Write-Host "Fehler: $_" -ForegroundColor Red
                }
                Pause
            }
            "7" {
                Clear-Host
                Write-Host "+++ Users unter $domainDN +++" -ForegroundColor Cyan
                Get-ADUser -Filter * -SearchBase $domainDN |
                    Select Name, SamAccountName, Enabled, DistinguishedName |
                    Format-Table -AutoSize
                Pause
            }
            "0" { break }
            default {
                Write-Host "Ungueltige Auswahl." -ForegroundColor Red
                Pause
            }
        }
    } until ($c -eq "0")
}

# GPO Wallpaper
function Wallpaper-Menu {
    Clear-Host
    Write-Host "********** GPO Wallpaper Verwaltung **********"
    $path = Read-Host "UNC-Pfad zum Bild (z.B. \\server\share\bild.png)"
    try {
        Remove-GPPrefRegistryValue -Name "Default Domain Policy" -Context User `
            -Key "HKCU\Control Panel\Desktop" -ValueName Wallpaper -ErrorAction SilentlyContinue
        Set-GPPrefRegistryValue -Name "Default Domain Policy" -Context User -Action Replace `
            -Key "HKCU\Control Panel\Desktop" -ValueName Wallpaper -Type String -Value $path
        Write-Host "Wallpaper gesetzt." -ForegroundColor Green
        Write-Host "Meister, gpupdate /force auf Clients ausfuehren." -ForegroundColor Yellow
    } catch {
        Write-Host "Fehler: $_" -ForegroundColor Red
    }
    Pause
}

# Passwort-Policy
function PasswordPolicy-Menu {
    do {
        Clear-Host
        Write-Host "***** Password Policy Verwaltung *****"
        Write-Host "1. Aktuelle Policy anzeigen"
        Write-Host "2. Policy anpassen"
        Write-Host "0. Zurueck"
        $c = Read-Host "Auswahl (0-2):"
        switch ($c) {
            "1" {
                Get-ADDefaultDomainPasswordPolicy -Identity $fqdn | Format-List
                Pause
            }
            "2" {
                # Min-Laenge
                do {
                    $minLen = Read-Host "Minimale Passwortlaenge (10-16)"
                } until ($minLen -as [int] -and $minLen -ge 10 -and $minLen -le 16)
                # Max-Age in Tagen
                do {
                    $maxDays = Read-Host "Max Passwortalter in Tagen (mindestens 30)"
                } until ($maxDays -as [int] -and $maxDays -ge 30)
                # Min-Age in Tagen
                do {
                    $minDays = Read-Host "Min Passwortalter in Tagen (mindestens 0)"
                } until ($minDays -as [int] -and $minDays -ge 0)
                # History Count
                do {
                    $hist = Read-Host "Password History Count (0-50)"
                } until ($hist -as [int] -and $hist -ge 0 -and $hist -le 50)
                # Complexity
                $cx = Read-Host "Komplexitaet erzwingen? (j/n)"
                $cx = $cx -eq 'j'
                # Reversible
                $rv = Read-Host "Reversible Encryption? (j/n)"
                $rv = $rv -eq 'j'
                # TimeSpan-Strings
                $maxTS = "{0}.00:00:00" -f $maxDays
                $minTS = "{0}.00:00:00" -f $minDays
                try {
                    Set-ADDefaultDomainPasswordPolicy -Identity $fqdn `
                        -MinPasswordLength $minLen `
                        -MaxPasswordAge $maxTS `
                        -MinPasswordAge $minTS `
                        -PasswordHistoryCount $hist `
                        -ComplexityEnabled $cx `
                        -ReversibleEncryptionEnabled $rv -ErrorAction Stop
                    Write-Host "Policy aktualisiert." -ForegroundColor Green
                } catch {
                    Write-Host "Fehler: $_" -ForegroundColor Red
                }
                Pause
            }
            "0" { break }
            default {
                Write-Host "Ungueltige Auswahl." -ForegroundColor Red
                Pause
            }
        }
    } until ($c -eq "0")
}

# Hauptmenü
do {
    Clear-Host
    Write-Host "********** AD Management Hauptmenue **********"
    Write-Host "1. OU Verwaltung"
    Write-Host "2. Gruppen Verwaltung"
    Write-Host "3. Benutzer Verwaltung"
    Write-Host "4. GPO Wallpaper setzen"
    Write-Host "5. Password Policy verwalten"
    Write-Host "0. Beenden"
    $m = Read-Host "Meister, Auswahl (0-5):"
    switch ($m) {
        "1" { OU-Menu }
        "2" { Group-Menu }
        "3" { User-Menu }
        "4" { Wallpaper-Menu }
        "5" { PasswordPolicy-Menu }
        "0" {
            Write-Host "Programm beendet." -ForegroundColor Cyan
            break
        }
        default {
            Write-Host "Ungueltige Auswahl." -ForegroundColor Red
            Pause
        }
    }
} while ($true)