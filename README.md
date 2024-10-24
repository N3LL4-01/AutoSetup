 <p align="center">
  <pre>
                          _                          
   /\         _          | |         _               
  /  \  _   _| |_  ___    \ \   ____| |_ _   _ ____  
 / /\ \| | | |  _)/ _ \    \ \ / _  )  _) | | |  _ \ 
| |__| | |_| | |_| |_| |____) | (/ /| |_| |_| | | | |
|______|\____|\___)___(______/ \____)\___)____| ||_/ 
                                              |_|                                                                      
  </pre>
</p>



AutoSetup ist ein Bash-Skript zur automatisierten Installation, Konfiguration und Verwaltung eines Basissystems. Es unterstützt die Einrichtung von Apache, MySQL, PHP und verschiedenen Systemdiensten, um eine grundlegende Serverumgebung bereitzustellen.
![{85D12853-8F7E-4506-A838-C55B9467DFCE}](https://github.com/user-attachments/assets/a740494a-d648-4a40-a9bb-f327303041f6)

## Funktionen

- **Automatische Installation und Aktualisierung**: Installiert und aktualisiert definierte Pakete (Apache, PHP, MySQL und andere nützliche Tools).
- **Konfiguration von Apache, MySQL und PHP**: Konfiguriert die jeweiligen Dienste gemäß vordefinierten Konfigurationsdateien.
- **Systemverwaltung**: Führt Systemkonfigurationen durch, z.B. Einrichtung von Cron-Jobs und Anpassung von Systemverzeichnissen.
- **Grafische Benutzeroberfläche (Dialog)**: Bietet eine einfache Menü-basierte Benutzeroberfläche für die Auswahl von Aktionen wie Installation, Aktualisierung oder Neukonfiguration des Systems.

## Voraussetzungen

- **Betriebssystem**: Linux (getestet unter Debian-basierten Distributionen wie Ubuntu und Kali)
- **Root-Rechte**: Das Skript muss mit Root-Rechten ausgeführt werden

## Installation

1. Klone dieses Repository:
   ```bash
   git clone https://github.com/dein-benutzername/sysdeploy.git
   cd sysdeploy
