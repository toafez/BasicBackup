#!/bin/bash
# Filename: rsync.sh - coded in utf-8
script_version="0.8-500"

#                       Basic Backup
#
#        Copyright (C) 2024 by Tommes | License GNU GPLv3
#         Member of the German Synology Community Forum
#
# Extract from  GPL3   https://www.gnu.org/licenses/gpl-3.0.html
#							...
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
# bash /var/packages/BasicBackup/target/ui/rsync.sh "RasPi-Push"

# ------------------------------------------------------------------------
# Function: Check if server online (Ping Test)
# ------------------------------------------------------------------------
function ping_server ()
{
	counter=1
	while [ ${counter} -le 2 ]; do
		ping -c 2 -w 2 ${var[${1}]} &>/dev/null
		exit_ping=${?}
		if [[ "${exit_ping}" -eq 0 ]]; then
			counter="5"
		else
			counter=$(expr ${counter} + 1)
		fi
	done
	unset counter

	if [[ "${exit_ping}" -eq 0 ]]; then
		echo "${txt_server_ping_true}" | tee -a "${script_log}"
		is_online="true"
		exit_code=0
	else
		if [[ $(echo "${var[wakeup]}" | grep -E ^[[:digit:]]+$) ]]; then
			echo "${txt_server_ping_wakeup}" | tee -a "${script_log}"
		else
			echo "${txt_server_ping_false}" | tee -a "${script_log}"
			echo "$(timestamp) - [ ${jobname} ] ${txt_server_ping_false}" >> "${system_log}"
			synodsmnotify -c SYNO.SDS."${app}".Application @administrators "${app}":app:title "${app}":app:server_failed
			#exit
		fi
		is_online="false"
		exit_code=1
	fi
	unset exit_ping
}

# ------------------------------------------------------------------------
# Function: Wakeup Remote server
# ------------------------------------------------------------------------
function wakeup_server ()
{
	if [[ "${is_online}" == "false" ]]; then
		if [ -d /proc/sys/net/ipv4/conf/wlan0 ]; then
			if [ -f /opt/bin/etherwake ]; then
				/opt/bin/etherwake -i wlan0 "${var[sshmac]}"
				exit_wakeup=${?}
			elif [ -f /opt/bin/wakelan ]; then
				/opt/bin/wakelan -m "${var[sshmac]}"
				exit_wakeup=${?}
			fi
		elif [ -d /proc/sys/net/ipv4/conf/eth0 ]; then
			if [ -f /usr/bin/ether-wake ]; then
				/usr/bin/ether-wake "${var[sshmac]}"
				exit_wakeup=${?}
			elif [ -f /usr/syno/sbin/synonet ]; then
				/usr/syno/sbin/synonet --wake "${var[sshmac]}" eth0
				exit_wakeup=${?}
			fi
		fi

		if [[ ${exit_wakeup} -eq 0 ]]; then
			echo "${txt_server_wakeup_true}" | tee -a "${script_log}"
			is_awake="true"
			exit_code=0
		else
			echo "${txt_server_wakeup_false}" | tee -a "${script_log}"
			echo "$(timestamp) - [ ${jobname} ] ${txt_server_wakeup_false}" >> "${system_log}"
			synodsmnotify -c SYNO.SDS."${app}".Application @administrators "${app}":app:title "${app}":app:server_failed
			exit_code=1
			#exit
		fi
		unset exit_wakeup
	fi
}

# ------------------------------------------------------------------------
# Function: SSH Establish connection
# ------------------------------------------------------------------------
function connect_server ()
{
	remotehost=$(${ssh} -o StrictHostKeyChecking=no 'hostname' 2> /dev/null)
	if [ -n "${remotehost}" ]; then
		echo "${txt_server_connected}" | tee -a "${script_log}"
		is_connected="true"
		exit_code=0
	else
		echo "${txt_server_disconnected}" | tee -a "${script_log}"
		echo "$(timestamp) - [ ${jobname} ] ${txt_server_disconnected}" >> "${system_log}"
		synodsmnotify -c SYNO.SDS."${app}".Application @administrators "${app}":app:title "${app}":app:server_failed
		exit_code=1
		#exit
	fi
}

# ------------------------------------------------------------------------
# Function: Shutdown Remote server
# ------------------------------------------------------------------------
function shutdown_server ()
{
	if [[ "${is_online}" == "true" ]]; then
		${ssh} "/sbin/shutdown -k -h now"
		if [[ ${?} -eq 0 ]]; then
			echo "${txt_server_shutdown_true}" | tee -a "${script_log}"
			is_shutdown="true"
			exit_code=0
		else
			echo "${txt_server_shutdown_false}" | tee -a "${script_log}"
			echo "$(timestamp) - ${txt_server_shutdown_false}" >> "${system_log}"
			exit_code=1
			#exit
		fi
	fi
}

### Let's beginn...
#
# ------------------------------------------------------------------------
# Define Enviroment
# ------------------------------------------------------------------------
PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/syno/bin:/usr/syno/sbin
app="BasicBackup"
dir="$(echo `dirname ${0}`)"
base="$(echo `basename ${0}`)"
whoami=$(whoami)
localhost=$(hostname)

if [ -z "${backupIFS}" ]; then
	backupIFS="${IFS}"
	readonly backupIFS
	IFS="${backupIFS}"
fi

unset var
exit_code=
# clear

# ------------------------------------------------------------------------
# Ceck that the script run only as root
# ------------------------------------------------------------------------
if [ "${whoami}" != "root" ]; then
	echo "${txt_root_failed}"
	synodsmnotify -c SYNO.SDS."${app}".Application @administrators "${app}":app:title "${app}":app:script_failed
	exit_code=1
	exit
fi

# ------------------------------------------------------------------------
# Loading backup config, rsync options and language file
# ------------------------------------------------------------------------
for i in "$@" ; do
    case $i in
		-j=*|--job-name=*)
		jobname="${i#*=}"
        backupjob="${dir}/usersettings/backupjobs/${jobname}.config"
        if [ -f "${backupjob}" ]; then
			declare -A var
			source "${backupjob}"
			exit_code=0
		else
			synodsmnotify -c SYNO.SDS."${app}".Application @administrators "${app}":app:title "${app}":app:job_failed
			echo "${txt_backupjob_false}"
			exit_code=1
			exit 1
		fi
        ;;
		-n|--dry-run)
        dryrun="--dry-run"
        shift
        ;;
		-v|-vv|-vvv|--verbose)
        verbose="${i#*=}"
		shift
        ;;
		-c=*|--chmod=*)
        perms="--chmod=${i#*=}"
        shift
        ;;
        *)
        echo "Error! Unknown option $i"
		exit
        ;;
    esac
done

# Loading language file
if [ -f "${dir}/modules/parse_language.sh" ]; then
	source "${dir}/modules/parse_language.sh"
	language "RSYNC"
	exit_code=0
else
	echo "${txt_backupjob_false}"
	synodsmnotify -c SYNO.SDS."${app}".Application @administrators "${app}":app:title "${app}":app:job_failed
	exit_code=1
	exit
fi

# Read version of Basic Backup App from INFO file
app_version=$(cat "/var/packages/${app}/INFO" | grep ^version | cut -d '"' -f2)

# ------------------------------------------------------------------------
#  Set timestamp, create log files and output notification
# ------------------------------------------------------------------------
if [[ ${exit_code} -eq 0 ]]; then

	#---------------------------------------------------------------------
	# Set pid file
	#---------------------------------------------------------------------
	touch /var/packages/"${app}"/tmp/pid && chmod 755 $_ && chown "${app}":"${app}" $_
	pid=$(ps -aux | grep -v "grep" | grep -w "${jobname}" | grep -v "rsync --daemon" | awk '{print $2}')
	echo 'pid="'${pid}'"' > /var/packages/"${app}"/tmp/pid
	echo 'job="'${jobname}'"' >> /var/packages/"${app}"/tmp/pid

	#---------------------------------------------------------------------
	# Set timestamp
	#---------------------------------------------------------------------
	timestamp() {
		date +"%Y-%m-%d %H:%M:%S"
	}

	#---------------------------------------------------------------------
	# Create logfiles
	#---------------------------------------------------------------------
	logpath="${dir}/usersettings/logfiles"
	script_log="${logpath}/${jobname}.log"
	system_log="${logpath}/BasicBackup.history"
	email_log="${dir}/temp/email.log"

	if [ ! -d "${logpath}" ]; then
		mkdir -p -m 0777 "${logpath}"
	fi

	if [ -d "${logpath}" ]; then
		if [ -f "${script_log}" ]; then
			rm -f "${script_log}"
		fi
		if [ ! -f "${script_log}" ]; then
			touch "${script_log}"
			chmod 0777 "${script_log}"
		fi
		if [ ! -f "${system_log}" ]; then
			touch "${system_log}"
			chmod 0777 "${system_log}"
		fi
	fi

	#---------------------------------------------------------------------
	# Optical and visual notification that the backup job starts...
	#---------------------------------------------------------------------

	# Notification that backup job starts
	dsm_version=$(synogetkeyvalue /etc.defaults/VERSION productversion)
	dsm_build=$(synogetkeyvalue /etc.defaults/VERSION buildnumber)
	dsm_update=$(synogetkeyvalue /etc.defaults/VERSION nano)
	[[ -n "${dsm_update}" ]] && dsm_update="Update ${dsm_update}" || dsm_update=""
	echo "Basic Backup GUI Version: ${app_version}" | tee -a "${script_log}"
	echo "Basic Backup Job Configuration : ${jobconfig_version}" | tee -a "${script_log}"
	echo "Basic Backup rsync script Version: ${script_version}" | tee -a "${script_log}"
	echo "DiskStation Manager Version: ${dsm_version}-${dsm_build} ${dsm_update}" | tee -a "${script_log}"
	echo "${txt_line_separator}" | tee -a "${script_log}"
	echo "$(timestamp) - ${txt_backupjob_starts}" | tee -a "${script_log}"
	echo "${txt_line_separator}" | tee -a "${script_log}"
	echo "${txt_backupjob_true} [ ${jobname}.config ]" | tee -a "${script_log}"

	# Optical signal control
	if [[ "${var[optical]}" == "true" ]]; then
		# Status LED orange on
		echo : >/dev/ttyS1
	fi

	# Acoustical signal control
	if [[ "${var[acoustical]}" == "true" ]]; then
		# 1x long beep sound
		echo 3 >/dev/ttyS1
	fi
	exit_code=0
fi

# ------------------------------------------------------------------------
# Connection type settings
# ------------------------------------------------------------------------
if [[ ${exit_code} -eq 0 ]]; then

	# Local settings
	if [ -z "${var[sshpush]}" ] && [ -z "${var[sshpull]}" ]; then
		echo "${txt_connectiontype_local}" | tee -a "${script_log}"
		connectiontype="local"
	fi

	# Pull settings
	if [ -z "${var[sshpush]}" ] && [ -n "${var[sshpull]}" ]; then
		echo "${txt_connectiontype_pull}" | tee -a "${script_log}"
		scp="scp -P ${var[sshport]} -i ~/.ssh/${var[privatekey]}"
		ssh="ssh -p ${var[sshport]} -i ~/.ssh/${var[privatekey]} ${var[sshuser]}@${var[sshpull]}"
		#ssh_nokeycheck="ssh -p ${var[sshport]} -o StrictHostKeyChecking=no -i ~/.ssh/${var[privatekey]} ${var[sshuser]}@${var[sshpull]}"
		connectiontype="sshpull"
	fi

	# Push settings
	if [ -n "${var[sshpush]}" ] && [ -z "${var[sshpull]}" ]; then
		echo "${txt_connectiontype_push}" | tee -a "${script_log}"
		scp="scp -P ${var[sshport]} -i ~/.ssh/${var[privatekey]}"
		ssh="ssh -p ${var[sshport]} -i ~/.ssh/${var[privatekey]} ${var[sshuser]}@${var[sshpush]}"
		#ssh_nokeycheck="ssh -p ${var[sshport]} -o StrictHostKeyChecking=no -i ~/.ssh/${var[privatekey]} ${var[sshuser]}@${var[sshpush]}"
		connectiontype="sshpush"
	fi
fi

# ------------------------------------------------------------------------
# Wakeup remote server and/or establish SSH connection
# ------------------------------------------------------------------------
if [[ ${exit_code} -eq 0 ]]; then

	# If the connectiontype is sshpush or sshpull, then ping remote server
	if [[ "${connectiontype}" == "sshpush" ]] || [[ "${connectiontype}" == "sshpull" ]]; then
		ping_server "${connectiontype}"

		# If ping failed, try to wake up the remote server
		if [[ "${is_online}" == "false" ]] && [[ $(echo "${var[wakeup]}" | grep -E ^[[:digit:]]+$) ]]; then
			wakeup_server

			# If remote server was woken up, wait until connection is established
			if [[ "${is_awake}" == "true" ]]; then
				sleep ${var[wakeup]}
				ping_server "${connectiontype}"
			fi
		fi

		# If the ping is successful, start connection establishment
		if [[ "${is_online}" == "true" ]]; then
			connect_server

			if [[ "${is_connected}" == "true" ]]; then
				if [ -n "${verbose}" ]; then
					${ssh} ${verbose} logout > >(tee -a "${script_log}") 2>&1
				fi
				echo "${txt_server_connection_true}" | tee -a "${script_log}"
				exit_code=0
			else
				echo "${txt_server_connection_false}" | tee -a "${script_log}"
				echo "$(timestamp) - [ ${jobname} ] ${txt_server_connection_false}" >> "${system_log}"
				synodsmnotify -c SYNO.SDS."${app}".Application @administrators "${app}":app:title "${app}":app:server_failed
				exit_code=1
			fi
		fi
	fi
	unset is_awake is_connected
fi

# ------------------------------------------------------------------------
# Create target folder on local machine or remote server
# ------------------------------------------------------------------------
if [[ ${exit_code} -eq 0 ]]; then

	# Escape white spaces with backslash from ${var[target]} and rename variable
	target=$(echo ${var[target]} | sed -e 's/ /\ /g')

	# If the connectiontype is local or sshpull
	if [[ "${connectiontype}" == "local" ]] || [[ "${connectiontype}" == "sshpull" ]]; then

		# If the backup destination is on a USB data carrier, check the mount point and adjust it if necessary
		if [[ "${target}" == /volumeUSB* ]] || [[ "${target}" == /volumeSATA* ]]; then
			echo "${txt_target_folder_on_usb}" | tee -a "${script_log}"

			if [[ "${var[uuidcheck]}" == "true" ]]; then
				echo "${txt_target_folder_check_uuid}" | tee -a "${script_log}"

				# Split the original ${target} into volume and share
				old_mountpoint=$(echo "${target}" | cut -d'/' -f1-3)
				targetfolder=$(echo "${target}" | cut -d'/' -f4-)

				# Evaluates the mount points of all connected USB data carriers
				mnts=( /volumeUSB /volumeSATA )
				while IFS= read -r volume; do
					IFS="${backupIFS}"
					[[ -z "${volume}" ]] && continue

					# Evaluates the associated share of the mounted USB data carrier
					while IFS= read -r share; do
						IFS="${backupIFS}"
						[[ -z "${share}" ]] && continue
						new_mountpoint="${share}"

						# Evaluates the device as well as the uuid of the mounted USB data carrier
						mountpoint=$(mount | grep -E "${new_mountpoint}")
						dev=$(echo "${mountpoint}" | awk '{print $1}')
						[[ -z "${dev}" ]] && continue
						uuid=$(blkid -s UUID -o value ${dev})

						# If the original UUID matches the determined UUID, set the determined mount point if necessary
						if [[ "${uuid}" == "${var[uuid]}" ]]; then
							if [[ "${old_mountpoint}" != "${new_mountpoint}" ]]; then
								var[target]="${new_mountpoint}/${targetfolder}"
								echo "${txt_target_folder_mountpoint_changed}" | tee -a "${script_log}"
								echo "${txt_target_folder_org_mnt} [ ${old_mountpoint} ]" | tee -a "${script_log}"
								echo "${txt_target_folder_new_mnt} [ ${new_mountpoint} ]" | tee -a "${script_log}"
								exit_mountpoint=0
							else
								echo "${txt_target_folder_mountpoint_match}" | tee -a "${script_log}"
								exit_mountpoint=0
							fi
						else
							continue
						fi

					done <<< "$( find ${volume}/* -maxdepth 0 -type d ! -path '*/lost\+found' ! -path '*/\@*' ! -path '*/\$RECYCLE.BIN' ! -path '*/Repair' ! -path '*/System Volume Information' )"
				done <<< "$( find "${mnts[@]}" -maxdepth 0 -type d 2>/dev/null )"
				unset volume share old_mountpoint targetfolder new_mountpoint mountpoint dev uuid label type

			else
				# Extract mountpoint from ${target}
				mountpoint=$(echo "${target}" | cut -d'/' -f1-3)

				echo "${txt_target_folder_check_mountpoint}" | tee -a "${script_log}"

				if [ -d "${mountpoint}" ]; then
					echo "${txt_target_folder_localized} [ ${mountpoint} ]" | tee -a "${script_log}"
					exit_mountpoint=0
				else
					echo "${txt_target_folder_nolocalized}" | tee -a "${script_log}"
					exit_mountpoint=1
				fi
			fi
		fi

		# Extract volume label and shared folder name from ${target}
		shared_folder=$(echo "${target}" | cut -d'/' -f1-3)

		# Generate an encrypted share name from ${shared_folder} 
		encrypted_shared_folder=$(echo "${shared_folder}" | sed 's/\/\([^/]*\)$/\/@\1/' | sed 's/\\//g;s/$/@/')

		# Check if an encrypted target folder exists
		if [ -d "${encrypted_shared_folder}" ]; then
			echo "${txt_target_folder_crypt_check}" | tee -a "${script_log}"

			# Check if the encrypted target folder is already mounted
        	if [[ "$(/bin/mount -t ecryptfs | grep "${shared_folder}" | wc -c)" -ne 0 ]]; then
				echo "${txt_target_folder_crypt_mount}" | tee -a "${script_log}"
				exit_crypt=1
			else
				echo "${txt_target_folder_crypt_unmount}" | tee -a "${script_log}"
				exit_crypt=2
			fi
		else
			exit_crypt=0
		fi

		if [ ! -d "${target}" ] && [[ ${exit_crypt} -eq 0 ]] && [[ ${exit_code} -eq 0 ]]; then
			mkdir -p "${target}"
			exit_mkdir=${?}
		elif [[ ${exit_crypt} -eq 2 ]]; then
			exit_mkdir=1
		fi

	fi

	# If the connectiontype is sshpush
	if [[ "${connectiontype}" == "sshpush" ]]; then

		if ${ssh} test ! -d "'${target}'"; then
			${ssh} "mkdir -p -m u+X '${target}'"
			exit_mkdir=${?}
		fi
	fi

	# If the target folder has been created correctly
	if [[ ${exit_mkdir} -eq 0 ]] && [[ ${exit_code} -eq 0 ]] && [[ ${exit_mountpoint} -eq 0 ]]; then
		echo "${txt_target_folder_true}" | tee -a "${script_log}"
		exit_code=0
	else
		if [[ ${exit_mountpoint} -ne 0 ]]; then
			echo "${txt_target_folder_mountpoint_false}" | tee -a "${script_log}"
			echo "$(timestamp) - [ ${jobname} ] ${txt_target_folder_mountpoint_false}" >> "${system_log}"
		fi
		if [[ ${exit_crypt} -eq 2 ]]; then
			echo "${txt_target_folder_crypt_false}" | tee -a "${script_log}"
			echo "$(timestamp) - [ ${jobname} ] ${txt_target_folder_false}" >> "${system_log}"
		fi
		if [[ ${exit_mkdir} -ne 0 ]]; then
			echo "${txt_target_folder_false}" | tee -a "${script_log}"
			echo "$(timestamp) - [ ${jobname} ] ${txt_target_folder_false}" >> "${system_log}"
		fi
		synodsmnotify -c SYNO.SDS."${app}".Application @administrators "${app}":app:title "${app}":app:target_failed
		exit_code=1
	fi
	unset exit_crypt exit_mkdir
fi

# ------------------------------------------------------------------------
# Start rsync data backup...
# ------------------------------------------------------------------------
if [[ ${exit_code} -eq 0 ]]; then

	#---------------------------------------------------------------------
	# Notification that rsync data backup starts...
	#---------------------------------------------------------------------
	echo "${txt_rsync_loop_starts}" | tee -a "${script_log}"
	synodsmnotify -c SYNO.SDS."${app}".Application @administrators "${app}":app:title "${app}":app:job_executed "${jobname}"

	#---------------------------------------------------------------------
	# Configure RSync options
	#---------------------------------------------------------------------
	dirdate=$(date "+%Y-%m-%d_%Hh-%Mm-%Ss")

	# If the 3rd party package -SynoCli Monitor Tools- of the -SynoCommunity- is installed and debug is off, then use the tool ionice...
	debug_ionice=$(synogetkeyvalue ${dir}/usersettings/system/debug.config switch_off_ionice)
	if [ -f /usr/local/bin/ionice ] && [ -z "${debug_ionice}" ]; then
		ionice="/usr/local/bin/ionice -c 3"
	# ...else... use Bandwidth speed limit
	elif [ -n "${var[speedlimit]}" ] && [[ "${var[speedlimit]}" -gt 0 ]]; then
		speedlimit="--bwlimit=${var[speedlimit]}"
	fi

	excluded="--delete-excluded --exclude=@eaDir/*** --exclude=@Logfiles/*** --exclude=#recycle/*** --exclude=#snapshot/*** --exclude=.DS_Store/***"

	#---------------------------------------------------------------------
	# Switch on @recycle without versioning and set target path
	# --------------------------------------------------------------------
	if [[ -z "${var[versioning]}" ]] || [[ "${var[versioning]}" == "false" ]]; then

		# If the number of days in the Recycle Bin function is not 0, create a restore point.
		if [[ -n "${var[recycle]}" ]] && [[ "${var[recycle]}" -ne 0 ]]; then
			backup="--backup --backup-dir=@recycle/${dirdate}"
		fi

		# Fix for 0.5-000 to move @backup into @recycle and delete @backup
		if [ -d "${var[target]}/@backup" ]; then
			mv "${var[target]}/@backup"/* "${var[target]}/@recycle"
			rm -rf "${var[target]}/@backup"
		fi

		# Make sure that the target path ends with a slash
		# ----------------------------------------------------------------
		if [ "${var[target]:${#var[target]}-1:1}" != "/" ]; then
			target="${var[target]}/"
		else
			target="${var[target]}"
		fi
	fi

	#---------------------------------------------------------------------
	# Switch off @recycle with versioning and set target path
	# --------------------------------------------------------------------
	if [[ -n "${var[versioning]}" ]] && [[ "${var[versioning]}" == "true" ]]; then

		# Make sure that the target path ends with a slash after version folder
		# ----------------------------------------------------------------
		if [ "${var[target]:${#var[target]}-1:1}" != "/" ]; then
			target="${var[target]}/${txt_main_version}/"
			history="${var[target]}/${txt_version_history}/"
		else
			target="${var[target]}${txt_main_version}/"
			history="${var[target]}${txt_version_history}/"
		fi
	fi

	#---------------------------------------------------------------------
	# Read in the sources and pass them to the rsync script
	# --------------------------------------------------------------------
	rsync_exit=()
	IFS='&'
	read -r -a sources <<< "${var[sources]}"
	IFS="${backupIFS}"
	for source in "${sources[@]}"; do
		source=$(echo "${source}" | sed 's/^[ \t]*//;s/[ \t]*$//')

		#-----------------------------------------------------------------
		# Beginn rsync loop
		# ----------------------------------------------------------------
		echo "" | tee -a "${script_log}"
		echo "${txt_line_separator}" | tee -a "${script_log}"
		echo "$(timestamp) - ${txt_rsync_loop_log}..." | tee -a "${script_log}"
		echo "➜ ${source}" | tee -a "${script_log}"
		echo "${txt_line_separator}" | tee -a "${script_log}"

		# If the connectiontype is local
		if [[ "${connectiontype}" == "local" ]]; then
			# Local to Local:  rsync [option]... [source]... target
			${ionice} \
			rsync \
			${var[syncopt]} \
			${speedlimit} \
			${dryrun} \
			${verbose} \
			--stats \
			--delete \
			${backup} \
			${excluded} \
			"${source}" "${target}" > >(tee -a "${script_log}") 2>&1
			rsync_exit_code=${?}
		fi

		# If the connectiontype is sshpull
		if [[ "${connectiontype}" == "sshpull" ]]; then
			# Remote to Local: rsync [option]... [USER@]HOST:source... [target]
			# Notes: To transfer folder and file names from or to a remote shell 
			# that contain spaces and/or special characters, the rsync option 
			# --protect-args (-s) is used. Alternatively, folder and file names 
			# can also be set in additional single quotes. 
			# Example: either ... rsync -s "${source}" ... or ... "'${source}'"
			${ionice} \
			rsync -s \
			${var[syncopt]} \
			${speedlimit} \
			${dryrun} \
			${verbose} \
			--stats \
			--delete \
			${backup} \
			${excluded} \
			-e "ssh -p ${var[sshport]} -i ~/.ssh/${var[privatekey]}" ${var[sshuser]}@${var[sshpull]}:"${source}" "${target}" > >(tee -a "${script_log}") 2>&1
			rsync_exit_code=${?}
		fi

		# If the connectiontype is sshpush
		if [[ "${connectiontype}" == "sshpush" ]]; then
			# Local to Remote: rsync [option]... [source]... [USER@]HOST:DEST
			# Notes: To transfer folder and file names from or to a remote shell 
			# that contain spaces and/or special characters, the rsync option 
			# --protect-args (-s) is used. Alternatively, folder and file names 
			# can also be set in additional single quotes. 
			# Example: either ... rsync -s "${target}" ... or ... "'${target}'"
			${ionice} \
			rsync -s \
			${var[syncopt]} \
			${speedlimit} \
			${dryrun} \
			${verbose} \
			--stats \
			--delete \
			${backup} \
			${excluded} \
			${perms} \
			-e "ssh -p ${var[sshport]} -i ~/.ssh/${var[privatekey]}" "${source}" ${var[sshuser]}@${var[sshpush]}:"${target}" > >(tee -a "${script_log}") 2>&1
			rsync_exit_code=${?}
		fi

		#-----------------------------------------------------------------
		# rsync exit codes
		# ----------------------------------------------------------------
		if [[ "${rsync_exit_code}" -ne 0 ]]; then
			rsync_exit+="${rsync_exit_code}"
			echo -n "<br />" >> "${script_log}"
			echo ""
			if [[ ${rsync_exit_code} -eq 1 ]]; then
				echo "${txt_rsync_1_log}" | tee -a "${script_log}"
			elif [[ ${rsync_exit_code} -eq 2 ]]; then
				echo "${txt_rsync_2_log}" | tee -a "${script_log}"
			elif [[ ${rsync_exit_code} -eq 3 ]]; then
				echo "${txt_rsync_3_log}" | tee -a "${script_log}"
			elif [[ ${rsync_exit_code} -eq 4 ]]; then
				echo "${txt_rsync_4_log}" | tee -a "${script_log}"
			elif [[ ${rsync_exit_code} -eq 5 ]]; then
				echo "${txt_rsync_5_log}" | tee -a "${script_log}"
			elif [[ ${rsync_exit_code} -eq 6 ]]; then
				echo "${txt_rsync_6_log}" | tee -a "${script_log}"
			elif [[ ${rsync_exit_code} -eq 10 ]]; then
				echo "${txt_rsync_10_log}" | tee -a "${script_log}"
			elif [[ ${rsync_exit_code} -eq 11 ]]; then
				echo "${txt_rsync_11_log}" | tee -a "${script_log}"
			elif [[ ${rsync_exit_code} -eq 12 ]]; then
				echo "${txt_rsync_12_log}" | tee -a "${script_log}"
			elif [[ ${rsync_exit_code} -eq 13 ]]; then
				echo "${txt_rsync_13_log}" | tee -a "${script_log}"
			elif [[ ${rsync_exit_code} -eq 14 ]]; then
				echo "${txt_rsync_14_log}" | tee -a "${script_log}"
			elif [[ ${rsync_exit_code} -eq 20 ]]; then
				echo "${txt_rsync_20_log}" | tee -a "${script_log}"
			elif [[ ${rsync_exit_code} -eq 21 ]]; then
				echo "${txt_rsync_21_log}" | tee -a "${script_log}"
			elif [[ ${rsync_exit_code} -eq 22 ]]; then
				echo "${txt_rsync_22_log}" | tee -a "${script_log}"
			elif [[ ${rsync_exit_code} -eq 23 ]]; then
				echo "${txt_rsync_23_log}" | tee -a "${script_log}"
			elif [[ ${rsync_exit_code} -eq 24 ]]; then
				echo "${txt_rsync_24_log}" | tee -a "${script_log}"
			elif [[ ${rsync_exit_code} -eq 25 ]]; then
				echo "${txt_rsync_25_log}" | tee -a "${script_log}"
			elif [[ ${rsync_exit_code} -eq 30 ]]; then
				echo "${txt_rsync_30_log}" | tee -a "${script_log}"
			elif [[ ${rsync_exit_code} -eq 35 ]]; then
				echo "${txt_rsync_35_log}" | tee -a "${script_log}"
			elif [[ ${rsync_exit_code} -eq 43 ]]; then
				echo "${txt_rsync_43_log}" | tee -a "${script_log}"
			elif [[ ${rsync_exit_code} -eq 44 ]]; then
				echo "${txt_rsync_44_log}" | tee -a "${script_log}"
			elif [[ ${rsync_exit_code} -eq 127 ]]; then
				echo "${txt_rsync_127_log}" | tee -a "${script_log}"
			elif [[ ${rsync_exit_code} -eq 255 ]]; then
				echo "${txt_rsync_255_log}" | tee -a "${script_log}"
			fi
		fi
	done
	echo "${txt_line_separator}" | tee -a "${script_log}"
fi

# ------------------------------------------------------------------------
# Error analysis after rsync run...
# ------------------------------------------------------------------------
if [[ ${exit_code} -eq 0 ]]; then

	# If rsync returned an error, set exit_rsync to 1, otherwise to 0
	if [ -z "${rsync_exit[@]}" ]; then
		exit_code=0
	else
		for exit_code in "${rsync_exit[@]}"; do
			if [[ "${exit_code}" -eq 44 ]]; then
				exit_code=1
			elif [[ "${exit_code}" -ne 0 ]]; then
				exit_rsync=1
			fi
		done
	fi
	unset rsync_exit
fi

# --------------------------------------------------------------------
# Rotation cycle for deleting /@recycle when versioning is off
# --------------------------------------------------------------------
if [[ ${exit_code} -eq 0 ]]; then
	if [[ -z "${var[versioning]}" ]] || [[ "${var[versioning]}" == "false" ]]; then

		if [[ -n "${var[recycle]}" ]] && [[ "${var[recycle]}" -ne 0 ]]; then

			# ----------------------------------------------------------------
			# If the connectiontype is local or sshpull...
			# ----------------------------------------------------------------
			if [ -z "${dryrun}" ] && [[ "${connectiontype}" == "sshpull" || "${connectiontype}" == "local" ]]; then

				# If the folder exists, then execute the find command
				if [ -d "${target%/*}/@recycle" ]; then
					find "${target%/*}/@recycle/"* -maxdepth 0 -type d -mtime +${var[recycle]} -print0 | xargs -0 rm -r 2>/dev/null
					if [[ ${?} -eq 0 ]]; then
						echo "${txt_recycle_delete}" | tee -a "${script_log}"
					fi
				fi
			fi

			# ----------------------------------------------------------------
			# If the connectiontype is sshpush...
			# ----------------------------------------------------------------
			if [ -z "${dryrun}" ] && [[ "${connectiontype}" == "sshpush" ]]; then

				# Escape white spaces with backslash
				at_recycle=$(echo ${target%/*}/@recycle | sed -e 's/ /\ /g')

				# If the remote folder exists, then execute the find command
				if ${ssh} test -d "'${at_recycle}'"; then
					${ssh} "find '${at_recycle}' -maxdepth 0 -type d -mtime +${var[recycle]} -print0 | xargs -0 rm -r" 2>/dev/null
					if [[ ${?} -eq 0 ]]; then
						echo "${txt_recycle_delete}" | tee -a "${script_log}"
					fi
				fi
			fi
		fi
	fi
fi

#---------------------------------------------------------------------
# Create @configs folder on local machine or remote server
# --------------------------------------------------------------------
if [[ ${exit_code} -eq 0 ]]; then

	# ----------------------------------------------------------------
	# If the connectiontype is local or sshpull
	# ----------------------------------------------------------------
	if [[ "${connectiontype}" == "local" ]] || [[ "${connectiontype}" == "sshpull" ]]; then
		# Check if the folder exists, otherwise create it
		if [ ! -d "${target%./}/@configs" ]; then
			mkdir -p -m 0755 "${target%/*}/@configs"
			exit_mkdir=${?}
		fi

		# If the folder exists, then execute the command
		if [ -d "${target%/*}/@configs" ]; then

			# Local: Copy DSM config and Basic Backup config on the local machine
			if [[ "${connectiontype}" == "local" ]]; then
				if [ -f "${target%/*}/@configs/DSMConfig_${localhost}.dss" ]; then
					rm -f "${target%/*}/@configs/DSMConfig_${localhost}.dss"
				fi
				synoconfbkp export --filepath "${target%/*}/@configs/DSMConfig_${localhost}.dss"
				cp "${backupjob}" "${target%/*}"/@configs
				exit_cp=${?}
			fi

			# Pull: Copy only Basic Backup config because no DSM config can be pulled from the remote server!
			if [[ "${connectiontype}" == "sshpull" ]]; then
				cp "${backupjob}" "${target%/*}"/@configs
				exit_cp=${?}
			fi
		fi

		# If all commands have been executed, then report
		if [[ ${exit_mkdir} -eq 0 ]] || [[ ${exit_cp} -eq 0 ]]; then

			if [[ "${connectiontype}" == "local" ]]; then
				echo "${txt_config_copy_all}" | tee -a "${script_log}"
			fi

			if [[ "${connectiontype}" == "sshpull" ]]; then
				echo "${txt_config_copy_bbc}" | tee -a "${script_log}"
			fi
		fi
		unset exit_mkdir exit_cp
	fi

	# ----------------------------------------------------------------
	# If the connectiontype is sshpush
	# ----------------------------------------------------------------
	if [[ "${connectiontype}" == "sshpush" ]]; then
		# Export DSMConfig
		synoconfbkp export --filepath "/tmp/@configs/DSMConfig_$localhost.dss" 2>/dev/null

		# Escape white spaces with backslash
		at_configs=$(echo ${target%/*}/@configs | sed -e 's/ /\ /g')

		# Check if the remote folder exists, otherwise create it
		if ${ssh} test ! -d "'${at_configs}'"; then
			${ssh} "mkdir -p -m 0755 '${at_configs}'"
			exit_mkdir=${?}
		fi

		# If the remote folder exists, then execute the scp command

		# Push: Copy DSM config and Basic Backup config on the remote server
		if ${ssh} test -d "'${target}'"; then
			${scp} -rq /tmp/@configs/*.dss ${var[sshuser]}@${var[sshpush]}:"'${at_configs}'"
			${scp} -rq "${backupjob}" ${var[sshuser]}@${var[sshpush]}:"'${at_configs}'"
			exit_scp=${?}
		fi

		# If all commands have been executed, then report
		if [[ ${exit_mkdir} -eq 0 ]] || [[ ${exit_scp} -eq 0 ]]; then
			echo "${txt_config_copy_all}" | tee -a "${script_log}"
		fi
		unset exit_mkdir exit_scp

		rm -rf "/tmp/@configs"
	fi
fi

# --------------------------------------------------------------------
# Create version of the current data set when versioning is on
# --------------------------------------------------------------------
if [[ ${exit_code} -eq 0 ]]; then
	if [ -n "${var[versioning]}" ] && [[ "${var[versioning]}" == "true" ]]; then

		# ----------------------------------------------------------------
		# If the connectiontype is local or sshpull...
		# ----------------------------------------------------------------
		if [ -z "${dryrun}" ] && [[ "${connectiontype}" == "sshpull" || "${connectiontype}" == "local" ]]; then

			# Check if the folder exists, otherwise create it
			if [ ! -d "${history}" ]; then
				mkdir -p -m 0755 "${history}"
				if [[ ${?} -ne 0 ]]; then
					echo "${txt_version_history_failed}" | tee -a "${script_log}"
				fi
			fi

			# If the folder exists, then execute the cp command
			if [ -d "${history}" ]; then
				cp -al "${target}/" "${history}/${dirdate}"
				if [[ ${?} -eq 0 ]]; then
					echo "${txt_version_history_create}" | tee -a "${script_log}"
				else
					echo "${txt_version_history_failed}" | tee -a "${script_log}"
				fi
			fi
		fi

		# ----------------------------------------------------------------
		# If the connectiontype is sshpush...
		# ----------------------------------------------------------------
		if [ -z "${dryrun}" ] && [[ "${connectiontype}" == "sshpush" ]]; then

			# Escape white spaces with backslash
			at_history=$(echo ${history} | sed -e 's/ /\ /g')

			# Check if the remote folder exists, otherwise create it
			if ${ssh} test ! -d "'${at_history}'"; then
				${ssh} "mkdir -p -m 0755 '${at_history}'"
				if [[ ${?} -ne 0 ]]; then
					echo "${txt_version_history_failed}" | tee -a "${script_log}"
				fi
			fi

			# If the remote folder exists, then execute the cp command
			if ${ssh} test -d "'${at_history}'"; then
				${ssh} "cp -al '${target}'/ '${at_history}'${dirdate}"
				if [[ ${?} -eq 0 ]]; then
					echo "${txt_version_history_create}" | tee -a "${script_log}"
				else
					echo "${txt_version_history_failed}" | tee -a "${script_log}"
				fi
			fi
		fi
	fi
fi

# --------------------------------------------------------------------
# Rotation cycle for deleting /VersionHistory when /@recycle is off
# --------------------------------------------------------------------
if [[ ${exit_code} -eq 0 ]]; then
	if [ -n "${var[versioning]}" ] && [[ "${var[versioning]}" == "true" ]]; then

		# ----------------------------------------------------------------
		# If the connectiontype is local or sshpull...
		# ----------------------------------------------------------------
		if [ -z "${dryrun}" ] && [[ "${connectiontype}" == "sshpull" || "${connectiontype}" == "local" ]]; then

			# If the folder exists, then execute the find command
			if [ -d "${history}" ]; then
				find "${history}/"* -maxdepth 0 -type d -mtime +${var[versions]} -print0 | xargs -0 rm -r 2>/dev/null
				if [[ ${?} -eq 0 ]]; then
					echo "${txt_version_history_delete}" | tee -a "${script_log}"
				fi
			fi
		fi

		# ----------------------------------------------------------------
		# If the connectiontype is sshpush...
		# ----------------------------------------------------------------
		if [ -z "${dryrun}" ] && [[ "${connectiontype}" == "sshpush" ]]; then

			# Escape white spaces with backslash
			at_history=$(echo ${history} | sed -e 's/ /\ /g')

			# If the remote folder exists, then execute the find command
			if ${ssh} test -d "'${at_history}'"; then
				${ssh} "find '${at_history}'/* -maxdepth 0 -type d -mtime +${var[versions]} -print0 | xargs -0 rm -r" 2>/dev/null
				# Verify that a new entry in the version history is correctly
				if [[ ${?} -eq 0 ]]; then
					echo "${txt_version_history_delete}" | tee -a "${script_log}"
				fi
			fi
		fi
	fi
fi

# ------------------------------------------------------------------------
# Shutdown remote server
# ------------------------------------------------------------------------
if [[ ${exit_code} -eq 0 ]]; then

	# If the remote server does not shut down
	if [[ "${is_online}" == "true" ]] && [[ "${var[shutdown]}" == "false" ]]; then
		echo "${txt_server_shutdown_info}" | tee -a "${script_log}"
	fi

	# If the remote server is only shut down after success
	if [[ "${is_online}" == "true" ]] && [[ "${var[shutdown]}" == "success" ]]; then
		shutdown_server
	fi
fi

if [[ ${exit_code} -eq 0 ]] || [[ ${exit_code} -eq 1 ]]; then

	# If the remote server is always shut down
	if [[ "${is_online}" == "true" ]] && [[ "${var[shutdown]}" == "always" ]]; then
		shutdown_server
	fi
fi

# ------------------------------------------------------------------------
# Signal control
# ------------------------------------------------------------------------
if [[ "${var[optical]}" == "true" ]]; then
	# Status LED green on
	echo 8 >/dev/ttyS1
fi

if [[ "${var[acoustical]}" == "true" ]]; then
	if [[ "${exit_code}" -eq 0 ]]; then
		# 1x long beep sound
		echo 3 >/dev/ttyS1
	else
		# 3x short beep sound
		echo 2 >/dev/ttyS1
		sleep 1
		echo 2 >/dev/ttyS1
		sleep 1
		echo 2 >/dev/ttyS1;
	fi
fi

# ------------------------------------------------------------------------
# Notification of success or failure
# ------------------------------------------------------------------------

if [[ "${exit_code}" -eq 0 ]]; then

	# Delete pid file
	[ -f /var/packages/"${app}"/tmp/pid ] && rm /var/packages/"${app}"/tmp/pid

	# Notification that the backup job was successfully executed
	echo "${txt_line_separator}" | tee -a "${script_log}"
	echo "$(timestamp) - ${txt_backupjob_success}" | tee -a "${script_log}"
	echo "$(timestamp) - [ ${jobname} ] ${txt_backupjob_success}" >> "${system_log}"
	synodsmnotify -c SYNO.SDS."${app}".Application @administrators "${app}":app:title "${app}":app:job_successful "${jobname}"
	synologset1 sys info 0x11100000 "Package [${app}] completed the backup job [${jobname}] successfully!"
else
	# Delete pid file
	[ -f /var/packages/BasicBackup/tmp/pid ] && rm /var/packages/BasicBackup/tmp/pid

	# Notification that the backup job contained errors
	echo "${txt_line_separator}" | tee -a "${script_log}"
	echo "$(timestamp) - ${txt_backupjob_warning}" | tee -a "${script_log}"
	echo "$(timestamp) - [ ${jobname} ] ${txt_backupjob_warning}" >> "${system_log}"
	synodsmnotify -c SYNO.SDS."${app}".Application @administrators "${app}":app:title "${app}":app:job_warning "${jobname}"
	synologset1 sys info 0x11100000 "Package [${app}] executed the backup job [${jobname}] with errors! Check the job log."
	
fi


# --------------------------------------------------------------------
# Email notifications
# --------------------------------------------------------------------
if [[ "${var[sendemail]}" == "true" ]] || [[ "${var[sendemail]}" == "problem" ]]; then

	# Check whether e-mail from and e-mail to are correct
	if [ -n "${var[emailfrom]}" ] && [ -n "${var[emailto]}" ]; then
		echo "To: ${var[emailto]}" > "${email_log}"
		echo "From: ${var[emailfrom]}" >> "${email_log}"

		# Always send e-mail when no problems have occurred (sendemail = true)
		if [[ "${exit_code}" -eq 0 ]] && [[ "${var[sendemail]}" == "true" ]]; then
			echo "Subject: ${txt_email_success}" >> "${email_log}"
			echo "" >> "${email_log}"
			cat "${script_log}" >> "${email_log}"
			if [ -n "${verbose}" ]; then
				echo "" | tee -a "${script_log}"
				echo "Start SMTP Debug Mode..." | tee -a "${script_log}"
				ssmtp ${verbose} "${var[emailto]}" < "${email_log}" > >(tee -a "${script_log}") 2>&1
				echo "...close SMTP debug mode" | tee -a "${script_log}"
				echo "" | tee -a "${script_log}"
			else
				ssmtp "${var[emailto]}" < "${email_log}"
			fi
			exit_ssmtp=${?}

		# Send e-mail in case of problems (sendemail = true or problem)
		elif [[ "${exit_code}" -ne 0 ]] && [[ "${var[sendemail]}" == "true" || "${var[sendemail]}" == "problem" ]]; then
			echo "Subject: ${txt_email_warning}" >> "${email_log}"
			echo "" >> "${email_log}"
			cat "${script_log}" >> "${email_log}"
			if [ -n "${verbose}" ]; then
				echo "" | tee -a "${script_log}"
				echo "Start SMTP Debug Mode..." | tee -a "${script_log}"
				ssmtp ${verbose} "${var[emailto]}" < "${email_log}" > >(tee -a "${script_log}") 2>&1
				echo "...close SMTP debug mode" | tee -a "${script_log}"
				echo "" | tee -a "${script_log}"
			else
				ssmtp "${var[emailto]}" < "${email_log}"
			fi
			exit_ssmtp=${?}
		fi

		# Check if e-mail has been sent
		if [[ "${exit_code}" -eq 0 ]] && [[ "${exit_ssmtp}" -eq 0 ]] && [[ "${var[sendemail]}" == "true" ]]; then
			echo " - ${txt_email_send}" | tee -a "${script_log}"
		elif [[ "${exit_code}" -ne 0 && "${exit_ssmtp}" -eq 0 ]] && [[ "${var[sendemail]}" == "true" || "${var[sendemail]}" == "problem" ]]; then
			echo " - ${txt_email_send}" | tee -a "${script_log}"
		elif [[ "${exit_ssmtp}" -ne 0 ]]; then
			echo " - ${txt_email_fail}" | tee -a "${script_log}"
		fi

		# Delete e-mail log
		rm "${email_log}"

	else
		echo "${txt_email_fail}" | tee -a "${script_log}"
	fi
fi

if [[ "${exit_code}" -eq 0 ]]; then
	exit
elif [[ "${exit_code}" -ne 0 ]]; then
	exit 1
elif [[ "${exit_mountpoint}" -ne 0 ]]; then
	exit 2
fi
