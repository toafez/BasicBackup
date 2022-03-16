#!/bin/sh
# Filename: kickme_into_group.sh - coded in utf-8
# call: /usr/syno/synoman/webman/3rdparty/BasicBackup/app_permissions.sh


#						 Basic Backup
#
#        Copyright (C) 2022 by Tommes | License GNU GPLv3
#         Member of the German Synology Community Forum
#
# Extract from  GPL3   https://www.gnu.org/licenses/gpl-3.0.html
#                                     ...
# This program is free software: you can redistribute it  and/or
# modify it under the terms of the GNU General Public License as
# published by the Free Software Foundation, either version 3 of
# the License, or (at your option) any later version.
#
# This program is distributed in the hope that it will be useful
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
#
# See the GNU General Public License for more details.You should
# have received a copy of the GNU General Public  License  along
# with this program. If not, see http://www.gnu.org/licenses/  !

app="BasicBackup"

# Set App permissions
# ---------------------------------------------------------------------

	# Prüfe ob Version min. DSM 7 entspricht
	# -----------------------------------------------------------------
	if [ $(synogetkeyvalue /etc.defaults/VERSION majorversion) -ge 7 ]; then

		if [ -z "${1}" ]; then

			# Füge den Benutzer BasicBackup der Gruppe administrators hinzu
			# ---------------------------------------------------------------------
			if ! cat /etc/group | grep ^administrators | grep -q BasicBackup ; then
				sed -i "/^administrators:/ s/$/,BasicBackup/" /etc/group
			fi

			# Gib eine DSM-Benachrichtung über Erfolg bzw. Misserfolg aus
			# ---------------------------------------------------------------------
			if cat /etc/group | grep ^administrators | grep -q BasicBackup ; then
				synodsmnotify -c SYNO.SDS._ThirdParty.App."${app}" @administrators "${app}":app:title "${app}":app:permissions_true
			else
				synodsmnotify -c SYNO.SDS._ThirdParty.App."${app}" @administrators "${app}":app:title "${app}":app:permissions_false
			fi
		fi

		if [ -n "${1}" ]; then

			# autopilot einschalten
			# ---------------------------------------------------------------------
			if [[ "${1}" == "autopilot start" ]] && [ ! -f /usr/lib/udev/rules.d/99-autopilot.rules ]; then
				cp /var/packages/BasicBackup/target/ui/modules/autopilot.rules /usr/lib/udev/rules.d/99-autopilot.rules
				chmod 644 /usr/lib/udev/rules.d/99-autopilot.rules
				/usr/bin/udevadm control --reload-rules

				synodsmnotify -c SYNO.SDS._ThirdParty.App."${app}" @administrators "${app}":app:subtitle "${app}":app:autopilot_enabled
			fi

			# autopilot ausschalten
			# ---------------------------------------------------------------------
			if [[ "${1}" == "autopilot stop" ]] && [ -f /usr/lib/udev/rules.d/99-autopilot.rules ]; then
				rm -f /usr/lib/udev/rules.d/99-autopilot.rules
				/usr/bin/udevadm control --reload-rules

				synodsmnotify -c SYNO.SDS._ThirdParty.App."${app}" @administrators "${app}":app:subtitle "${app}":app:autopilot_disabled
			fi
		fi

	fi
