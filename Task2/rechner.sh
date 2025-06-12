#!/bin/bash

# Taschenrechner Skript
# Von: Jannik Lüthi
# Datum: 12.06.2025
# 
# WICHTIG: Dieses Skript benötigt 'bc' zum Rechnen!
# Falls nicht installiert: sudo apt install bc (Ubuntu) oder brew install bc (Mac)

echo "*** Mein Taschenrechner ***"
echo

# Funktion um zu prüfen ob eine Eingabe eine Zahl ist
ist_zahl() {
    eingabe="$1"
    # Regex um zu checken ob es eine Zahl ist (auch mit Komma)
    if [[ $eingabe =~ ^-?[0-9]+([.][0-9]+)?$ ]]; then
        return 0  
    else
        return 1  
    fi
}

# Funktion um zu prüfen ob die Operation ok ist
ist_operation_ok() {
    op="$1"
    if [[ "$op" == "+" || "$op" == "-" || "$op" == "*" || "$op" == "/" ]]; then
        return 0  
    else
        return 1  
    fi
}

# Funktion für das Rechnen
rechne() {
    zahl1="$1"
    zahl2="$2"
    rechenart="$3"
    
    # Je nach Operation anders rechnen
    if [[ "$rechenart" == "+" ]]; then
        echo "scale=2; $zahl1 + $zahl2" | bc
    elif [[ "$rechenart" == "-" ]]; then
        echo "scale=2; $zahl1 - $zahl2" | bc
    elif [[ "$rechenart" == "*" ]]; then
        echo "scale=2; $zahl1 * $zahl2" | bc
    elif [[ "$rechenart" == "/" ]]; then
        # Prüfen ob durch 0 geteilt wird
        if [[ $(echo "$zahl2 == 0" | bc) -eq 1 ]]; then
            echo "FEHLER: Man kann nicht durch 0 teilen!"
            return 1
        fi
        echo "scale=2; $zahl1 / $zahl2" | bc
    fi
}

# Hauptschleife - läuft bis user "exit" eingibt
while true; do
    # Erste Zahl holen
    while true; do
        echo "Geben Sie die erste Zahl ein (oder 'exit' zum Beenden):"
        read -p "> " erste_zahl
        
        # Schauen ob user exit will
        if [[ "$erste_zahl" == "exit" ]]; then
            echo "Auf Wiedersehen!"
            exit 0
        fi
        
        # Prüfen ob es eine gültige Zahl ist
        if ist_zahl "$erste_zahl"; then
            break  
        else
            echo "Das ist keine gültige Zahl! Bitte nochmal versuchen."
            echo
        fi
    done
    
    # Zweite Zahl holen
    while true; do
        echo "Geben Sie die zweite Zahl ein:"
        read -p "> " zweite_zahl
        
        # Prüfen ob es eine gültige Zahl ist
        if ist_zahl "$zweite_zahl"; then
            break 
        else
            echo "Das ist keine gültige Zahl! Bitte nochmal versuchen."
            echo
        fi
    done
    
    # Operation auswählen lassen
    while true; do
        echo "Wählen Sie die Operation (+, -, *, /):"
        read -p "> " operation
        
        # Prüfen ob Operation gültig ist
        if ist_operation_ok "$operation"; then
            break 
        else
            echo "Ungültige Operation! Nur +, -, * oder / sind erlaubt."
            echo
        fi
    done
    
    # Jetzt rechnen
    ergebnis=$(rechne "$erste_zahl" "$zweite_zahl" "$operation")
    
    # Schauen ob das Rechnen geklappt hat
    if [[ $? -eq 0 ]]; then
        echo "Ergebnis: $ergebnis"
    else
        echo "$ergebnis"  
    fi
    
    echo  
done