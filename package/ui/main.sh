#!/bin/bash
# Filename: main.sh - coded in utf-8

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

	echo '
	<div class="accordion accordion-flush" id="main-accordion">'
	
		# Überprüfen des App-Versionsstandes
		# --------------------------------------------------------------
		local_version=$(cat "/var/packages/${app_name}/INFO" | grep ^version | cut -d '"' -f2)
		git_version=$(wget --no-check-certificate --timeout=60 --tries=1 -q -O- "https://raw.githubusercontent.com/toafez/${app_name}/main/INFO" | grep ^version | cut -d '"' -f2)		
		if [ -n "${git_version}" ] && [ -n "${local_version}" ]; then
			if dpkg --compare-versions ${git_version} gt ${local_version}; then
				echo '<p class="text-center">'${txt_update_available}' <a href="https://github.com/toafez/'${app_name}'/releases" target="_blank">'${git_version}'</a></p>'
			fi
		fi

		# Systemumgebung und Systemprotokoll
		# --------------------------------------------------------------
		echo '
		<div class="accordion-item border-0">
			<span class="accordion-header" id="heading0">
				<div class="card border-0">
					<div class="card-header bg-light border-0">
						<a href="#edit0" class="text-dark text-decoration-none" data-bs-toggle="collapse" data-bs-target="#collapse0" aria-expanded="true" aria-controls="collapse0">'

							# rsync Status abfragen
							rsyncd_status=$(systemctl is-enabled rsyncd.service) # activ= Dienst aktiv, unknown= Dienst deaktiert

							# SSH Status abfragen
							sshd_status=$(systemctl is-enabled sshd.service)	# activ= Dienst aktiv, unknown= Dienst deaktiert

							# Benutzer-Home-Ordner abfragen
							userhome_status=$(cat "/etc/synoinfo.conf" | grep userHomeEnable | cut -d '"' -f2) # yes= Dienst aktiv

							# rsync, SSH, Benutzer-Home und admin Rechte abfragen
							if [[ "${rsyncd_status}" == "enabled" ]] && [[ "${sshd_status}" == "enabled" ]] && [[ "${userhome_status}" == "yes" ]] && ( cat /etc/group | grep ^administrators | grep -q ${app_name}) && [ -f /usr/lib/udev/rules.d/99-autopilot.rules ]; then
								echo '&nbsp;<i class="bi bi-check-lg text-success"></i> '
							else
								echo '&nbsp;<i class="bi bi-exclamation-lg text-danger"></i>'
							fi
							echo '&nbsp;'${txt_system_title}'
						</a>
						<div class="float-end">
							<a href="index.cgi?page=view&section=systemlog&file='${usr_systemlog}'" title="'${txt_link_systemlog}'"><i class="bi bi-journal-text text-dark"></i></a>&nbsp;
							<a href="index.cgi?page=main&section=reset" title="'${txt_link_refresh}'"><i class="bi bi-arrow-repeat text-dark"></i></a>
						</div>
					</div>
				</div>
			</span>'

			# Systemumgebung anzeigen
			# --------------------------------------------------------------
			echo '
			<div id="collapse0" class="accordion-collapse collapse" aria-labelledby="heading0" data-bs-parent="#main-accordion">
				<div class="accordion-body">
					<div class="card-body bg-light">
						<div class="row">
							<div class="col-sm-12">'

								# rsync Dienst aktiviert bzw. deaktiviert - Befehl: systemctl status sshd.service
								# --------------------------------------------------------------

								# rsync Dienst aktiv/deaktiviert
								rsync_port_check=$(cat "/etc/synoinfo.conf" | grep rsync_sshd_port | cut -d '"' -f2)

								# rsync Konto aktiv/deaktiviert
								rsync_account_check=$(cat "/etc/synoinfo.conf" | grep rsync_account | cut -d '"' -f2)

								echo '
								<ul class="list-unstyled">
									<li class="text-dark list-style-square">'${txt_rsync_status}'
										<ul class="list-unstyled ps-4">'
											if [[ "${rsyncd_status}" == "enabled" ]]; then
												echo '
												<li class="text-success">'${txt_rsync_service}' '${txt_is_active}' '${txt_rsync_port}' '${rsync_port_check}'</li>'
												#if [[ "${rsync_account_check}" == "yes" ]]; then
												#	echo '<li class="text-secondary">'${txt_rsync_account}' '${txt_is_active}'</li>'
												#else
												#	echo '<li class="text-secondary">'${txt_rsync_account}' '${txt_is_inactive}'</li>'
												#fi
											else
												echo '
												<li class="text-danger">'${txt_rsync_service}' '${txt_is_inactive}'</li>
												<li class="text-secondary">'${txt_rsync_info}'</li>'
											fi
											echo '
										</ul>
									</li>
								</ul>'

								# SSH Dienst aktiviert bzw. deaktiviert - Befehl: systemctl status rsyncd.service
								# --------------------------------------------------------------

								# SSH-Dienst aktiv/deaktivert
								ssh_port_check=$(cat "/etc/synoinfo.conf" | grep ssh_port | cut -d '"' -f2)

								echo '
								<ul class="list-unstyled">
									<li class="text-dark list-style-square">'${txt_ssh_status}'
										<ul class="list-unstyled ps-4">'
											if [[ "${sshd_status}" == "enabled" ]]; then
												echo '
												<li class="text-success">'${txt_ssh_service}' '${txt_is_active}' '${txt_ssh_port}' '${ssh_port_check}'</li>'
											else
												echo '
												<li class="text-danger">'${txt_ssh_service}' '${txt_is_inactive}'</li>
												<li class="text-secondary">'${txt_ssh_info}'</li>'
											fi
											echo '
										</ul>
									</li>
								</ul>'

								# Benutzer-Home-Dienst aktiviert bzw. deaktiviert
								# --------------------------------------------------------------
								echo '
								<ul class="list-unstyled">
									<li class="text-dark list-style-square">'${txt_userhome_status}'
										<ul class="list-unstyled ps-4">'
											if [[ "${userhome_status}" == "yes" ]]; then
												echo '
												<li class="text-success">'${txt_userhome_service}' '${txt_is_active}'</li>'
											else
												echo '
												<li class="text-danger">'${txt_userhome_service}' '${txt_is_inactive}'</li>
												<li class="text-secondary">'${txt_userhome_info}'</li>'
											fi
											echo '
										</ul>
									</li>
								</ul>'

								# USB/SATA-AutoPilot aktiviert bzw. deaktiviert
								# --------------------------------------------------------------
								if [ -f /usr/lib/udev/rules.d/99-autopilot.rules ]; then
									# USB/SATA-AutoPilot deaktivieren
									echo '
									<ul class="list-unstyled">
										<li class="text-dark list-style-square">'${txt_autopilot_status}'&nbsp;
											<span class="float-end">
												<a href="index.cgi?page=view&section=autopilot&file=${usr_logfiles}/autopilot.log" title="'${txt_link_autopilotlog}'"><i class="bi bi-journal-text text-dark"></i></a>&nbsp;
												<a href="index.cgi?page=autoconfig&section=start" title="'${txt_pilot_settings}'"><i class="bi bi-gear-fill text-dark"></i></a>&nbsp;
												<a class="text-danger text-decoration-none" data-bs-toggle="collapse" href="#collapsePilot" role="button" aria-expanded="false" aria-controls="collapsePilot">
													'${note}'
												</a>
											</span>
											<div class="collapse" id="collapsePilot">
												<div class="card card-body">
													<ul class="list-unstyled ps-4">
														<li><strong>'${txt_pilot_switch_console_deactive}'</strong></li>
															<ol>
																<li>'${txt_pilot_console_step_1}'
																	<ul class="list-unstyled ps-3 pt-2">
																		<li>'${txt_pilot_console_step_3}'</li>
																		<li>
																			<small>
																				<pre class="text-dark p-1 border border-1 rounded bg-white">/usr/syno/synoman/webman/3rdparty/BasicBackup/app_permissions.sh "autopilot stop"</pre>
																			</small>
																		</li>
																	</ul>
																</li>
															</ol>
														<li><strong>'${txt_pilot_switch_taskmanager_deactive}'</strong></li>
															<ol>
																<li>'${txt_group_step_1}'</li>
																<li>'${txt_group_step_2}'</li>
																<li>'${txt_group_step_3}'</li>
																<li>'${txt_group_step_4}'</li>
																	<ul class="list-unstyled ps-3 pt-2">
																		<li>'${txt_pilot_console_step_3}'</li>
																		<li>
																			<small>
																				<pre class="text-dark p-1 border border-1 rounded bg-white">/usr/syno/synoman/webman/3rdparty/BasicBackup/app_permissions.sh "autopilot stop"</pre>
																			</small>
																		</li>
																	</ul>
																<li>'${txt_group_step_6}'</li>
																<li>'${txt_group_step_7}'</li>
																<li>'${txt_group_step_8}'</li>
															</ol>
													</ul>
												</div>
											</div>
											<ul class="list-unstyled ps-4">
												<li class="text-success">'${txt_autopilot_service}' '${txt_is_active}'</li>
											</ul>
										</li>
									</ul>'
								else
									# USB/SATA-AutoPilot aktivieren
									echo '
									<ul class="list-unstyled">
										<li class="text-dark list-style-square">'${txt_autopilot_status}'
											<ul class="list-unstyled ps-4">
												<li class="text-danger pb-2">'${txt_autopilot_service}' '${txt_is_inactive}'</li>
												<li><strong>'${txt_pilot_switch_console_active}'</strong></li>
													<ol>
														<li>'${txt_pilot_console_step_1}'
															<ul class="list-unstyled ps-3 pt-2">
																<li>'${txt_pilot_console_step_2}'</li>
																<li>
																	<small>
																		<pre class="text-dark p-1 border border-1 rounded bg-white">/usr/syno/synoman/webman/3rdparty/BasicBackup/app_permissions.sh "autopilot start"</pre>
																	</small>
																</li>
															</ul>
														</li>
													</ol>
												<li><strong>'${txt_pilot_switch_taskmanager_active}'</strong></li>
													<ol>
														<li>'${txt_group_step_1}'</li>
														<li>'${txt_group_step_2}'</li>
														<li>'${txt_group_step_3}'</li>
														<li>'${txt_group_step_4}'</li>
															<ul class="list-unstyled ps-3 pt-2">
																<li>'${txt_pilot_console_step_2}'</li>
																<li>
																	<small>
																		<pre class="text-dark p-1 border border-1 rounded bg-white">/usr/syno/synoman/webman/3rdparty/BasicBackup/app_permissions.sh "autopilot start"</pre>
																	</small>
																</li>
															</ul>
														<li>'${txt_group_step_6}'</li>
														<li>'${txt_group_step_7}'</li>
														<li>'${txt_group_step_8}'</li>
													</ol>
											</ul>
										</li>
									</ul>'
								fi
								echo '
							</div>
						</div>
						<div class="row">
							<div class="col">'
								# Hinweis, das nur eingeschränkte Benutzerrechte vorhanden
								# --------------------------------------------------------------
								#if cat /etc/group | grep ^administrators | grep -q ${app_name} ; then
								echo '
								<ul class="list-unstyled">
									<li class="text-dark list-style-square">'${txt_group_status}'
										<ul class="list-unstyled ps-4">'
											if cat /etc/group | grep ^administrators | grep -q ${app_name} ; then
												echo '
												<li class="text-success">'${txt_group_status_true}'</li>'
											else
												echo '
												<li class="text-danger pb-2">'${txt_group_status_false}'</li>
												<li><strong>'${txt_group_console}'</strong></li>
													<ol>
														<li>'${txt_group_console_step_1}'
															<ul class="list-unstyled ps-3 pt-2">
																<li>'${txt_group_console_step_2}'</li>
																<li>
																	<small>
																		<pre class="text-dark p-1 border border-1 rounded bg-white">'${txt_group_step_5}'</pre>
																	</small>
																</li>
															</ul>
														</li>
													</ol>
												<li><strong>'${txt_group_taskmanager}'</strong></li>
													<ol>
														<li>'${txt_group_step_1}'</li>
														<li>'${txt_group_step_2}'</li>
														<li>'${txt_group_step_3}'</li>
														<li>'${txt_group_step_4}'</li>
															<ul class="list-unstyled ps-3 pt-2">
																<li>'${txt_group_console_step_2}'</li>
																<li>
																	<small>
																		<pre class="text-dark p-1 border border-1 rounded bg-white">'${txt_group_step_5}'</pre>
																	</small>
																</li>
															</ul>
														<li>'${txt_group_step_6}'</li>
														<li>'${txt_group_step_7}'</li>
														<li>'${txt_group_step_8}'</li>
														<li>'${txt_group_step_9}'</li>
													</ol>'
											fi
											echo '
										</ul>
									</li>
								</ul>'

								echo '
							</div>
						</div>
					</div>
				</div>
			</div><br />'

		# Backupaufträge anzeigen
		# --------------------------------------------------------------
		backupconfigs=$(find "$usr_backupjobs" -type f -name "*.config" -maxdepth 1 | sort)
		if [ -n "$backupconfigs" ]; then
			id=1
			IFS="
			"
			for backupconfig in ${backupconfigs}; do
				IFS="$backifs"
				[ -f "${backupconfig}" ] && source "${backupconfig}"
				backupjob=$(echo "${backupconfig##*/}")
				backupjob=$(echo "${backupjob%.*}")
				logfile="${usr_logfiles}/${backupjob}.log"

				# Einstellungen der Verbindungsart
				# ------------------------------------------------------------------------

				# Local settings
				if [ -z "${var[sshpush]}" ] && [ -z "${var[sshpull]}" ]; then
					sourceserver="${txt_local_diskstation}"
					targetserver="${txt_local_diskstation}"
				fi

				# Push settings
				if [ -n "${var[sshpush]}" ] && [ -z "${var[sshpull]}" ]; then
					sourceserver="${txt_local_diskstation}"
					targetserver="${txt_remote_pushserver} ${var[sshpush]}"
				fi

				# Pull settings
				if [ -z "${var[sshpush]}" ] && [ -n "${var[sshpull]}" ]; then
					sourceserver="${txt_remote_pullserver} ${var[sshpull]}"
					targetserver="${txt_local_diskstation}"
					serveraddress="${var[sshpull]}"
				fi

				# Überprüfen der Auftragsversionsstände
				# ------------------------------------------------------------------------
				if dpkg --compare-versions ${job_version} gt ${jobconfig_version}; then
					updatejob="<sup><span class=\"badge bg-danger\" title=\"${txt_update_job_info}\"> ${txt_update_job_run}</span></sup>"
					unset jobconfig_version
				else
					unset updatejob
				fi

				# Ausgabe der Aufträge
				# ------------------------------------------------------------------------
				echo '
				<div class="accordion-item border-0">
					<span class="accordion-header" id="heading'${id}'">
						<div class="card border-0">
							<div class="card-header bg-light border-0">
								<a href="#edit'${id}'" class="text-dark text-decoration-none" data-bs-toggle="collapse" data-bs-target="#collapse'${id}'" aria-expanded="true" aria-controls="collapse'${id}'">'

									# Anzeigen, ob der Auftrag grade ausgeführt wird
									# --------------------------------------------------------------
									process="stopped"
									if ps -fC "bash /usr/syno/synoman/webman/3rdparty/BasicBackup/rsync.sh" | grep -w "${backupjob}$" >/dev/null; then
										process="runs"
										echo '
										<div class="spinner-grow" style="width: 1rem; height: 1rem; color: #FF8C00;" role="status">
											<span class="visually-hidden">Loading...</span>
										</div> '${backupjob}' <span class="text-success">'${txt_backupjob_runs}'</span>'
										while sleep 1; do
											pid=$(ps -aux | grep -w "${backupjob}" | grep -v "grep" | grep -v "rsync --daemon" | awk '{print $2}')
											if [ -z "${pid}" ]; then
												break
											fi
										done &
										echo '<meta http-equiv="refresh" content="0">'
									else
										process="stopped"
										echo '<img src="images/banner_24_orange.png" /> '${backupjob}''
									fi
									echo '
								</a>
								<a href="index.cgi?page=jobedit&section=1&edit=true&jobname='${backupjob}'" title="'${txt_edit_job_title}'">'${updatejob}'</a>
								<div class="float-end">'

									# Auftragsoptionen anzeigen (rechts)
									# --------------------------------------------------------------

									# Logfile
									if [ -f "${logfile}" ]; then
										echo '
										<a href="index.cgi?page=view&section=scriptlog&file='${logfile}'&process='${process}'" title="'${txt_backup_log_title}'">
											<i class="bi bi-journal-text text-dark"></i></a>&nbsp;'
									fi

									# Settings
									echo '
									<a href="index.cgi?page=jobedit&section=1&edit=true&jobname='${backupjob}'" title="'${txt_edit_job_title}'">
										<i class="bi bi-gear-fill text-dark"></i></a>&nbsp;'

									# Trash
									echo '
									<a href="index.cgi?page=main&section=start&query=delete&jobname='${backupjob}'" title="'${txt_edit_job_title}'">
										<i class="bi bi-trash text-dark"></i></a>
								</div>
							</div>
						</div>
					</span>'

					# Auftragseinstellungen anzeigen
					# ------------------------------------------------------------------------
					echo '
					<div id="collapse'${id}'" class="accordion-collapse collapse" aria-labelledby="heading'${id}'" data-bs-parent="#main-accordion">
						<div class="accordion-body">
							<div class="card-body bg-light">
								<div class="row">
									<div class="col-sm-12">'

										# Datensicherungsquelle(n)
										# --------------------------------------------------------------
										echo '
										<ul class="list-unstyled">
											<li class="text-dark list-style-square">'${txt_backup_sources}'
												<ul class="list-unstyled ps-4">
													<li class="text-success">'${sourceserver}'</li>'
													IFS='&'
													read -r -a sources <<< "${var[sources]}"
													IFS="${backupIFS}"
													for source in "${sources[@]}"; do
														source=$(echo "${source}" | sed 's/^[ \t]*//;s/[ \t]*$//')
														echo '<li class="text-secondary">'${source}'</li>'
													done
													unset source
													echo '

												</ul>
											</li>
										</ul>'

										# Datensicherungsziel
										# --------------------------------------------------------------
										echo '
										<ul class="list-unstyled">
											<li class="text-dark list-style-square">'${txt_backup_target}'
												<ul class="list-unstyled ps-4">
													<li class="text-success">'${targetserver}'</li>
													<li class="text-secondary">'${var[target]}'</li>
												</ul>
											</li>
										</ul>'

										# Versionierung
										# --------------------------------------------------------------
										echo '
										<ul class="list-unstyled">
											<li class="text-dark list-style-square">'${txt_versioning}'
												<ul class="list-unstyled ps-4">'
													if [[ "${var[versioning]}" == "true" ]]; then
														echo '<li class="text-success">'${var[versions]}' '${txt_versions}'</li>'
													else
														echo '<li class="text-danger">'${txt_versioning}' '${txt_is_inactive}'</li>'
													fi
													echo '
												</ul>
											</li>
										</ul>'

										# Papierkorb Funktion
										# --------------------------------------------------------------
										echo '
										<ul class="list-unstyled">
											<li class="text-dark list-style-square">'${txt_recycling}'
												<ul class="list-unstyled ps-4">'
													if [[ "${var[versioning]}" == "true" ]]; then
														echo '<li class="text-danger">'${txt_recycle_inactive}'</li>'
													else
														if [[ "${var[recycle]}" -eq 0 ]]; then
															echo '<li class="text-danger">'${txt_recycle_false}'</li>'
														else
															echo '<li class="text-success">'${var[recycle]}' '${txt_recycle_true}'</li>'
														fi
													fi
													echo '
												</ul>
											</li>
										</ul>'

										# Befehl zum ausführen des Auftrages über den DSM-Aufgabenplaner
										# --------------------------------------------------------------
										echo '
										<ul class="list-unstyled">
											<li class="text-dark list-style-square">'${txt_job_step_title}'
												<a class="text-danger text-decoration-none" data-bs-toggle="collapse" href="#collapseJob" role="button" aria-expanded="false" aria-controls="collapseJob">
													'${note}'
												</a>'

												# Hinweise zum ausführen des Auftrages über den DSM-Aufgabenplaner
												# --------------------------------------------------------------
												echo '
												<div class="collapse" id="collapseJob">
													<div class="card card-body">
														<ul class="text-secondary" style="list-style-type: none">
															<li>
																<ol>
																	<li><small>'${txt_job_step_1}'</small></li>
																	<li><small>'${txt_job_step_2}'</small></li>
																	<li><small>'${txt_job_step_3}'</small></li>
																	<li><small>'${txt_job_step_4}'</small></li>
																	<li><small>'${txt_job_step_5}'</small></li>
																	<li><small>'${txt_job_step_6}'</small></li>
																</ol>
															</li>
														</ul>
													</div><br />
												</div>'

												# An den Befehl anhängbare Optionsschalter
												# --------------------------------------------------------------
												echo '
												<ul class="list-unstyled ps-4">
													<li class="text-success pb-2"><br />
														<pre class="text-dark p-2 border border-1 rounded bg-white">'
															echo -n 'bash /usr/syno/synoman'${app_link}'/rsync.sh <span class="text-success">--job-name="<span class="text-dark">'${backupjob}'</span>"</span>'; \
															[ -n "${var[sshpush]}" ] && echo -n '<span class="text-danger"> --chmod=ugo=rwX</span></pre>' || echo -n '</pre>'
															echo -n '
														</pre>
													</li>
													<li>
														<span class="text-dark">'${txt_bash_code_option}'</span>
														<dl class="row text-secondary">
															<dt class="col-sm-3"><small class="font-monospace text-success pe-4">-j=</small><small class="font-monospace text-success">--job-name=</small></dt>
															<dd class="col-sm-9 mb-0"><small>'${txt_bash_code_jobname}'</small></dd>
															<dt class="col-sm-3"><small class="font-monospace pe-4">-n </small><small class="font-monospace">--dry-run</small></dt>
															<dd class="col-sm-9 mb-0"><small>'${txt_bash_code_dryrun}'</small></dd>
															<dt class="col-sm-3"><small class="font-monospace pe-4">-v </small></dt>
															<dd class="col-sm-9 mb-0">
																<small>'${txt_bash_code_rsync_v}'</small>'
																if [ -n "${var[sshpull]}" ] || [ -n "${var[sshpush]}" ]; then
																	echo '<br /><small>'${txt_bash_code_ssh_v}'</small>'
																fi
																echo '
															</dd>
															<dt class="col-sm-3"><small class="font-monospace pe-4">-vv</small></dt>
															<dd class="col-sm-9 mb-0">
																<small>'${txt_bash_code_rsync_vv}'</small>'
																if [ -n "${var[sshpull]}" ] || [ -n "${var[sshpush]}" ]; then
																	echo '<br /><small>'${txt_bash_code_ssh_vv}'</small>'
																fi
																echo '
															</dd>
															<dt class="col-sm-3"><small class="font-monospace pe-4">-vvv</small></dt>
															<dd class="col-sm-9 mb-0">
																<small>'${txt_bash_code_rsync_vvv}'</small>'
																if [ -n "${var[sshpull]}" ] || [ -n "${var[sshpush]}" ]; then
																	echo '<br /><small>'${txt_bash_code_ssh_vvv}'</small>'
																fi
																echo '
															</dd>
															<dt class="col-sm-3"><small class="font-monospace pe-4">-c= </small><small class="font-monospace">--chmod=</small></dt>
															<dd class="col-sm-9 mb-0"><small>'${txt_bash_code_perms}'</small></dd>'
															if [ -n "${var[sshpush]}" ]; then
																echo '
																<dt class="col-sm-3"><small class="font-monospace pe-4">&nbsp;&nbsp;&nbsp;</small><small class="font-monospace text-danger">--chmod=ugo=rwX</small></dt>
																<dd class="col-sm-9 mb-0"><small>'${txt_bash_code_perms_push}'</small></dd>'
															fi
															echo '
														</dl>
													</li>
												</ul>
											</li>
										</ul>'
										echo '
									</div>
								</div>
							</div>
						</div>
					</div>
				</div><br />'
				id=$[${id}+1]
			done
			unset backupjob id var
		else
			echo '
			<p class="text-center">&nbsp;</p>
			<p class="text-center"><img src="images/icon_256.png" /></p>'
		fi
		echo '
	</div>'

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
