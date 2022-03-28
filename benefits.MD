
| Feature |	Basic_Backup	| Hyper_Backup |
| ------------- | ------------- | ------------------- |
| **Allgemein** | 
| Gesicherte Daten lassen sich über die GUI komfortabel wiederherstellen	| :x: | ✔️ |
| Diverse Paketeinstellungen lassen sich über die GUI komfortabel sichern und wiederherstellen	 | :x: | ✔️ |
| Speichern eines Versionsbackups (ggf. erschlüsselt) in eine Datenbankdatei | :x: | ✔️ |
| Speichern eines Versionsbackup (unverschlüsselt) in Dateiform mittels Hardlinks | ✔️ | :x: |
| Anfertigen eines detaillierten Datensicherungsprotokolls | ✔️ | :x: |
| Optische- und/oder Akustische Signalausgabe über die LED’s bzw. den Lautsprecher des Synology NAS | ✔️ | :x: |
| **USB/SATA-Datenträger** |
| Ein angeschlossener USB/SATA-Datenträger kann als Datensicherungsziel ausgewählt werden | ✔️ | ✔️ |
| Es lassen sich Datensicherungsquellen von einem USB/SATA-Datenträger auswählen. | ✔️ | :x: |
| Es kann eine lokale Datensicherung von einem USB/SATA-Datenträger auf einen weiteren USB/SATA-Datenträger ausgeführt werden | ✔️ | :x: |
| Automatisches Ausführen eines Datensicherungsauftrages nach einstecken eines USB-/SATA-Datenträgers sowie ein abschließendes auswerfen des Datenträgers nach Beendigung der Datensicherung | ✔️ | :x: |
| **Remote Server** | |
| Lokal ausgewählte Datensicherungsquellen lassen sich auf einen Remote Server sichern. (Push Backup) | ✔️ | ✔️ |
| Datensicherungsquellen, die sich auf einem Remote Server befinden, lassen sich auf das lokale Synology NAS sichern. (Pull Backup) | ✔️ | :x: |
| Aufwecken eines Remote Servers vor Beginn der Datensicherung (Wake on LAN) | ✔️ | :x: |
| Herunterfahren eines Remote Servers nach Beendigung der Datensicherung (shutdown) | ✔️ | :x: |
| Angehängte freigegebene Remote Ordner können als Datensicherungsquelle oder -ziel ausgewählt werden.| ✔️ | :x: |

**Anmerkung I:**
Das Sichern von USB/SATA-Datenträgern kann evtl. fehlerbehaftet sein, da sich der Mountpoint des Gerätes ziwschenzeitlich ändern kann. Wird ein USB/SATA-Datenträger als Datensicherungsziel angegeben, so kann dieser mittels seiner UUID anstatt seines Mountpoints identifiziert werden. Der Mountpoint wird ggf. intern umgeleitet.

**Anmerkung II:**
Das Sichern von bzw. auf angehängte, freigegebenen Remote Ordner ist ebenfalls fehlerbehaftet, da rsync hier u.U. Probleme bei der Delta-Kodierung bzw. Differenzspeicherung bekommen kann.
