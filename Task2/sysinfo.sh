#!/bin/bash

# Funktion für Pause nach Anzeige
pause() {
    echo
    echo "-----------------------------------------"
    read -p "Drück ENTER für Menü..." dummy
}

# OS info zeigen
show_os() {
    clear
    echo "### BETRIEBSSYSTEM ###"
    echo "OS Version:"
    cat /etc/os-release | grep PRETTY_NAME
    echo "Kernel:"
    uname -a
    pause
}

# Netzwerk info
show_ip() {
    clear
    echo "### IP ADRESSE ###"
    echo "Meine IPs:"
    ifconfig | grep -A 1 eth0
    pause
}

# RAM anzeigen
show_ram() {
    clear
    echo "### SPEICHER ###"
    echo "RAM info:"
    cat /proc/meminfo | grep 'MemTotal\|MemFree\|MemAvailable'
    free -h
    pause
}

# Festplatten anzeigen
show_disk() {
    clear
    echo "### FESTPLATTE ###"
    echo "Festplatten Platz:"
    df -h
    pause
}

# Prozesse anzeigen
show_proc() {
    clear
    echo "### PROZESSE ###"
    echo "Laufende Prozesse:"
    ps -aux | head -10
    pause
}

# Internet testen
test_net() {
    clear
    echo "### INTERNET TEST ###"
    echo "Ping test:"
    ping -c 4 8.8.8.8
    pause
}

# Webseite testen
test_web() {
    clear
    echo "### WEB TEST ###"
    echo "Webseite check:"
    curl -I https://www.google.com
    pause
}

# Speed test
test_speed() {
    clear
    echo "### SPEED TEST ###"
    
    if command -v speedtest-cli &> /dev/null; then
        speedtest-cli --simple
    else
        echo "Speedtest nicht da."
        read -p "Speedtest installieren? (j/n): " install
        if [ "$install" = "j" ]; then
            sudo apt install speedtest-cli -y
            speedtest-cli --simple
        else
            echo "OK, nicht installiert."
        fi
    fi
    pause
}

# Hauptmenü
while true; do
    clear
    echo "==============================="
    echo "     UBUNTU INFO TOOL         "
    echo "==============================="
    echo "1. OS anzeigen"
    echo "2. IP Adresse anzeigen"
    echo "3. RAM anzeigen"
    echo "4. Festplatten anzeigen"
    echo "5. Prozesse anzeigen"
    echo "6. Internet testen"
    echo "7. Webseite testen"
    echo "8. Speed test"
    echo "0. Beenden"
    echo "==============================="
    read -p "Was willste sehen? " choice
    
    case $choice in
        1) show_os ;;
        2) show_ip ;;
        3) show_ram ;;
        4) show_disk ;;
        5) show_proc ;;
        6) test_net ;;
        7) test_web ;;
        8) test_speed ;;
        0) 
            echo "Tschüss!"
            exit 0
            ;;
        *) 
            echo "Falsche Eingabe."
            sleep 2
            ;;
    esac
done