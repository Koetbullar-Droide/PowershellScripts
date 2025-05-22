# AD-Verwaltungsskript – Kurzinfo

## Zweck

Verwaltung von Active Directory (OUs, Benutzer, Gruppen, Passwortregeln, GPO-Wallpaper) über ein PowerShell-Menü.

⸻

## Start

Beim Start:

Bitte geben Sie die Basis-Domaene ein (z.B. DC=bbw,DC=lab)



⸻

## Menüpunkte

1. OU-Verwaltung
	•	OU erstellen/löschen
	•	OUs anzeigen

2. Gruppen-Verwaltung
	•	Gruppe erstellen/löschen
	•	Benutzer zur Gruppe hinzufügen
	•	Gruppen anzeigen

3. Benutzer-Verwaltung
	•	Benutzer erstellen/löschen
	•	aktivieren/deaktivieren
	•	umbenennen/verschieben
	•	Passwort zurücksetzen
	•	Benutzer anzeigen

4. GPO-Wallpaper
	•	Hintergrundbild per Gruppenrichtlinie setzen

5. Passwort-Policy
	•	Richtlinie anzeigen oder anpassen

⸻

## Wichtig

•	Namen exakt wie in AD verwenden
•	Bei Fehlern auf OU-Struktur achten
•	Nach Wallpaper-Änderung auf Client:
gpupdate /force

⸻

## Beenden

Im Hauptmenü 0 auswählen

⸻

Autor: Jannik Lüthi
Einsatz: Schulprojekt / AD-Übungsskript



