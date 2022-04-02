# Vor- und Nachteile von Basic Backup
Auf einem Synology NAS System übernimmt in der Regel Hyper Backup die umfassende Sicherung von freigegebenen Ordnern, Paketen und LUNs. Basic Backup versteht sich daher als alternative - oder auch ergänzende - Backup Software, welche sich jedoch im Funktionsumfang und in der Arbeitsweise mehr oder weniger stark von Hyper Backup unterscheidet. Die wesentlichen Unterschiede und damit verbunden, die Vor- und Nachteile beider Systeme werden in der nachstehenden Tabelle zusammengefasst.  

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
| Ein externer Datenträger kann als Datensicherungsziel ausgewählt werden<br />***Anmerkung:** Wird unter Verwendung von Basic Backup ein externer Datenträger als Datensicherungsziel angegeben, so kann dieser mittels seiner UUID anstatt seines Mountpoints identifiziert werden. Der Mountpoint wird in diesem Falle ggf. intern an das richtige Gerät umgeleitet.* | 🟢 | 🟢 |
| Es lassen sich Datensicherungsquellen von einem externen Datenträger auswählen<br />***Anmerkung:** Das Sichern von externen Datenträgern kann evtl. fehlerbehaftet sein, da sich der Mountpoint des Gerätes ziwschenzeitlich ändern kann. Eine Anpassung des Mountpoints durch Ermittlung der UUID ist in diesem Fall nicht vorgesehen.* | 🟢 | 🔴 |
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

