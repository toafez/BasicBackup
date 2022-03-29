
## Unterschiede von Basic Backup im Vergleich zu Hyper Backup

| Feature |	Basic&nbsp;Backup	| Hyper&nbsp;Backup |
| --- | :---: | :---: |
| **Sicherungen und Sicherungsversionen** |
| Gesicherte Daten werden unverschlüsselt direkt ins Dateisystem gespeichert | 🟢 | 🟢 |
| Gesicherte Daten werden in Synologys Datensicherungsformat (.hbk) ggf. verschlüsselt gespeichert | 🔴 | 🟢 |
| Sicherungsversionen werden unverschlüsselt direkt ins Dateisystem unter Verwendung von Hardlinks gespeichert | 🟢 | 🔴 |
| Sicherungsversionen werden in Synologys Datensicherungsformat (.hbk) ggf. verschlüsselt gespeichert | 🔴 | 🟢 |
| **Wiederherstellung** |
| Die Wiederherstellung gesicherter Daten wird unterstützt	| 🔴 | 🟢 |
| Das Sichern und Wiederherstellen bestimmter Anwendungen (Pakete) wird unterstützt	 | 🔴 | 🟢 |
| **USB/SATA-Datenträger** |
| Ein angeschlossener USB/SATA-Datenträger kann als Datensicherungsziel ausgewählt werden | 🟢 | 🟢 |
| Es lassen sich Datensicherungsquellen von einem USB/SATA-Datenträger auswählen | 🟢 | 🔴 |
| Es kann eine lokale Datensicherung von einem USB/SATA-Datenträger auf einen weiteren USB/SATA-Datenträger ausgeführt werden | 🟢 | 🔴 |
| Automatisches Ausführen eines Datensicherungsauftrages nach einstecken eines USB-/SATA-Datenträgers sowie ein abschließendes auswerfen des Datenträgers nach Beendigung der Datensicherung | 🟢 | 🔴 |
| **Remote Server** |
| Lokale Datensicherungsquellen des Synology NAS lassen sich auf einen Remote Server sichern (Push Backup) | 🟢 | 🟢 |
| Remote Datensicherungsquellen lassen sich auf das lokale Synology NAS sichern (Pull Backup) | 🟢 | 🔴 |
| Aufwecken eines Remote Servers vor Beginn der Datensicherung (Wake on LAN) | 🟢 | 🔴 |
| Herunterfahren eines Remote Servers nach Beendigung der Datensicherung (shutdown) | 🟢 | 🔴 |
| Angehängte freigegebene Remote Ordner können als Datensicherungsquelle oder -Ziel ausgewählt werden.| 🟢 | 🔴 |
| **Sonstiges** |
| Anfertigen eines detaillierten Datensicherungsprotokolls | 🟢 | 🔴 |
| Optische- und/oder Akustische Signalausgabe über die LED’s bzw. den Lautsprecher des Synology NAS | 🟢 | 🔴 |

**Anmerkung I:**
Das Sichern von USB/SATA-Datenträgern kann evtl. fehlerbehaftet sein, da sich der Mountpoint des Gerätes ziwschenzeitlich ändern kann. Wird ein USB/SATA-Datenträger als Datensicherungsziel angegeben, so kann dieser mittels seiner UUID anstatt seines Mountpoints identifiziert werden. Der Mountpoint wird ggf. intern umgeleitet.

**Anmerkung II:**
Das Sichern von bzw. auf angehängte, freigegebenen Remote Ordner ist ebenfalls fehlerbehaftet, da rsync hier u.U. Probleme bei der Delta-Kodierung bzw. Differenzspeicherung bekommen kann.
