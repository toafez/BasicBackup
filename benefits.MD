
## Unterschiede zwischen Basic Backup und Hyper Backup

| Feature |	Basic&nbsp;Backup	| Hyper&nbsp;Backup |
| --- | :---: | :---: |
| **Datensicherung** |
| Gesicherte Daten werden unverschlüsselt direkt ins Dateisystem gespeichert | 🟢 | 🟢 |
| Gesicherte Daten werden in Synologys Datensicherungsformat (.hbk) ggf. verschlüsselt gespeichert | 🔴 | 🟢 |
| **Datensicherungsversionen** |
| Sicherungsversionen werden unverschlüsselt direkt ins Dateisystem unter Verwendung von Hardlinks gespeichert | 🟢 | 🔴 |
| Sicherungsversionen werden in Synologys Datensicherungsformat (.hbk) ggf. verschlüsselt gespeichert | 🔴 | 🟢 |
| **Wiederherstellung** |
| Die Wiederherstellung gesicherter Daten wird unterstützt	| 🔴 | 🟢 |
| Das Sichern und Wiederherstellen bestimmter Anwendungen (Pakete) wird unterstützt	 | 🔴 | 🟢 |
| **Nutzung von extern angeschlossenen USB/SATA-Datenträgern** |
| Ein externer Datenträger kann als Datensicherungsziel ausgewählt werden | 🟢 | 🟢 |
| Es lassen sich Datensicherungsquellen von einem externen Datenträger auswählen<br />***Anmerkung:** Das Sichern von externen Datenträgern kann evtl. fehlerbehaftet sein, da sich der Mountpoint des Gerätes ziwschenzeitlich ändern kann. Wird ein externer Datenträger als Datensicherungsziel angegeben, so kann dieser mittels seiner UUID anstatt seines Mountpoints identifiziert werden. Der Mountpoint wird in diesem Falle ggf. intern umgeleitet.* | 🟢 | 🔴 |
| Es kann eine lokale Datensicherung von einem externen Datenträger auf einen weiteren externen Datenträger erfolgen | 🟢 | 🔴 |
| Automatisches Ausführen eines Datensicherungsauftrages nach einstecken eines externen Datenträgers sowie ein abschließendes auswerfen des Datenträgers nach Beendigung der Datensicherung | 🟢 | 🔴 |
| **Nutzung von Remote Servern im LAN oder über das Internet** |
| Lokale Datensicherungsquellen des Synology NAS lassen sich auf einen Remote Server sichern (Push Backup) | 🟢 | 🟢 |
| Remote Datensicherungsquellen lassen sich auf das lokale Synology NAS sichern (Pull Backup) | 🟢 | 🔴 |
| Aufwecken eines Remote Servers vor Beginn der Datensicherung (Wake on LAN) | 🟢 | 🔴 |
| Herunterfahren eines Remote Servers nach Beendigung der Datensicherung (shutdown) | 🟢 | 🔴 |
| Über die File Station angehängte, freigegebene Remote Ordner können als Datensicherungsquelle oder -Ziel ausgewählt werden<br />***Anmerkung:** Das Sichern von bzw. auf angehängte, freigegebenen Remote Ordner kann evtl. fehlerbehaftet sein, da rsync hier u.U. Probleme bei der Delta-Kodierung bzw. der Differenzspeicherung bekommen kann.*| 🟢 | 🔴 |
| **Sonstiges** |
| Anfertigen eines detaillierten Datensicherungsprotokolls | 🟢 | 🔴 |
| Optische- und/oder Akustische Signalausgabe über die LED’s bzw. den Lautsprecher des Synology NAS | 🟢 | 🔴 |

