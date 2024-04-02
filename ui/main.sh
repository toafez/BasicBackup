#!/bin/bash
# Filename: main.sh - coded in utf-8

#                       Basic Backup
#
#        Copyright (C) 2024 by Tommes | License GNU GPLv3
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


# Requests zurücksetzen und Seite neu laden
# --------------------------------------------------------------
if [[ "${get[page]}" == "main" && "${get[section]}" == "reset" ]]; then
	unset var
	[[ -f "${get_request}" ]] && rm "${get_request}"
	[[ -f "${post_request}" ]] && rm "${post_request}"
	echo '<meta http-equiv="refresh" content="0; url=index.cgi?page=main&section=start">'
fi

# Horizontale Navigationsleiste laden
# --------------------------------------------------------------
mainnav

# Startseite anzeigen
# --------------------------------------------------------------
if [[ "${get[page]}" == "main" && "${get[section]}" == "start" ]]; then
	[[ -f "${post_request}" ]] && source "${post_request}"
	
	# Überprüfen des App-Versionsstandes
	# --------------------------------------------------------------
	git_version=$(wget --no-check-certificate --timeout=60 --tries=1 -q -O- "https://raw.githubusercontent.com/toafez/${app_name}/main/INFO.sh" | grep ^version | cut -d '"' -f2)		
	if [ -n "${git_version}" ] && [ -n "${app_version}" ]; then
		if dpkg --compare-versions ${git_version} gt ${app_version}; then
			echo '
			<div class="card">
				<div class="card-header bg-danger-subtle"><strong>'${txt_update_available}'</strong></div>
				<div class="card-body">'${txt_update_from}'<span class="text-danger"> '${app_version}' </span>'${txt_update_to}'<span class="text-success"> '${git_version}'</span>
					<div class="float-end"> 
						<a href="https://github.com/toafez/'${app_name}'/releases" class="btn btn-sm text-dark text-decoration-none" style="background-color: #e6e6e6;" target="_blank">Update</a>
					</div>
				</div>
			</div><br />'
		fi
	fi

	# Überprüfen der App-Berechtigung
	# --------------------------------------------------------------
	if [ -z "${app_permissions}" ] || [[ "${app_permissions}" == "false" ]]; then
		echo '
		<div class="card">
			<div class="card-header bg-danger-subtle"><strong>'${txt_group_status}'</strong></div>
			<div class="card-body">'${txt_group_status_false}'
				<div class="float-end"> 
					<a href="#help-permissions" class="btn btn-sm text-dark text-decoration-none" style="background-color: #e6e6e6;" data-bs-toggle="modal" data-bs-target="#help-app-permissions">'${txt_button_extend_permission}'</a>
				</div>
			</div>
		</div><br />'
	fi

	# Überprüfen des rsync-Dienstes
	# --------------------------------------------------------------
	# rsync Status abfragen
	rsyncd_status=$(systemctl is-enabled rsyncd.service)
	if [[ "${rsyncd_status}" != "enabled" ]]; then
		echo '
		<div class="card">
			<div class="card-header bg-danger-subtle"><strong>'${txt_rsync_service}' '${txt_is_inactive}'</strong></div>
			<div class="card-body">'${txt_rsync_info}'</div>
		</div><br />'
	fi

	# Überprüfen des ssh-Dienstes
	# --------------------------------------------------------------
	# SSH Status abfragen
	sshd_status=$(systemctl is-enabled sshd.service)
	if [[ "${sshd_status}" != "enabled" ]]; then
		echo '
		<div class="card">
			<div class="card-header bg-danger-subtle"><strong>'${txt_ssh_service}' '${txt_is_inactive}'</strong></div>
			<div class="card-body">'${txt_ssh_info}'</div>
		</div><br />'
	fi

	echo '
	<div class="accordion accordion-flush" id="main-accordion">'
		# Backupaufträge anzeigen
		# --------------------------------------------------------------
		backupconfigs=$(find "$usr_backupjobs" -type f -name "*.config" -maxdepth 1 | sort)
		if [ -n "$backupconfigs" ]; then
			id=1
			IFS="
			"
			for backupconfig in ${backupconfigs}; do
				IFS="${backupIFS}"
				[ -f "${backupconfig}" ] && source "${backupconfig}"
				backupjob=$(echo "${backupconfig##*/}")
				backupjob=$(echo "${backupjob%.*}")
				logfile="${usr_logfiles}/${backupjob}.log"

				# Ausgabe der Aufträge
				# ------------------------------------------------------------------------
				echo '
				<div class="accordion-item border-0 mb-3">
					<div class="accordion-header bg-light p-2">'

						process="false"
						is_active=$(synogetkeyvalue /var/packages/${app_name}/tmp/pid job)
						if [[ "${backupjob}" == "${is_active}" ]]; then
							process="true"
							echo '<meta http-equiv="refresh" content="10">'
						else
							process="false"
						fi

						echo '
						<a href="#edit'${id}'" class="text-dark text-decoration-none" data-bs-toggle="collapse" data-bs-target="#collapse'${id}'" aria-expanded="true" aria-controls="collapse'${id}'">'
							if [ -z "${var[sshpush]}" ] && [ -z "${var[sshpull]}" ]; then
								if [[ "${var[sources]}" == /volume[[:digit:]]* ]] && [[ "${var[target]}" == /volume[[:digit:]]* ]]; then
									backuptype="share-to-share"
									backupsource="${txt_local_diskstation}"
									backuptarget="${txt_local_diskstation}"
									sourceicon="bi bi-hdd"
									targeticon="bi bi-hdd"
								fi
								if [[ "${var[sources]}" == /volume[[:digit:]]* ]] && [[ "${var[target]}" == /volumeUSB* || "${var[target]}" == /volumeSATA* ]]; then
									backuptype="share-to-usb"
									backupsource="${txt_local_diskstation}"
									backuptarget="${txt_external_disk}"
									sourceicon="bi bi-hdd"
									targeticon="bi bi-usb-symbol"
								fi
								if [[ "${var[sources]}" == /volumeUSB* || "${var[sources]}" == /volumeSATA* ]] && [[ "${var[target]}" == /volume[[:digit:]]* ]]; then
									backuptype="usb-to-share"
									backupsource="${txt_external_disk}"
									backuptarget="${txt_local_diskstation}"
									sourceicon="bi bi-usb-symbol"
									targeticon="bi bi-hdd"
								fi
								if [[ "${var[sources]}" == /volumeUSB* || "${var[sources]}" == /volumeSATA* ]] && [[ "${var[target]}" == /volumeUSB* || "${var[target]}" == /volumeSATA* ]]; then
									backuptype="usb-to-usb"
									backupsource="${txt_external_disk}"
									backuptarget="${txt_external_disk}"
									sourceicon="bi bi-usb-symbol"
									targeticon="bi bi-usb-symbol"
								fi
							elif [ -n "${var[sshpush]}" ]; then
								if [[ "${var[sources]}" == /volume[[:digit:]]* ]]; then
									backuptype="share-push-server"
									backupsource="${txt_local_diskstation}"
									if [[ "${var[target]}" == /volume* ]]; then
										backuptarget="${txt_remote_diskstation}"
									else
										backuptarget="${txt_remote_server}"
									fi
									sourceicon="bi bi-hdd"
									targeticon="bi bi-hdd-network"
								fi
								if [[ "${var[sources]}" == /volumeUSB* || "${var[sources]}" == /volumeSATA* ]]; then
									backuptype="usb-push-server"
									backupsource="${txt_external_disk}"
									if [[ "${var[target]}" == /volume* ]]; then
										backuptarget="${txt_remote_diskstation}"
									else
										backuptarget="${txt_remote_server}"
									fi
									sourceicon="bi bi-usb-symbol"
									targeticon="bi bi-hdd-network"
								fi
							elif [ -n "${var[sshpull]}" ]; then 
								if [[ "${var[target]}" == /volume[[:digit:]]* ]]; then
									backuptype="share-pull-server"
									if [[ "${var[sources]}" == /volume* ]]; then
										backupsource="${txt_remote_diskstation}"
									else
										backupsource="${txt_remote_server}"
									fi
									backuptarget="${txt_local_diskstation}"
									sourceicon="bi bi-hdd-network"
									targeticon="bi bi-hdd"
								fi
								if [[ "${var[sources]}" == /volumeUSB* || "${var[sources]}" == /volumeSATA* ]]; then
									backuptype="usb-pull-server"
									if [[ "${var[sources]}" == /volume* ]]; then
										backupsource="${txt_remote_diskstation}"
									else
										backupsource="${txt_remote_server}"
									fi
									backuptarget="${txt_external_disk}"
									sourceicon="bi bi-hdd-network"
									targeticon="bi bi-usb-symbol"
								fi
							fi

							echo '
							<span class="btn btn-sm text-dark py-0" role="button" style="background-color: #e6e6e6;">
								<i class="bi bi-caret-down-fill pe-2" style="font-size: 0.9rem;" title=""></i><span class="fs-5 pe-1">|</span>'
								if [[ "${backuptype}" == "share-to-share" ]]; then
									echo '
									<i class="'${sourceicon}' pe-1" style="font-size: 1.2rem;" title="'${backupsource}'"></i>
									<i class="bi bi-arrow-right-short text-success pe-1" style="font-size: 1.2rem;"></i>
									<i class="'${targeticon}' pe-1" style="font-size: 1.2rem;" title="'${backuptarget}'"></i>'
								fi
								if [[ "${backuptype}" == "share-to-usb" ]]; then
									echo '
										<i class="'${sourceicon}' pe-1" style="font-size: 1.2rem;" title="'${backupsource}'"></i>
										<i class="bi bi-arrow-right-short text-success pe-1" style="font-size: 1.2rem;"></i>
										<i class="'${targeticon}' pe-1" style="font-size: 1.2rem;" title="'${backuptarget}'"></i>'
								fi
								if [[ "${backuptype}" == "usb-to-share" ]]; then
									echo '
									<i class="'${sourceicon}' pe-1" style="font-size: 1.2rem;" title="'${backupsource}'"></i>
									<i class="bi bi-arrow-right-short text-success pe-1" style="font-size: 1.2rem;"></i>
									<i class="'${targeticon}' pe-1" style="font-size: 1.2rem;" title="'${backuptarget}'"></i>'
								fi
								if [[ "${backuptype}" == "usb-to-usb" ]]; then
									echo '
									<i class="'${sourceicon}' pe-1" style="font-size: 1.2rem;" title="'${backupsource}'"></i>
									<i class="bi bi-arrow-right-short text-success pe-1" style="font-size: 1.2rem;"></i>
									<i class="'${targeticon}' pe-1" style="font-size: 1.2rem;" title="'${backuptarget}'"></i>'
								fi
								if [[ "${backuptype}" == "share-push-server" ]]; then
									echo '
									<i class="'${sourceicon}' pe-1" style="font-size: 1.2rem;" title="'${backupsource}'"></i>
									<i class="bi bi-arrow-right-short text-success pe-1" style="font-size: 1.2rem;"></i>
									<i class="'${targeticon}' pe-1" style="font-size: 1.2rem;" title="'${backuptarget}'"></i>'
								fi
								if [[ "${backuptype}" == "usb-push-server" ]]; then
									echo '
									<i class="'${sourceicon}' pe-1" style="font-size: 1.2rem;" title="'${backupsource}'"></i>
									<i class="bi bi-arrow-right-short text-success pe-1" style="font-size: 1.2rem;"></i>
									<i class="'${targeticon}' pe-1" style="font-size: 1.2rem;" title="'${backuptarget}'"></i>'
								fi
								if [[ "${backuptype}" == "share-pull-server" ]]; then
									echo '
									<i class="'${targeticon}' pe-1" style="font-size: 1.2rem;" title="'${backuptarget}'"></i>
									<i class="bi bi-arrow-left-short text-success pe-1" style="font-size: 1.2rem;"></i>
									<i class="'${sourceicon}' pe-1" style="font-size: 1.2rem;" title="'${backupsource}'"></i>'
								fi
								if [[ "${backuptype}" == "usb-pull-server" ]]; then
									echo '
									<i class="'${sourceicon}' pe-1" style="font-size: 1.2rem;" title="'${backupsource}'"></i>
									<i class="bi bi-arrow-left-short text-success pe-1" style="font-size: 1.2rem;"></i>
									<i class="'${targeticon}' pe-1" style="font-size: 1.2rem;" title="'${backuptarget}'"></i>'
								fi
								echo '
							</span>
						</a>'
						if [[ "${process}" == "true" ]]; then
							echo '
							<div class="spinner-grow" style="width: 1rem; height: 1rem; color: #FF8C00;" role="status">
								<span class="visually-hidden">Loading...</span>
							</div>&nbsp;&nbsp;'${backupjob}' <span class="text-success">'${txt_backupjob_runs}'</span>'
						else
							echo '&nbsp;&nbsp;'${backupjob}''
						fi

						echo '
						<div class="float-end">'

							# Auftragsoptionen anzeigen (rechts)
							# --------------------------------------------------------------

							# Job version
							if dpkg --compare-versions ${job_version} gt ${jobconfig_version}; then
								if dpkg --compare-versions ${jobconfig_version} eq "0.7-000"; then
									find ${usr_backupjobs}/ -type f -print0 | xargs -0 -n 1 sed -i -e 's/'"0.7-000"'/'"${job_version}"'/g'
								else
									echo '
									<a class="btn btn-sm text-dark btn-outline-danger bg-danger-subtle text-decoration-none me-1" role="button" href="index.cgi?page=jobedit&section=1&edit=true&jobname='${backupjob}'">
										<span style="font-size: 0.8rem;" title="'${txt_update_job_info}'">'${txt_update_job_run}'</span>
									</a>'
								fi
								unset jobconfig_version
							fi

							# Logfile
							if [ -f "${logfile}" ]; then
								echo '
								<a class="btn btn-sm text-dark text-decoration-none py-0 me-1" role="button" style="background-color: #e6e6e6;" href="index.cgi?page=view&section=scriptlog&file='${logfile}'&process='${process}'" title="'${txt_backup_log_title}'">
									<i class="bi bi-journal-text text-dark" style="font-size: 1.2rem;"></i></a>'
							fi

							# Settings
							echo '
							<a class="btn btn-sm text-dark text-decoration-none py-0 me-1" role="button" style="background-color: #e6e6e6;" href="index.cgi?page=jobedit&section=1&edit=true&jobname='${backupjob}'" title="'${txt_edit_job_title}'">
								<i class="bi bi-gear-fill text-secondary" style="font-size: 1.2rem;"></i></a>'

							# Trash
							echo '
							<a class="btn btn-sm text-dark text-decoration-none py-0" role="button" style="background-color: #e6e6e6;" href="index.cgi?page=main&section=start&query=delete&jobname='${backupjob}'" title="'${txt_delete_job_title}'">
								<i class="bi bi-trash text-danger" style="font-size: 1.2rem;"></i></a>
						</div>
					</div>'

					# Auftragseinstellungen anzeigen
					# ------------------------------------------------------------------------
					echo '
					<div id="collapse'${id}'" class="accordion-collapse collapse" aria-labelledby="heading'${id}'" data-bs-parent="#main-accordion">
						<div class="accordion-body bg-light">
							<table class="table table-sm table-light table-borderless mb-0">
								<thead></thead>
								<tbody>'
									# Datensicherungsziel
									echo '
									<tr>
										<td style="width: 220px;">
											'${txt_backup_target}'
										</td>
										<td style="width: auto;">
											<span class="text-dark">'${backuptarget}'</span>
											<br />
											<i class="bi bi-folder-fill text-warning ps-1" style="font-size: 1.2rem;"></i>
											<span class="text-secondary"> '${var[target]}'</span>
										</td>
									</tr>'
									# Datensicherungsquelle
									echo '
									<tr>
										<td style="width: 220px;">
											'${txt_backup_sources}'
										</td>
										<td style="width: auto;">
											<span class="text-dark">'${backupsource}'</span>
											<br />'
											IFS='&'
											read -r -a sources <<< "${var[sources]}"
											for source in "${sources[@]}"; do
												source=$(echo "${source}" | sed 's/^[ \t]*//;s/[ \t]*$//')
												echo '
												<i class="bi bi-folder-fill text-warning ps-1" style="font-size: 1.2rem;"></i>
												<span class="text-secondary"> '${source}'</span><br />'
											done
											IFS="${backupIFS}"
											unset source
											echo '
										</td>
									</tr>'
									# Versionsstände
									echo '
									<tr>
										<td style="width: 220px;">
											'${txt_versioning}'
										</td>'
										if [[ "${var[versioning]}" == "true" ]]; then
											echo '
											<td style="width: auto;">
												<span class="text-secondary">'${txt_versions_step_1}' <span class="text-danger">'${var[versions]}'</span> '${txt_versions_step_2}'</span>
											</td>'
										else
											echo '
											<td style="width: auto;">
												<span class="text-danger">'${txt_inactive}'</span>
											</td>'
										fi
										echo '
									</tr>'
									# Papierkorb
									echo '
									<tr>
										<td style="width: 220px;">
											'${txt_recycling}'
										</td>'
										if [[ "${var[versioning]}" == "true" ]]; then
											echo '
											<td style="width: auto;">
												<span class="text-secondary">'${txt_recycling_inactive}'</span>
											</td>'
										else
											if [[ "${var[recycle]}" -eq 0 ]]; then
												echo '
												<td style="width: auto;">
													<span class="text-danger">'${txt_inactive}'</span>
												</td>'
											else
												echo '
												<td style="width: auto;">
													<span class="text-secondary">'${txt_recycling_step_1}' <span class="text-danger">'${var[recycle]}'</span> '${txt_recycling_step_2}'</span>
												</td>'
											fi
										fi
										echo '
									</tr>'
									# Bandbreitenbeschänkung
									echo '
									<tr>
										<td style="width: 220px;">
											'${txt_speedlimit_title}'
										</td>
										<td style="width: auto;">
											<span class="text-secondary">'
												if [ -f /usr/local/bin/ionice ] && [ -z "${switch_off_ionice}" ]; then
													echo ''${txt_speedlimit_active}''
												else
													echo ''${txt_speedlimit_limited_info_step_1}' <span class="text-danger">'${var[speedlimit]}' kB/s</span> '${txt_speedlimit_limited_info_step_2}''
												fi
											echo '
											</span>
										</td>
									</tr>'
									# Optionsschalter
									echo '
									<tr>
										<td class="pt-2" style="width: 220px;">
											<span>'${txt_bash_code_option}'
												<span class="float-end">
													<a class="btn btn-sm text-dark text-decoration-none py-0" data-bs-toggle="collapse" href="#collapseOpt" role="button" aria-expanded="false" aria-controls="collapseOpt" style="background-color: #e6e6e6;" title="'${txt_link_note}'">
														<i class="bi bi-info-square text-primary" style="font-size: 1.2rem;"></i><i class="bi bi-caret-down-fill align-middle pb-1 ps-2" style="font-size: 0.5rem;" title=""></i>
													</a>
												</span>
											</span>
										</td>
										<td style="width: auto;">
											<span class="text-secondary">'${txt_bash_code_option_note}'</span>
											<div class="collapse mt-2" id="collapseOpt">
												<div class="card">								
													<div class="card-body ps-1">
														<small>
															<dl class="row">
																<dt class="col-sm-3 pe-4 fw-normal">--job-name="....."</dt>
																<dd class="col-sm-9 mb-0 text-secondary">'${txt_bash_code_jobname}'</dd>'
																if [ -n "${var[sshpush]}" ]; then
																	echo '
																	<dt class="col-sm-3 text-danger pe-4 fw-normal">--chmod=ugo=rwX</dt>
																	<dd class="col-sm-9 mb-0 text-secondary">'${txt_bash_code_perms_push}'</dd>'
																else
																	echo '
																	<dt class="col-sm-3 pe-4 fw-normal">--chmod="....."</dt>
																	<dd class="col-sm-9 mb-0 text-secondary">'${txt_bash_code_perms}'</dd>'
																fi
																echo '
																<dt class="col-sm-3 pe-4 fw-normal">--dry-run</dt>
																<dd class="col-sm-9 mb-0 text-secondary">'${txt_bash_code_dryrun}'</dd>
																<dt class="col-sm-3 pe-4 fw-normal">-v</dt>
																<dd class="col-sm-9 mb-0 text-secondary">'${txt_bash_code_rsync_v}''
																	if [ -n "${var[sshpull]}" ] || [ -n "${var[sshpush]}" ]; then
																		echo '<br />'${txt_bash_code_ssh_v}''
																	fi
																	echo '
																</dd>
																<dt class="col-sm-3 pe-4 fw-normal">-vv</dt>
																<dd class="col-sm-9 mb-0 text-secondary">'${txt_bash_code_rsync_vv}''
																	if [ -n "${var[sshpull]}" ] || [ -n "${var[sshpush]}" ]; then
																		echo '<br />'${txt_bash_code_ssh_vv}''
																	fi
																	echo '
																</dd>
																<dt class="col-sm-3 pe-4 fw-normal">-vvv</dt>
																<dd class="col-sm-9 mb-0 text-secondary">'${txt_bash_code_rsync_vvv}''
																	if [ -n "${var[sshpull]}" ] || [ -n "${var[sshpush]}" ]; then
																		echo '<br />'${txt_bash_code_ssh_vvv}''
																	fi
																	echo '
																</dd>
															</dl>
														</small>
													</div>
												</div>
											</div>
										</td>
									</tr>'
									# Auftragsausführung
									echo '
									<tr>
										<td class="pt-2" style="width: 220px;">
											<span>'${txt_help_job_title}'
												<span class="float-end">
													<a class="btn btn-sm text-dark text-decoration-none py-0" data-bs-toggle="collapse" href="#collapseJob" role="button" aria-expanded="false" aria-controls="collapseJob" style="background-color: #e6e6e6;" title="'${txt_link_note}'">
														<i class="bi bi-info-square text-primary" style="font-size: 1.2rem;"></i><i class="bi bi-caret-down-fill align-middle pb-1 ps-2" style="font-size: 0.5rem;" title=""></i>
													</a>
												</span>
											</span>
										</td>'
										# Befehl
										echo '
										<td style="width: auto;">
											<div class="card">
												<div class="card-body font-monospace" style="font-size: 0.9rem;">
													/usr/syno/synoman'${app_link}'/rsync.sh --job-name="'${backupjob}'"'
													if [ -n "${var[sshpush]}" ]; then
														echo ' --chmod=ugo=rwX'
													fi
													echo '
												</div>
											</div>'
											# Auftrag über Konsole bzw. Aufgabenplaner ausführen
											echo '
											<div class="collapse mt-2" id="collapseJob">
												<div class="card card-body ps-1">
													<small>
														<span class="text-secondary">'${txt_help_job_info}'</span>
														<br /><br />
														<strong class="ps-1">'${txt_help_job_title_terminal}'</strong>
														<ol class="text-secondary">
															<li>'${txt_help_job_step_1}'</li>
														</ol>
														<strong class="ps-1">'${txt_help_job_title_dsm}'</strong>
														<ol class="text-secondary">
															<li>'${txt_help_job_step_2}'</li>
															<li>'${txt_help_job_step_3}'</li>
															<li>'${txt_help_job_step_4}'</li>
															<li>'${txt_help_job_step_5}'</li>
															<li>'${txt_help_job_step_6}'</li>
															<li>'${txt_help_job_step_7}'</li>
															<li>'${txt_help_job_step_8}'</li>
															<li>'${txt_help_job_step_9}'</li>
														</ol>
													</small>
												</div>
											</div>
										</td>
									</tr>'
									# Auftragsabbruch
									echo '
									<tr>
										<td class="pt-2" style="width: 220px;">
											<span>'${txt_kill_job_title}'
												<span class="float-end">
													<a class="btn btn-sm text-dark text-decoration-none py-0" data-bs-toggle="collapse" href="#collapseKill" role="button" aria-expanded="false" aria-controls="collapseKill" style="background-color: #e6e6e6;" title="'${txt_link_note}'">
														<i class="bi bi-info-square text-primary" style="font-size: 1.2rem;"></i><i class="bi bi-caret-down-fill align-middle pb-1 ps-2" style="font-size: 0.5rem;" title=""></i>
													</a>
												</span>
											</span>
										</td>'
										# Befehl
										echo '
										<td style="width: auto;">
											<div class="card">
												<div class="card-body font-monospace" style="font-size: 0.9rem;">
													pkill rsync | rm -f /var/packages/BasicBackup/tmp/pid
												</div>
											</div>'
											# Auftrag über Konsole bzw. Aufgabenplaner ausführen
											echo '
											<div class="collapse mt-2" id="collapseKill">
												<div class="card card-body ps-1">
													<small>
														<span class="text-secondary">'${txt_kill_job_info}'</span>
														<br /><br />
														<strong class="ps-1">'${txt_kill_job_title_terminal}'</strong>
														<ol class="text-secondary">
															<li>'${txt_kill_job_step_1}'</li>
														</ol>
														<strong class="ps-1">'${txt_kill_job_title_dsm}'</strong>
														<ol class="text-secondary">
															<li>'${txt_help_job_step_2}'</li>
															<li>'${txt_help_job_step_3}'</li>
															<li>'${txt_kill_job_step_4}'</li>
															<li>'${txt_kill_job_step_6}'</li>
															<li>'${txt_help_job_step_7}'</li>
															<li>'${txt_help_job_step_8}'</li>
															<li>'${txt_help_job_step_9}'</li>
														</ol>
													</small>
												</div>
											</div>
										</td>
									</tr>
								</tbody>
							</table><br />
						</div>
					</div>
				</div>'
				id=$[${id}+1]
			done
			unset backupjob backuptype backupsource backuptarget sourceicon targeticon id var
		else
			echo '
			<p class="text-center">&nbsp;</p>
			<p class="text-center"><img src="images/icon_256.png" /></p>'
		fi

	# Auftrag löschen
	# --------------------------------------------------------------
	if [[ "${get[query]}" == "delete" ]] && [ -z "${get[delete]}" ]; then
		popup_modal "main" "${txt_popup_delete_conf}" "${txt_popup_delete_job}"
	elif [[ "${get[query]}" == "delete" ]] && [[ "${get[delete]}" == "true" ]]; then
		[ -f "${get_request}" ] && rm "${get_request}"

		# Leerzeichen mit Backslash ausblenden
		get[jobname]=$(urldecode ${get[jobname]})

		# Lösche Backupjob
		[ -f "${usr_backupjobs}/${get[jobname]}.config" ] && rm "${usr_backupjobs}/${get[jobname]}.config" 2>/dev/null

		# Lösche Logfiles
		[ -f "${usr_logfiles}/${get[jobname]}.log" ] && rm "${usr_logfiles}/${get[jobname]}.log" 2>/dev/null
		unset get
		echo '<meta http-equiv="refresh" content="0; url=index.cgi?page=main&section=start">'
	fi
fi
