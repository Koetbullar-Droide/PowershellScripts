# Author: Jannik Lüthi
Import-Module ActiveDirectory

# Domäne abfragen
$domain = Read-Host "Meister, bitte geben Sie die Basis-Domäne ein (z.B. DC=bbw,DC=lab)"

# Hilfsfunktion zum Anhalten
function Pause {
    Write-Host "`nDrücken Sie eine beliebige Taste, um fortzufahren..."
    $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
}

# Untermenü für OU-Verwaltung
function OU-Menu {
    Clear-Host
    Write-Host "********** OU Verwaltung **********" -ForegroundColor Cyan
    Write-Host "1. OU erstellen"
    Write-Host "2. OU löschen"
    Write-Host "0. Zurück"
    $choice = Read-Host "Meister, bitte Auswahl eingeben (0-2):"
    switch ($choice) {
        "1" {
            $ouName = Read-Host "Name der neuen OU"
            try {
                New-ADOrganizationalUnit -Name $ouName -Path $domain -ErrorAction Stop
                Write-Host "OU erstellt: $ouName" -ForegroundColor Green
            } catch {
                Write-Host "Fehler beim Erstellen der OU: $_" -ForegroundColor Red
            }
            Pause
        }
        "2" {
            $ouName = Read-Host "Name der zu löschenden OU"
            $ouPath = "OU=$ouName,$domain"
            try {
                Set-ADObject -Identity $ouPath -ProtectedFromAccidentalDeletion $false -ErrorAction Stop
                Remove-ADOrganizationalUnit -Identity $ouPath -Recursive -Confirm:$false -ErrorAction Stop
                Write-Host "OU gelöscht: $ouName" -ForegroundColor Green
            } catch {
                Write-Host "Fehler beim Löschen der OU: $_" -ForegroundColor Red
            }
            Pause
        }
        "0" { return }
        default {
            Write-Host "Ungültige Auswahl." -ForegroundColor Red
            Pause
        }
    }
}

# Untermenü für Gruppen-Verwaltung
function Group-Menu {
    Clear-Host
    Write-Host "********** Gruppen Verwaltung **********" -ForegroundColor Cyan
    Write-Host "1. Gruppe erstellen"
    Write-Host "2. Gruppe löschen"
    Write-Host "3. Benutzer zur Gruppe hinzufügen"
    Write-Host "0. Zurück"
    $choice = Read-Host "Meister, bitte Auswahl eingeben (0-3):"
    switch ($choice) {
        "1" {
            $groupName = Read-Host "Name der neuen Gruppe"
            $ouName = Read-Host "OU, in der die Gruppe erstellt werden soll"
            $groupPath = "OU=$ouName,$domain"
            try {
                New-ADGroup -Name $groupName -GroupCategory Security -GroupScope DomainLocal -Path $groupPath -ErrorAction Stop
                Write-Host "Gruppe erstellt: $groupName" -ForegroundColor Green
            } catch {
                Write-Host "Fehler beim Erstellen der Gruppe: $_" -ForegroundColor Red
            }
            Pause
        }
        "2" {
            $groupName = Read-Host "Name der zu löschenden Gruppe"
            try {
                Remove-ADGroup -Identity $groupName -Confirm:$false -ErrorAction Stop
                Write-Host "Gruppe gelöscht: $groupName" -ForegroundColor Green
            } catch {
                Write-Host "Fehler beim Löschen der Gruppe: $_" -ForegroundColor Red
            }
            Pause
        }
        "3" {
            $userName = Read-Host "Benutzername"
            $groupName = Read-Host "Gruppenname"
            try {
                Add-ADGroupMember -Identity $groupName -Members $userName -ErrorAction Stop
                Write-Host "Benutzer $userName zur Gruppe $groupName hinzugefügt." -ForegroundColor Green
            } catch {
                Write-Host "Fehler beim Hinzufügen des Benutzers zur Gruppe: $_" -ForegroundColor Red
            }
            Pause
        }
        "0" { return }
        default {
            Write-Host "Ungültige Auswahl." -ForegroundColor Red
            Pause
        }
    }
}

# Untermenü für Benutzer-Verwaltung
function User-Menu {
    Clear-Host
    Write-Host "********** Benutzer Verwaltung **********" -ForegroundColor Cyan
    Write-Host "1. Benutzer erstellen"
    Write-Host "2. Benutzer löschen"
    Write-Host "3. Benutzer aktivieren/deaktivieren"
    Write-Host "4. Benutzer umbenennen"
    Write-Host "5. Benutzer verschieben"
    Write-Host "6. Passwort zurücksetzen"
    Write-Host "0. Zurück"
    $choice = Read-Host "Meister, bitte Auswahl eingeben (0-6):"
    switch ($choice) {
        "1" {
            $userName = Read-Host "Benutzername"
            $ouName = Read-Host "OU, in der der Benutzer erstellt werden soll"
            do {
                $password = Read-Host "Passwort" -AsSecureString
                $confirmPassword = Read-Host "Passwort erneut eingeben" -AsSecureString
                $plainPass = [Runtime.InteropServices.Marshal]::PtrToStringAuto(
                    [Runtime.InteropServices.Marshal]::SecureStringToBSTR($password)
                )
                $plainConfirm = [Runtime.InteropServices.Marshal]::PtrToStringAuto(
                    [Runtime.InteropServices.Marshal]::SecureStringToBSTR($confirmPassword)
                )
                if ($plainPass -ne $plainConfirm) {
                    Write-Host "Passwörter stimmen nicht überein." -ForegroundColor Red
                    $match = $false
                } else {
                    $match = $true
                }
            } until ($match)
            $userPath = "OU=$ouName,$domain"
            try {
                New-ADUser -Name $userName -AccountPassword $password -Path $userPath -PassThru -ErrorAction Stop
                Enable-ADAccount -Identity $userName -ErrorAction Stop
                Write-Host "Benutzer erstellt und aktiviert: $userName" -ForegroundColor Green
            } catch {
                Write-Host "Fehler beim Erstellen oder Aktivieren des Benutzers: $_" -ForegroundColor Red
            }
            Pause
        }
        "2" {
            $userName = Read-Host "Benutzername"
            try {
                Remove-ADUser -Identity $userName -Confirm:$false -ErrorAction Stop
                Write-Host "Benutzer gelöscht: $userName" -ForegroundColor Green
            } catch {
                Write-Host "Fehler beim Löschen des Benutzers: $_" -ForegroundColor Red
            }
            Pause
        }
        "3" {
            $userName = Read-Host "Benutzername"
            $action = Read-Host "Möchten Sie aktivieren oder deaktivieren? (a/d)"
            try {
                if ($action -eq "a") {
                    Enable-ADAccount -Identity $userName -ErrorAction Stop
                    Write-Host "Benutzer aktiviert: $userName" -ForegroundColor Green
                } elseif ($action -eq "d") {
                    Disable-ADAccount -Identity $userName -ErrorAction Stop
                    Write-Host "Benutzer deaktiviert: $userName" -ForegroundColor Yellow
                } else {
                    Write-Host "Ungültige Auswahl." -ForegroundColor Red
                }
            } catch {
                Write-Host "Fehler bei der Änderung des Benutzerstatus: $_" -ForegroundColor Red
            }
            Pause
        }
        "4" {
            $oldName = Read-Host "Aktueller Anzeigename des Benutzers"
            $ouName = Read-Host "OU des Benutzers"
            $newName = Read-Host "Neuer Anzeigename"
            $dn = "CN=$oldName,OU=$ouName,$domain"
            try {
                Rename-ADObject -Identity $dn -NewName $newName -ErrorAction Stop
                Write-Host "Benutzer umbenannt in: $newName" -ForegroundColor Green
            } catch {
                Write-Host "Fehler beim Umbenennen des Benutzers: $_" -ForegroundColor Red
            }
            Pause
        }
        "5" {
            $userName = Read-Host "Benutzername"
            $currentOU = Read-Host "Aktuelle OU des Benutzers"
            $targetOU = Read-Host "Ziel-OU"
            $dn = "CN=$userName,OU=$currentOU,$domain"
            $targetPath = "OU=$targetOU,$domain"
            try {
                Move-ADObject -Identity $dn -TargetPath $targetPath -ErrorAction Stop
                Write-Host "Benutzer verschoben: $userName nach $targetOU" -ForegroundColor Green
            } catch {
                Write-Host "Fehler beim Verschieben des Benutzers: $_" -ForegroundColor Red
            }
            Pause
        }
        "6" {
            $userName = Read-Host "Benutzername"
            $newPassword = Read-Host "Neues Passwort" -AsSecureString
            try {
                Set-ADAccountPassword -Identity $userName -NewPassword $newPassword -Reset -ErrorAction Stop
                Write-Host "Passwort zurückgesetzt für $userName" -ForegroundColor Green
            } catch {
                Write-Host "Fehler beim Zurücksetzen des Passworts: $_" -ForegroundColor Red
            }
            Pause
        }
        "0" { return }
        default {
            Write-Host "Ungültige Auswahl." -ForegroundColor Red
            Pause
        }
    }
}

# Hauptmenü
Do {
    Clear-Host
    Write-Host "********** AD Management Hauptmenü **********" -ForegroundColor Cyan
    Write-Host "1. OU Verwaltung"
    Write-Host "2. Gruppen Verwaltung"
    Write-Host "3. Benutzer Verwaltung"
    Write-Host "0. Beenden"
    $mainChoice = Read-Host "Meister, bitte Auswahl eingeben (0-3):"
    switch ($mainChoice) {
        "1" { OU-Menu }
        "2" { Group-Menu }
        "3" { User-Menu }
        "0" { Write-Host "Programm wird beendet..."; break }
        default {
            Write-Host "Ungültige Auswahl." -ForegroundColor Red
            Pause
        }
    }
} while ($true)
