source /pkgscripts/include/pkg_util.sh
package="BasicBackup"
displayname="Basic Backup"
displayname_enu="Basic Backup"
displayname_ger="Basic Backup"
version="0.7-035"
firmware="7.0-40000"
os_min_ver="7.0-40000"
support_center="no"
thirdparty="yes"
reloadui="yes"
arch="noarch"
dsmuidir="ui"
ctl_stop="yes"
startable="yes"
silent_install="no"
silent_upgrade="yes"
silent_uninstall="no"
package_icon="PACKAGE_ICON.PNG"
package_icon_256="PACKAGE_ICON_256.PNG"
dsmappname="SYNO.SDS._ThirdParty.App.BasicBackup"
maintainer="Tommes"
description="Basic Backup enables GUI-supported, file-based data backup based on rsync, as well as version backup according to the generation principle using hard links. Possible backup sources and destinations are internal volumes and USB/SATA data carriers connected externally to a DiskStation, as well as rsync-capable remote servers connected via SSH. Via the integrated USB/SATA AutoPilot function, both backup jobs and other Bash scripts can be executed automatically when an external USB/SATA data carrier is connected and, if necessary, automatically ejected again afterwards."
description_enu="Basic Backup enables GUI-supported, file-based data backup based on rsync, as well as version backup according to the generation principle using hard links. Possible backup sources and destinations are internal volumes and USB/SATA data carriers connected externally to a DiskStation, as well as rsync-capable remote servers connected via SSH. Via the integrated USB/SATA AutoPilot function, both backup jobs and other Bash scripts can be executed automatically when an external USB/SATA data carrier is connected and, if necessary, automatically ejected again afterwards."
description_ger="Basic Backup ermöglicht eine GUI gestützte, dateibasierte Datensicherung auf Grundlage von rsync, sowie ein Versionsbackup nach dem Generationenprinzip unter Verwendung von Hardlinks. Mögliche Datensicherungsquellen sowie Ziele sind neben internen Volumes und extern an eine DiskStation angeschlossene USB/SATA-Datenträger, auch über SSH verbundene, rsync fähige Remote Server. Über die integrierte USB/SATA-AutoPilot Funktion können sowohl Datensicherungsaufträge als auch sonstige Bash-Scripte automatisch beim Anschluss eines externen USB/SATA-Datenträgers ausgeführt und bei Bedarf im Anschluss wieder automatisch ausgeworfen werden."
helpurl="https://www.synology-forum.de/threads/basic-backup.117455/"
[ "$(caller)" != "0 NULL" ] && return 0
pkg_dump_info
