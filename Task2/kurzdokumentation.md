# AD-Verwaltungsskript – Kurzinfo

## Zweck

Dieses Skript hilft dabei, Active Directory Objekte wie OUs, Benutzer, Gruppen, Passwortregeln und das Desktop-Hintergrundbild einfach über ein Menü zu verwalten.

---

## Start

Beim Start wirst du gefragt:
Bitte die Basis-Domaene eingeben (z.B. DC=bbw,DC=lab)

---

## Menüpunkte

1. **OU-Verwaltung**
   - OUs erstellen und löschen (mit Warnung und Auswahl für rekursives oder nicht-rekursives Löschen)
   - OUs anzeigen

2. **Gruppen-Verwaltung**
   - Gruppe erstellen/löschen (mit Bestätigung)
   - Benutzer zur Gruppe hinzufügen
   - Gruppen anzeigen

3. **Benutzer-Verwaltung**
   - Benutzer erstellen/löschen (mit Bestätigung)
   - Benutzer aktivieren/deaktivieren
   - Benutzer umbenennen/verschieben
   - Passwort zurücksetzen
   - Benutzer anzeigen

4. **GPO-Wallpaper**
   - Hintergrundbild per Gruppenrichtlinie setzen
   - Hintergrundbild löschen/zurücksetzen (auf Default)

5. **Passwort-Policy**
   - Aktuelle Richtlinie anzeigen
   - Neue Policy setzen (mit Plausibilitätsprüfung und Bestätigung)

---

## Hinweise

- **Alle Namen** (z.B. von OUs, Gruppen, Usern) müssen exakt so wie im AD existieren.
- Das Skript prüft, ob Objekte schon da sind, bevor sie angelegt oder gelöscht werden.
- Bei kritischen Aktionen (z.B. Löschen) kommt immer eine Sicherheitsabfrage.
- Nach einer Änderung des Hintergrundbilds:  
  Auf dem Client `gpupdate /force` ausführen und ggf. neu anmelden.
- Zum Beenden einfach im Hauptmenü `0` auswählen.

---

**Autor:** Jannik Luethi  
**Projekt:** Powershell Schulübung AD  