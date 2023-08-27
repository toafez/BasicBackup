#!/bin/bash
# Filename: main.sh - coded in utf-8

#                       Basic Backup
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
		git_version=$(wget --no-check-certificate --timeout=60 --tries=1 -q -O- "https://raw.githubusercontent.com/toafez/${app_name}/main/INFO.sh" | grep ^version | cut -d '"' -f2)		
		if [ -n "${git_version}" ] && [ -n "${local_version}" ]; then
			if dpkg --compare-versions ${git_version} gt ${local_version}; then
			echo '
			<div class="row">
				<div class="ol-sm-12">
					<h5>'${txt_update_available}'</h5>
					<table class="table table-borderless table-hover table-sm">
						<thead></thead>
						<tbody>
							<tr>
								<td scope="row" class="row-sm-auto">
									'${txt_update_from}' <span class="text-danger">'${local_version}'</span> '${txt_update_to}' <span class="text-success">'${git_version}'</span>
									<td class="text-end"> 
										<a href="https://github.com/toafez/'${app_name}'/releases" class="btn btn-light btn-sm text-success text-decoration-none" target="_blank">Update</a>
									</td>
								</td>'
									
								echo '
							</tr>
						</tbody>
					</table><hr />
				</div>
			</div>'	
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

							# rsync, SSH, Benutzer-Home und admin Rechte abfragen
							if [[ "${rsyncd_status}" == "enabled" ]] && [[ "${sshd_status}" == "enabled" ]] && ( cat /etc/group | grep ^administrators | grep -q ${app_name}) ; then
								echo '&nbsp;<i class="bi bi-check-lg text-success"></i> '
							else
								echo '&nbsp;<i class="bi bi-exclamation-lg text-danger"></i>'
							fi
							echo '&nbsp;'${txt_system_title}'
						</a>
						<div class="float-end">
							&nbsp;
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
								</ul>
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
												<li class="text-success">'${txt_group_status_true}'. <a href="#help-permissions" class="text-danger text-decoration-none" data-bs-toggle="modal" data-bs-target="#help-permissions">'${txt_button_restrict_permission}'</a></li>'
											else
												echo '
												<li class="text-danger pb-2">'${txt_group_status_false}' <a href="#help-permissions" class="text-primary text-decoration-none" data-bs-toggle="modal" data-bs-target="#help-permissions">'${txt_button_extend_permission}'</a></li>'
											fi
											echo '
										</ul>
									</li>
								</ul>
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
								<div class="row">'

									# Datensicherungsquelle
									# --------------------------------------------------------------
									function backup_sources()
									{
										echo '
										<span>'${txt_source_shares}'</span>
										<ul class="list-unstyled ps-3">'
											IFS='&'
											read -r -a sources <<< "${var[sources]}"
											IFS="${backupIFS}"
											for source in "${sources[@]}"; do
												source=$(echo "${source}" | sed 's/^[ \t]*//;s/[ \t]*$//')
												echo '<li class="text-secondary">'${source}'</li>'
											done
											unset source
											echo '
										</ul>'
									}

									# Datensicherungsziel
									# --------------------------------------------------------------
									function backup_target()
									{
										echo '
										<span>'${txt_target_share}'</span>
										<ul class="list-unstyled ps-3">
											<li class="text-secondary">'${var[target]}'</li>
										</ul>'
									}

									# Versionierung
									# --------------------------------------------------------------
									function target_versioning()
									{
										echo '
										<span>'${txt_versioning}'</span>
										<ul class="list-unstyled ps-3">'
											if [[ "${var[versioning]}" == "true" ]]; then
												echo '<li class="text-secondary">'${var[versions]}' '${txt_versions}'</li>'
											else
												echo '<li class="text-danger">'${txt_versioning}' '${txt_is_inactive}'</li>'
											fi
											echo '
										</ul>'
									}

									# Papierkorb Funktion
									# --------------------------------------------------------------
									function target_recycle()
									{
										echo '
										<span>'${txt_recycling}'</span>
										<ul class="list-unstyled ps-3">'
											if [[ "${var[versioning]}" == "true" ]]; then
												echo '<li class="text-danger">'${txt_recycle_inactive}'</li>'
											else
												if [[ "${var[recycle]}" -eq 0 ]]; then
													echo '<li class="text-danger">'${txt_recycle_false}'</li>'
												else
													echo '<li class="text-secondary">'${var[recycle]}' '${txt_recycle_true}'</li>'
												fi
											fi
											echo '
										</ul>'
									}

									# Quell-Server
									# --------------------------------------------------------------
									echo '
									<div class="col-sm-6 ps-4 pt-3">'
										if [ -z "${var[sshpush]}" ] && [ -z "${var[sshpull]}" ]; then
											echo '
											<span class="fs-5">'${txt_backup_sources}'</span>
											<ul class="list-unstyled ps-3">
												<li class="text-success">'${txt_local_diskstation}'</li>
											</ul>'
											 backup_sources
										elif [ -n "${var[sshpush]}" ]; then
											echo '
											<span class="fs-5">'${txt_backup_sources}'</span>
											<ul class="list-unstyled ps-3">
												<li class="text-success">'${txt_local_diskstation}'</li>
											</ul>'
											backup_sources
										elif [ -n "${var[sshpull]}" ]; then 
											echo '
											<span class="fs-5">'${txt_backup_target}'</span>
											<ul class="list-unstyled ps-3">
												<li class="text-success">'${txt_local_diskstation}'</li>
											</ul>'
											backup_target
											target_versioning
											target_recycle
										fi
										echo '
									</div>'

									# Ziel-Server
									# --------------------------------------------------------------
									echo '
									<div class="col-sm-6 pe-4 pt-3">'
										if [ -z "${var[sshpush]}" ] && [ -z "${var[sshpull]}" ]; then
											echo '
											<span class="fs-5">'${txt_backup_target}'</span>
											<ul class="list-unstyled ps-3">
												<li class="text-success">'${txt_local_diskstation}'</li>
											</ul>'
											backup_target
											target_versioning
											target_recycle
										elif [ -n "${var[sshpush]}" ] && [[ "${var[target]}" == /volume* ]]; then
											echo '
											<span class="fs-5">'${txt_backup_target}'</span>
											<ul class="list-unstyled ps-3">
												<li class="text-success">'${txt_remote_diskstation}' <span class="text-secondary">('${var[sshpush]}')</span></li>
											</ul>'
											backup_target
											target_versioning
											target_recycle
										elif [ -n "${var[sshpull]}" ] && [[ "${var[sources]}" == */volume* ]]; then
											echo '
											<span class="fs-5">'${txt_backup_sources}'</span>
											<ul class="list-unstyled ps-3">
												<li class="text-success">'${txt_remote_diskstation}' <span class="text-secondary">('${var[sshpull]}')</span></li>
											</ul>'
											backup_sources
										else
											echo '
											<span class="fs-5">'${txt_backup_target}'</span>
											<ul class="list-unstyled ps-3">
												<li class="text-success">'${txt_remote_server}' <span class="text-secondary">('${var[sshpush]}''${var[sshpull]}')</span></li>
											</ul>'
											backup_target
											target_versioning
											target_recycle
										fi
										echo '
									</div>'
									echo '
								</div>
								<div class="col-sm-12 ps-3 pt-3 pe-3">'
									
									# Befehl zum ausführen des Auftrages
									# --------------------------------------------------------------
									echo '
									<span>'${txt_job_step_title}'
										<a class="text-danger text-decoration-none" data-bs-toggle="collapse" href="#collapseJob" role="button" aria-expanded="false" aria-controls="collapseJob">
											'${note}'
										</a>
									</span>'

									# Hinweise zum ausführen des Auftrages über den DSM-Aufgabenplaner
									# --------------------------------------------------------------
									echo '
									<div class="collapse ps-3 me-3" id="collapseJob">
										<div class="card card-body ps-1">
											<ol class="text-secondary">
												<li><small>'${txt_job_step_1}'</small></li>
												<li><small>'${txt_job_step_2}'</small></li>
												<li><small>'${txt_job_step_3}'</small></li>
												<li><small>'${txt_job_step_4}'</small></li>
												<li><small>'${txt_job_step_5}'</small></li>
												<li><small>'${txt_job_step_6}'</small></li>
											</ol>
										</div><br />
									</div>
									<div class="form-group ps-3">'

										# Befehl
										# --------------------------------------------------------------
										codeblock_1=$(echo 'bash /usr/syno/synoman'${app_link}'/rsync.sh --job-name="'${backupjob}'"')
										codeblock_2=$([ -n "${var[sshpush]}" ] && echo '--chmod=ugo=rwX')

										echo '
										<div class="me-3">
											<textarea class="form-control" style="font-family: Consolas,monaco,monospace; font-size: 0.9rem;" rows="2" readonly>'${codeblock_1}' '${codeblock_2}'</textarea>
											<br />
										</div>
									</div>'

									# Optionsschalter
									# --------------------------------------------------------------
									echo '
									<span>'${txt_bash_code_option}'</span>
									<div class="card card-body ms-3 me-3">
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
									</div>	
								</div>
								<p>&nbsp;</p>
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
