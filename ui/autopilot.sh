#!/bin/bash
# Filename: autopilot.sh - coded in utf-8

#						 Basic Backup
#
#        Copyright (C) 2023 by Tommes | License GNU GPLv3
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

# --------------------------------------------------------------
# Define Enviroment
# --------------------------------------------------------------
	PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/syno/bin:/usr/syno/sbin
	app="BasicBackup"
	dir="$(echo `dirname ${0}`)"
	scriptname="autopilot"
	logpath="${dir}/usersettings/logfiles"
	logfile="${scriptname}.log"

	# Create logfile
	# ----------------------------------------------------------
	if [ ! -d "${logpath}" ]; then
		mkdir -p -m 0777 "${logpath}"
	fi
	if [ -d "${logpath}" ]; then
		if [ ! -f "${logpath}/${logfile}" ]; then
			touch "${logpath}/${logfile}"
			chmod 0777 "${logpath}/${logfile}"
			chown "${app}":"${app}" "${logpath}/${logfile}"
		fi
	fi
	log="${logpath}/${logfile}"

	# Load configuration settings
	# ----------------------------------------------------------
	[ -f "${dir}/usersettings/system/${scriptname}.config" ] && source "${dir}/usersettings/system/${scriptname}.config"

	# Load language settings
	# ----------------------------------------------------------
	[ -f "${dir}/modules/parse_language.sh" ] && source "${dir}/modules/parse_language.sh" || exit
	language "PILOT"

	# Set timestamp
	# ----------------------------------------------------------
	function timestamp()
	{
		date +"%Y-%m-%d %H:%M:%S"
	}

	# Optical and acoustic signal output
	# ----------------------------------------------------------
	function signal_start()
	{
		# Short beep
		echo 2 > /dev/ttyS1
		# Status LED orange on
		echo : > /dev/ttyS1
	}

	function signal_stop()
	{
		# Short beep
		echo 2 > /dev/ttyS1
		# Status LED green on
		echo 8 > /dev/ttyS1
	}

	function signal_warning()
	{
		# Short beep
		echo 2 > /dev/ttyS1
		# Short beep
		echo 2 > /dev/ttyS1
		# Short beep
		echo 2 > /dev/ttyS1
		# Status LED green on
		echo 8 > /dev/ttyS1
	}

	function signal_error()
	{
		# Long beep
		echo 3 > /dev/ttyS1
		exit 1
	}

# --------------------------------------------------------------
# Mount and unmount external devices
# --------------------------------------------------------------
	# ${1} is the passed device name %k from the udev rule
	if [ -z "${1}" ]; then
		echo "$(timestamp) ${txt_device_failed}" >> "${log}"
		echo "# ---" >> "${log}"
		exit 1
	fi

	# Mount (connect) external USB devices
	# ----------------------------------------------------------
	if [[ "${connect}" == "true" ]]; then

		# Searching for mount paths
		counter=0
		mountpoint=""
		while ([ -z "${mountpoint}" ] && [ ${counter} -lt 20 ]); do
			mountpoint=$(mount 2>&1 | grep "/dev/$1" | cut -d ' ' -f3)
			((counter++))
			sleep 2
		done

		# If no mount paths were found
		if [ -z "${mountpoint}" ]; then
			echo "$(timestamp) ${txt_mountpoint_failed}" >> "${log}"
			[[ "${signal}" == "true" ]] && signal_error
		fi

		# When mount paths have been found
		if [ -x "${mountpoint}/${scriptname}" ]; then
			uuid=$(blkid -s UUID -o value ${DEVNAME})
			serialnr=$(cat /proc/sys/kernel/syno_serial)
			echo "$(timestamp) ${txt_device_detected} ${DEVNAME}" >> "${log}"
			echo "$(timestamp) ${DEVNAME} - ${txt_mountpoint_detected} ${mountpoint}" >> "${log}"
			echo "$(timestamp) ${DEVNAME} - ${txt_uuid_detected} ${uuid}" >> "${log}"
			# udevadm info ${DEVNAME} >> "${log}"
			echo "$(timestamp) ${DEVNAME} - ${txt_script} ${mountpoint}/${scriptname} ${txt_script_localized}" >> "${log}"
			echo "$(timestamp) ${DEVNAME} - ${txt_script} ${mountpoint}/${scriptname} ${txt_script_started}" >> "${log}"

			[[ "${signal}" == "true" ]] && signal_start
			synodsmnotify -c SYNO.SDS._ThirdParty.App."${app}" @administrators "${app}":app:subtitle "${app}":app:autopilot_start "${mountpoint}"
			sleep 5
			${mountpoint}/${scriptname}
			exit_script=${?}
			sleep 5
			if [[ ${exit_script} -eq 0 || ${exit_script} -eq 100 ]]; then
				echo "$(timestamp) ${DEVNAME} - ${txt_script} ${mountpoint}/${scriptname} ${txt_script_run_through}" >> "${log}"
			else
				echo "$(timestamp) ${DEVNAME} - ${txt_script_execution} ${mountpoint}/${scriptname} ${txt_script_error_occurred} Exit-Code: ${exit_script}" >> "${log}"
			fi
		else
			if [ -f "${mountpoint}/${scriptname}" ]; then
				echo "$(timestamp) ${DEVNAME} - ${txt_script} ${mountpoint}/${scriptname} ${txt_script_not_executed}" >> "${log}"
				echo "$(timestamp) ${DEVNAME} - ${txt_device_mounted_and_connected}" >> "${log}"
				echo "# ---" >> "${log}"
				[[ "${signal}" == "true" ]] && signal_error
			else
				echo "$(timestamp) ${DEVNAME} - ${txt_script} ${mountpoint}/${scriptname} ${txt_script_not_found}" >> "${log}"
				echo "$(timestamp) ${DEVNAME} - ${txt_device_mounted_and_connected}" >> "${log}"
				echo "# ---" >> "${log}"
				exit
			fi
		fi

		# Unmount (disconnect) external USB devices
		# ------------------------------------------------------
		if [[ "${disconnect}" == "auto" ]] || [[ "${disconnect}" == "manual" && ${exit_script} -eq 100 ]]; then

			# Unmount external device
			sync
			umount ${mountpoint}
			exit_umount=${?}

			# If the external device has been unmount
			if [[ ${exit_umount} -eq 0 ]]; then
				echo "$(timestamp) ${DEVNAME} - ${txt_device_unmount} ${mountpoint}" >> "${log}"
				eject_mount=$(echo $1 | sed "s/[0-9]//")

				# # Disconnect external device if mount point was found
				if [ -f "/sys/block/${eject_mount}/device/delete" ]; then
					echo 1 > "/sys/block/${eject_mount}/device/delete"
					exit_eject=${?}
					sleep 5

					# If the external device has been disconnected
					if [[ ${exit_eject} -eq 0 ]]; then
						# Remove external USB file system
						rmdir "${mountpoint}"
						exit_rmdir=${?}

						# If the file system has been removed
						if [[ ${exit_rmdir} -eq 0 ]]; then
							echo "$(timestamp) ${txt_device_ejected} (${DEVNAME})" >> "${log}"
							if [[ ${exit_script} -eq 0 || ${exit_script} -eq 100 ]]; then
								[[ "${signal}" == "true" ]] && signal_stop
								synodsmnotify -c SYNO.SDS._ThirdParty.App."${app}" @administrators "${app}":app:subtitle "${app}":app:autopilot_stop_a "${mountpoint}"
							else
								[[ "${signal}" == "true" ]] && signal_warning
								synodsmnotify -c SYNO.SDS._ThirdParty.App."${app}" @administrators "${app}":app:subtitle "${app}":app:autopilot_stop_b "${mountpoint}"
							fi
						else
							echo "$(timestamp) ${txt_device_not_ejected} (${DEVNAME}). Exit-Code: ${exit_rmdir}" >> "${log}"
							[[ "${signal}" == "true" ]] && signal_warning
							if [[ ${exit_script} -eq 0 || ${exit_script} -eq 100 ]]; then
								synodsmnotify -c SYNO.SDS._ThirdParty.App."${app}" @administrators "${app}":app:subtitle "${app}":app:autopilot_alert_a "${mountpoint}"
							else
								synodsmnotify -c SYNO.SDS._ThirdParty.App."${app}" @administrators "${app}":app:subtitle "${app}":app:autopilot_alert_b "${mountpoint}"
							fi
						fi
					else
						echo "$(timestamp) ${txt_device_only_unmount} (${DEVNAME}) Exit-Code: eject ${exit_eject}" >> "${log}"
						[[ "${signal}" == "true" ]] && signal_warning
						if [[ ${exit_script} -eq 0 || ${exit_script} -eq 100 ]]; then
							synodsmnotify -c SYNO.SDS._ThirdParty.App."${app}" @administrators "${app}":app:subtitle "${app}":app:autopilot_alert_a "${mountpoint}"
						else
							synodsmnotify -c SYNO.SDS._ThirdParty.App."${app}" @administrators "${app}":app:subtitle "${app}":app:autopilot_alert_b "${mountpoint}"
						fi
					fi
				else
					echo "$(timestamp) ${txt_device_not_found} (${DEVNAME})" >> "${log}"
					[[ "${signal}" == "true" ]] && signal_warning
					if [[ ${exit_script} -eq 0 || ${exit_script} -eq 100 ]]; then
						synodsmnotify -c SYNO.SDS._ThirdParty.App."${app}" @administrators "${app}":app:subtitle "${app}":app:autopilot_alert_a "${mountpoint}"
					else
						synodsmnotify -c SYNO.SDS._ThirdParty.App."${app}" @administrators "${app}":app:subtitle "${app}":app:autopilot_alert_b "${mountpoint}"
					fi
				fi
			else
				echo "$(timestamp) ${txt_device_not_unmount_ejected} (${DEVNAME}). Exit-Code: umount ${exit_umount}" >> "${log}"
				[[ "${signal}" == "true" ]] && signal_warning
				if [[ ${exit_script} -eq 0 || ${exit_script} -eq 100 ]]; then
					synodsmnotify -c SYNO.SDS._ThirdParty.App."${app}" @administrators "${app}":app:subtitle "${app}":app:autopilot_alert_a "${mountpoint}"
				else
					synodsmnotify -c SYNO.SDS._ThirdParty.App."${app}" @administrators "${app}":app:subtitle "${app}":app:autopilot_alert_b "${mountpoint}"
				fi
			fi
		else
			echo "$(timestamp) ${txt_device_mounted_and_connected} (${DEVNAME})" >> "${log}"
			[[ "${signal}" == "true" ]] && signal_stop
			if [[ ${exit_script} -eq 0 || ${exit_script} -eq 100 ]]; then
				synodsmnotify -c SYNO.SDS._ThirdParty.App."${app}" @administrators "${app}":app:subtitle "${app}":app:autopilot_stop_c "${mountpoint}"
			else
				synodsmnotify -c SYNO.SDS._ThirdParty.App."${app}" @administrators "${app}":app:subtitle "${app}":app:autopilot_stop_d "${mountpoint}"
			fi
		fi
		echo "# ---" >> "${log}"
	fi
