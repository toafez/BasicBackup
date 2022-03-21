
# ![Package icon](/package/ui/images/icon_24.png) Basic Backup - Paket für Synology NAS (DSM 7)
Basic Backup ermöglicht eine GUI gestützte, dateibasierte Datensicherung auf Grundlage von rsync, sowie ein Versionsbackup nach dem Generationenprinzip unter Verwendung von Hardlinks. Mögliche Datensicherungsquellen sowie Ziele sind neben internen Volumes und extern an eine DiskStation angeschlossene USB/SATA-Datenträger, auch über SSH verbundene, rsync fähige Remote Server. Über die integrierte USB/SATA-AutoPilot Funktion können sowohl Datensicherungsaufträge als auch sonstige Bash-Scripte automatisch beim Anschluss eines externen USB/SATA-Datenträgers ausgeführt und bei Bedarf im Anschluss wieder automatisch ausgeworfen werden.

# Systemvoraussetzungen
**Basic Backup** wurde speziell für die Verwendung auf **Synology NAS Systemen** entwickelt die das Betriebsystem **DiskStation Mangager 7** verwenden.

# Installationshinweise
Laden Sie sich die **jeweils aktuellste Version** von Basic Backup aus dem Bereich [Releases](https://github.com/toafez/BasicBackup/releases) herunter. Öffnen Sie anschließend im **DiskStation Manager (DSM)** das **Paket-Zentrum**, wählen oben rechts die Schaltfläche **Manuelle Installation** aus und folgen dem **Assistenten**, um das neue **Paket** bzw. die entsprechende **.spk-Datei** hochzuladen und zu installieren. Dieser Vorgang ist sowohl für eine Erstinstallation als auch für die Durchführung eines Updates identisch. 

**Nach dem Start** von BasicBackup wird die lokal **installierte Version** mit der auf GitHub **verfügbaren Version** verglichen. Steht ein Update zur Verfügung, wird der Benutzer über die App darüber **informiert** und es wird ein entsprechender **Link** zu dem ensprechenden Release eingeblendet. Der Download sowie der anschließende Updatevorgang wurde bereits weiter oben erläutert. 

  - ## Rsync-Dienst aktivieren
    Aktivieren Sie im Vorfeld bitte den **rsync-Dienst**. Zum aktivieren des rsync Dienstes gehen Sie zu **DSM-Hauptmenü** > **Systemsteuerung** > **Dateidienste** und wechseln dort in den Reiter > **rsync**. Aktiveren Sie die Checkbox **rsync Dienst aktivieren**. Als **SSH-Verschlüsselungsport** wird standardmäßig der **Port 22** verwendet, welchen Sie bei Bedarf anpassen können.
    
  - ## SSH Terminal-Dienst aktivieren (falls benötigt)
    Aktivieren Sie im Vorfeld bitte auf Ihrer lokalen DiskStation als auch auf der Remote DiskStation den **SSH Terminal-Dienst**. Zum aktivieren des SSH Terminal-Dienstes gehen Sie zu **DSM-Hauptmenü** > **Systemsteuerung** > **Terminal & SNMP** und wechseln dort in den Reiter > **Terminal**. Aktiveren Sie die Checkbox **SSH-Dienst aktivieren**. Sollte es sich bei dem verwendeten **Remote Server** um ein anderes Gerät als eine Synology DiskStation handeln, stellen Sie bitte im Vorfeld sicher, das der **SSH-Dienst** aktiviert wurde.
   
  - ## Benutzer-Home-Dienst aktivieren (falls SSH-Dienst aktiviert wurde)
    Aktivieren Sie im Vorfeld bitte außerdem den **Benutzer-Home-Dienst**, da die benötigten SSH-Verbindungsdaten im entsprechenden Benutzer-Home-Ordner des angemeldeten SSH-Benutzers abgelegt werden. Zum aktivieren des Benutzer-Home-Dienstes gehen Sie zu **DSM-Hauptmenü** > **Systemsteuerung** > **Benutzer und Gruppe** und wechseln dort in den Reiter > **Erweitert**. Aktiveren Sie unter dem Menüpunkt **Benutzerbasis** die Checkbox **Benutzer-Home-Dienst aktiveren**. Sollte es sich bei dem verwendeten **Remote Server** um ein anderes Gerät als eine Synology DiskStation handeln, stellen Sie bitte im Vorfeld sicher, das ein entsprechender Benutzer-Home-Dienst aktivert wurde.

  - ## App-Berechtigung erweitern
    Unter DSM 7 wird eine 3rd_Party Anwendung wie Basic Backup (im folgenden App genannt) mit stark eingeschränkten Benutzer- und Gruppenrechten ausgestattet. Dies hat u.a. zur Folge, das systemnahe Befehle nicht ausgeführt werden können. Für den reibungslosen Betrieb von Basic Backup werden jedoch erweiterte Systemrechte benötigt um z.B. auf die Ordnerstuktur der "freigegebenen Ordner" zugreifen zu können. Zum erweitern der App-Berechtigungen muss Basic Backup in die Gruppe der Administratoren aufgenommen werden, was jedoch nur durch den Benutzer selbst durchgeführt werden kann. Die nachfolgende Anleitung beschreibt diesen Vorgang.

    - ### Erweitern der App-Berechtigungen über die Konsole

      - Melden Sie sich als Benutzer **root** auf der Konsole Ihrer DiskStation an.
      - Befehl zum erweitern der App-Berechtigungen

        `/usr/syno/synoman/webman/3rdparty/BasicBackup/app_permissions.sh`
 
    - ### Erweitern der App-Berechtigungen über den Aufgabenplaner

      - Im **DSM** unter **Hauptmenü** > **Systemsteuerung** den **Aufgabenplaner** öffnen.
      - Im **Aufgabenplaner** über die Schaltfläche **Erstellen** > **Geplante Aufgabe** > **Benutzerdefiniertes Script** auswählen.
      - In dem nun geöffneten Pop-up-Fenster im Reiter **Allgemein** > **Allgemeine Einstellungen** der Aufgabe einen Namen geben und als Benutzer: **root** auswählen. Außerdem den Haken bei Aktiviert entfernen.
      - Im Reiter **Aufgabeneinstellungen** > **Befehl ausführen** > **Benutzerdefiniertes Script** nachfolgenden Befehl in das Textfeld einfügen...
      - Befehl zum erweitern der App-Berechtigungen

        `/usr/syno/synoman/webman/3rdparty/BasicBackup/app_permissions.sh`
   
      - Eingaben mit **OK** speichern und die anschließende Warnmeldung ebenfalls mit **OK** bestätigen.
      - Die grade erstellte Aufgabe in der Übersicht des Aufgabenplaners markieren, jedoch **nicht** aktivieren (die Zeile sollte nach dem markieren blau hinterlegt sein).
      - Führen Sie die Aufgabe durch Betätigen Sie Schaltfläche **Ausführen** einmalig aus.

  - ## USB/SATA-AutoPilot Funktion aktivieren/deaktivieren
    Über die integrierte USB/SATA-AutoPilot Funktion können sowohl Datensicherungsaufträge als auch sonstige Bash-Scripte automatisch beim Anschluss eines externen USB/SATA-Datenträgers ausgeführt und bei Bedarf im Anschluss wieder automatisch ausgeworfen werden. Damit das funktioniert, muss eine so genannte UDEF-Regel an das System übergeben werden. Dieser Schritt kann jedoch nur durch den Benutzer selbst durchgeführt werden kann. Die nachfolgende Anleitung beschreibt diesen Vorgang.
    
    - ### USB/SATA-AutoPilot über die Konsole aktivieren/deaktivieren

      - Melden Sie sich als Benutzer **root** auf der Konsole Ihrer DiskStation an.
      - Befehl zum **Aktivieren** der USB/SATA-AutoPilot Funktion

        `/usr/syno/synoman/webman/3rdparty/BasicBackup/app_permissions.sh "autopilot start"`

      - Befehl zum **Deaktivieren** der USB/SATA-AutoPilot Funktion

        `/usr/syno/synoman/webman/3rdparty/BasicBackup/app_permissions.sh "autopilot stop"`

    - ### USB/SATA-AutoPilot über den Aufgabenplaner aktivieren/deaktivieren
      - Im **DSM** unter **Hauptmenü** > **Systemsteuerung** den **Aufgabenplaner** öffnen.
      - Im **Aufgabenplaner** über die Schaltfläche **Erstellen** > **Geplante Aufgabe** > **Benutzerdefiniertes Script** auswählen.
      - In dem nun geöffneten Pop-up-Fenster im Reiter **Allgemein** > **Allgemeine Einstellungen** der Aufgabe einen Namen geben und als Benutzer: **root** auswählen. Außerdem den Haken bei Aktiviert entfernen.
      - Im Reiter **Aufgabeneinstellungen** > **Befehl ausführen** > **Benutzerdefiniertes Script** nachfolgenden Befehl in das Textfeld einfügen...
      - Befehl zum **Aktivieren** der USB/SATA-AutoPilot Funktion

        `/usr/syno/synoman/webman/3rdparty/BasicBackup/app_permissions.sh "autopilot start"`

      - Befehl zum **Deaktivieren** der USB/SATA-AutoPilot Funktion

        `/usr/syno/synoman/webman/3rdparty/BasicBackup/app_permissions.sh "autopilot stop"`
   
      - Eingaben mit **OK** speichern und die anschließende Warnmeldung ebenfalls mit **OK** bestätigen.
      - Die grade erstellte Aufgabe in der Übersicht des Aufgabenplaners markieren, jedoch **nicht** aktivieren (die Zeile sollte nach dem markieren blau hinterlegt sein).
      - Führen Sie die Aufgabe durch Betätigen Sie Schaltfläche **Ausführen** einmalig aus.
      
  - ## Einen externen Datenträger für USB/SATA-AutoPilot einrichten
    - ### Einrichtung über den DSM 
      - Installieren Sie über das **DSM Paket-Zentrum** das von Synology angebotene Paket **Text-Editor**.
      - Starten Sie den **Text-Editor** und erstellen Sie über die Schaltfläche **Datei** > **Neu** eine neue Textdatei.
      - Möchten Sie beim Einstecken des externen Datenträgers gerne ein Basic Backup Auftrag ausführen, dann fügen Sie den nachfolgenden Inhalt ein, wobei Sie **TASKNAME** durch den von Ihnen gewünschten **Auftragsnamen** ersetzen. Beispiel:
      
        ```
        #!/bin/bash
        bash /usr/syno/synoman/webman/3rdparty/BasicBackup/rsync.sh --job-name="TASKNAME"
        ```
        
      - Speichern Sie anschließend die grade erstellet Textdatei über die Schaltfläche **Datei** > **Speichern unter...** wählen als Speicherort das **root Verzeichnis** des gewünschten externen Datenträgers an wie z.B. **/usbshare** und geben als Dateiname **autopilot** ohne Dateiendung an. Bestätigen Sie Ihre Eingaben durch drücken der Schaltfläche **Speichern**.
      - Werfen Sie den externen Datenträger über den DSM aus. Beim nächsten anstecken des externen Datenträgers wird der Inhalt der grade erstellten Scriptdatei ausgeführt.

# Versionsgeschichte
- Details zur Versionsgeschichte finden Sie in der Datei [CHANGELOG](CHANGELOG).

# Entwickler-Information
- Details zum Backend entnehmen Sie bitte dem [Synology DSM 7.0 Developer Guide](https://help.synology.com/developer-guide/)
- Details zum Frontend entnehmen Sie bitte dem [Bootstrap Framework](https://getbootstrap.com/)
- Details zu jQuery entnehmen Sie bitte der [jQuery API](https://api.jquery.com/)

# Hilfe und Diskussion
- Hilfe und Diskussion gerne über [Das deutsche Synology Support Forum](https://www.synology-forum.de/threads/basic-backup.117455/) oder über [heimnetz.de](https://forum.heimnetz.de/threads/basic-backup-3rdparty-app-fuer-synology-nas-dsm-7.485/)

# Lizenz
Dieses Programm ist freie Software. Sie können es unter den Bedingungen der **GNU General Public License**, wie von der Free Software Foundation veröffentlicht, weitergeben und/oder modifizieren, entweder gemäß **Version 3** der Lizenz oder (nach Ihrer Option) jeder späteren Version.

Die Veröffentlichung dieses Programms erfolgt in der Hoffnung, daß es Ihnen von Nutzen sein wird, aber **OHNE IRGENDEINE GARANTIE**, sogar **ohne die implizite Garantie der MARKTREIFE oder der VERWENDBARKEIT FÜR EINEN BESTIMMTEN ZWECK**. Details finden Sie in der Datei [GNU General Public License](LICENSE).