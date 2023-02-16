#!/bin/bash
# Filename: jobedit.sh - coded in utf-8
job_version="0.7-000"

#						Basic Backup
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

pageview="off"

# Horizontale Navigationsleiste laden
# --------------------------------------------------------------
mainnav

# Funktion: Lokale Datensicherungsquelle(n) auswählen
# --------------------------------------------------------------
function local_sources()
{
	while IFS= read -r volume; do
		IFS="${backupIFS}"
		[[ -z "${volume}" ]] && continue
		echo -n '<span class="text-secondary ps-2"><strong>'${volume}'</strong></span><br />'
		if [[ "${volume}" == /volumeUSB[[:digit:]]/usbshare* || "${volume}" == /volumeSATA[[:digit:]]/satashare* ]]; then
			echo -n '<div class="text-secondary ps-4 pb-1"><small>'${txt_note_mountpoint}'</small></div>'
		fi
		# Vertikales Dropdownmenü (checktree.js, fadetree.js, stylesheet.css)
		echo '
		<ul class="checktree" style="list-style-type: none">'
			while IFS= read -r share; do
				IFS="${backupIFS}"
				[[ -z "${share}" ]] && continue

				IFS='&'
				read -r -a shares <<< "${var[sources]}"
				IFS="${backupIFS}"
				for dir in "${shares[@]}"; do
					dir=$(echo "${dir}" | sed 's/^[ \t]*//;s/[ \t]*$//')
					[[ "${share}" == "${dir}" ]] && break
				done
				unset shares

				echo -n '
				<li>
					<!-- <a href="#" class="a_toggle text-secondary" style="text-decoration: none;">+</a> -->
					<input type="checkbox" class="form-check-input" id="share_'${count}'" name="share_'${count}'" value="'${share}'"'; \
						[[ "${share}" == "${dir}" ]] && echo -n ' checked />' || echo -n ' />'; echo -n '
					<label for="share_'${count}'" class="form-check-label text-dark">'${share##*/}'</label>'
					count=$[${count}+1]

					echo '
					<ul class="show" style="list-style-type: none">'
						while IFS= read -r folder; do
							IFS="${backupIFS}"
							[[ -z "${folder}" ]] && continue

							IFS='&'
							read -r -a folders <<< "${var[sources]}"
							IFS="${backupIFS}"
							for sub in "${folders[@]}"; do
								sub=$(echo "${sub}" | sed 's/^[ \t]*//;s/[ \t]*$//')
								[[ "${folder}" == "${sub}" ]] && break
							done

							echo -n '
							<li>
								<input type="checkbox" class="form-check-input" id="folder_'${count}'" name="folder_'${count}'" value="'${folder}'"'; \
									[[ "${folder}" == "${sub}" ]] && echo -n ' checked />' || echo -n ' />'; echo -n '
								<label for="folder_'${count}'" class="form-check-label text-secondary">'${folder##*/}'</label>
							</li>'
							count=$[${count}+1]

						done <<< "$( find ${share}/* -maxdepth 0 -type d ! -path '*/lost\+found' ! -path '*/\@*' ! -path '*/\#recycle' ! -path '*/\$RECYCLE.BIN' )"
						echo -n '
					</ul>
				</li>'
			done <<< "$( find ${volume}/* -maxdepth 0 -type d ! -path '*/lost\+found' ! -path '*/\@*' ! -path '*/\$RECYCLE.BIN' ! -path '*/Repair' ! -path '*/System Volume Information' )"
			echo '
		</ul>
		<script>
			$(function(){
				$("ul.checktree").checktree();
			});
		</script>'
	done <<< "$( find ${1} -type d -maxdepth 0 )"
	unset volume share folder count
}

# Funktion: Lokales Datensicherungsziel auswählen
# --------------------------------------------------------------
function local_target()
{
	while IFS= read -r volume; do
		IFS="${backupIFS}"
		[[ -z "${volume}" ]] && continue
		while IFS= read -r share; do
			IFS="${backupIFS}"
			[[ -z "${share}" ]] && continue
			echo -n '<option value="'${share}'"'; \
				[[ "${var[${2}]}" == "${share}" ]] && echo -n ' selected>' || echo -n '>'
			echo ''${share}'</option>'
		done <<< "$( find ${volume}/* -type d ! -path '*/lost\+found' ! -path '*/\@*' ! -path '*/\$RECYCLE.BIN' ! -path '*/Repair' ! -path '*/System Volume Information' -maxdepth 0 )"
	done <<< "$( find ${1} -maxdepth 0 -type d )"
	unset volume share
}

# Funktion: Auftrags- bzw. Scriptdaten zurücksetzen
# --------------------------------------------------------------
function reset_job_settings()
{
	"${set_keyvalue}" "${post_request}" "var[jobname]" ""
	"${set_keyvalue}" "${post_request}" "var[sendemail]" ""
	"${set_keyvalue}" "${post_request}" "var[emailfrom]" ""
	"${set_keyvalue}" "${post_request}" "var[emailto]" ""
}

# Funktion: Auftrags- bzw. Scriptdaten behalten
# --------------------------------------------------------------
function keep_job_settings()
{
	"${set_keyvalue}" "${post_request}" "var[jobname]" "${var[jobname]}"
	"${set_keyvalue}" "${post_request}" "var[sendemail]" "${var[sendemail]}"
	"${set_keyvalue}" "${post_request}" "var[emailfrom]" "${var[emailfrom]}"
	"${set_keyvalue}" "${post_request}" "var[emailto]" "${var[emailto]}"
}

# Funktion: Zielserver zurücksetzen
# --------------------------------------------------------------
function reset_target_server()
{
	"${set_keyvalue}" "${post_request}" "var[targetserver]" ""
}

# Funktion: Zielserver behalten
# --------------------------------------------------------------
function keep_target_server()
{
	"${set_keyvalue}" "${post_request}" "var[targetserver]" "${var[targetserver]}"
}

# Funktion: Zielordner zurücksetzen
# --------------------------------------------------------------
function reset_backup_target()
{
	"${set_keyvalue}" "${post_request}" "var[target]" ""
	"${set_keyvalue}" "${post_request}" "var[localshare]" ""
	"${set_keyvalue}" "${post_request}" "var[localfolder]" ""
}

# Funktion: Zielordner behalten
# --------------------------------------------------------------
function keep_backup_target()
{
	"${set_keyvalue}" "${post_request}" "var[target]" "${var[target]}"
	"${set_keyvalue}" "${post_request}" "var[localshare]" "${var[localshare]}"
	"${set_keyvalue}" "${post_request}" "var[localfolder]" "${var[localfolder]}"
}

# Funktion: Quellserver zurücksetzen
# --------------------------------------------------------------
function reset_source_server()
{
	"${set_keyvalue}" "${post_request}" "var[sourceserver]" ""
}

# Funktion: Quellserver behalten
# --------------------------------------------------------------
function keep_source_server()
{
	"${set_keyvalue}" "${post_request}" "var[sourceserver]" "${var[sourceserver]}"
}

# Funktion: Quellordner zurücksetzen
# --------------------------------------------------------------
function reset_backup_source()
{
	"${set_keyvalue}" "${post_request}" "var[sources]" ""
}

# Funktion: Quellordner behalten
# --------------------------------------------------------------
function keep_backup_source()
{
	"${set_keyvalue}" "${post_request}" "var[sources]" "${var[sources]}"
}

# Funktion: Remote Verbindungen zurücksetzen
# --------------------------------------------------------------
function reset_remote_server()
{
	"${set_keyvalue}" "${post_request}" "var[sshuser]" ""
	"${set_keyvalue}" "${post_request}" "var[sshpush]" ""
	"${set_keyvalue}" "${post_request}" "var[sshpull]" ""
	"${set_keyvalue}" "${post_request}" "var[sshport]" ""
	"${set_keyvalue}" "${post_request}" "var[sshmac]" ""
	"${set_keyvalue}" "${post_request}" "var[privatekey]" ""
	"${set_keyvalue}" "${post_request}" "var[wakeup]" ""
	"${set_keyvalue}" "${post_request}" "var[shutdown]" ""
}

# Funktion: Remote Verbindungen behalten
# --------------------------------------------------------------
function keep_remote_server()
{
	"${set_keyvalue}" "${post_request}" "var[sshuser]" "${var[sshuser]}"
	"${set_keyvalue}" "${post_request}" "var[sshpush]" "${var[sshpush]}"
	"${set_keyvalue}" "${post_request}" "var[sshpull]" "${var[sshpull]}"
	"${set_keyvalue}" "${post_request}" "var[sshport]" "${var[sshport]}"
	"${set_keyvalue}" "${post_request}" "var[sshmac]" "${var[sshmac]}"
	"${set_keyvalue}" "${post_request}" "var[privatekey]" "${var[privatekey]}"
	"${set_keyvalue}" "${post_request}" "var[wakeup]" "${var[wakeup]}"
	"${set_keyvalue}" "${post_request}" "var[shutdown]" "${var[shutdown]}"
}


# Auftrag erstellen bzw. bearbeiten
# --------------------------------------------------------------
echo '
<div class="row">
	<div class="col">'
		# Alle Einstellungen löschen und zur Startseite wechseln
		if [[ "${get[section]}" == "abort" ]]; then
			unset var
			[ -f "${get_request}" ] && rm "${get_request}"
			[ -f "${post_request}" ] && rm "${post_request}"
			echo '<meta http-equiv="refresh" content="0; url=index.cgi?page=main&section=start">'
		fi

		# Start
		# -------------------------------------------------------------------------------
		if [[ "${get[page]}" == "jobedit" ]]; then

			echo '
			<form action="index.cgi?page=jobedit" method="post" id="jobedit-form" autocomplete="on">'

				# Alle Variabeln auf Null setzen
				if [[ "${get[section]}" == "1" ]]; then
					unset var POST_STRING POST_vars
					reset_job_settings
					reset_target_server
					reset_backup_target
					reset_source_server
					reset_backup_source
					reset_remote_server
					[ -f "${post_request}" ] && rm "${post_request}"
					#[ -f "${post_request}" ] && source "${post_request}"
				fi

				# Auftrag laden
				if [[ "${get[edit]}" == "true" ]] && [ -f "${usr_backupjobs}/$(urldecode ${get[jobname]}).config" ]; then
					source "${usr_backupjobs}/$(urldecode ${get[jobname]}).config"
					var[jobname]=$(urldecode ${get[jobname]})
					old_jobname=$(urldecode ${get[jobname]})

					if [ -z "${var[sshpush]}" ] && [ -z "${var[sshpull]}" ]; then
						var[targetserver]="local"
						var[sourceserver]="local"
					fi
					if [ -n "${var[sshpush]}" ] && [ -z "${var[sshpull]}" ]; then
						var[targetserver]="remote"
						var[sourceserver]="local"
					fi
					if [ -z "${var[sshpush]}" ] && [ -n "${var[sshpull]}" ]; then
						var[targetserver]="local"
						var[sourceserver]="remote"
					fi

					# Überprüfen der Auftragsversionsstände um Neuigkeiten oder Updates einzublenden
					# ------------------------------------------------------------------------
					if dpkg --compare-versions ${job_version} gt ${jobconfig_version}; then
						new="<sup><span class=\"badge bg-danger text-uppercase\">New</span></sup>"
						update="<sup><span class=\"badge bg-danger text-uppercase\">Update</span></sup>"
					fi
				fi

				# Seite 1
				# ---------------------------------------------------------------------------
				if [[ "${get[section]}" == "1" ]] || [[ "${var[section]}" == "1" ]]; then
					[[ "${pageview}" == "on" ]] && echo "Seite (page-1) - Primäre Ansicht"

					# Variablen zurücksetzen: Kommend von Seite 2 - Primäre Ansicht
					#...
					if [[ "${var[goback]}" == "page-1" ]]; then
						var[goback]=""
						"${set_keyvalue}" "${post_request}" "var[goback]" ""
						if [[ "${get[edit]}" != "true" ]]; then
							[ -f "${post_request}" ] && rm "${post_request}"
							keep_job_settings
							if [[ "${var[targetserver]}" == "remote" ]] || [[ "${var[sourceserver]}" == "remote" ]]; then
								keep_backup_target
								keep_remote_server
							else
								reset_backup_target
								reset_remote_server
							fi
							[ -f "${post_request}" ] && source "${post_request}"
						fi
					fi


					# Seite 1 - Primäre Ansicht - Auftrag
					# ---------------------------------------------------------------------------
					echo '
					<div class="card border-0">
						<div class="card-header ps-0 pb-0 bg-body border-0">'
							if [[ "${get[edit]}" == "true" ]]; then
								echo '<h5>'${txt_job_title}' <span class="text-blue">'$(urldecode ${get[jobname]})'</span> '${txt_job_edit}'</h5>'
							else
								echo '<h5>'${txt_job_title}' '${txt_job_create}'</h5>'
							fi
							echo '
						</div>
					</div>
					<div class="card-body">'
						# Auftrags- bzw. Scriptname (backupjob)
						# ...
						echo '
						<div class="row g-3 mb-3">
							<div class="col">
								<label for="jobname" class="form-label text-secondary">'${txt_jobname_label}'</label>
								<div class="input-group input-group-sm">
									<input type="text" pattern="'${txt_jobname_regex}'" class="form-control form-control-sm" name="jobname" id="jobname" value="'${var[jobname]}'" placeholder="'${txt_jobname_format}'" aria-label="" aria-describedby="jobname" required />
									 <span class="input-group-text" id="inputGroup-sizing-sm">.sh</span>
								</div>
							</div>
						</div>'
						# E-Mail Adresse
						# ...
						smtp_mail=$(cat "/usr/syno/etc/synosmtp.conf" | grep smtp_from_mail | cut -d '"' -f2)
						event_mail=$(cat "/usr/syno/etc/synosmtp.conf" | grep eventmails | cut -d '"' -f2)

						echo '
						<div class="row g-3 mb-3">
							<div class="col">
								<label for="sendemail" class="form-label text-secondary">'${txt_sendemail_label}'</label>
								<select id="sendemail" name="sendemail" class="form-select form-select-sm" required >'
									echo -n '<option value="false"'; \
									[[ "${var[sendemail]}" == "false" ]] && echo -n ' selected>' || echo -n '>'
									echo ''${txt_signal_opt_false}'</option>'
									echo -n '<option value="true"'; \
									[[ "${var[sendemail]}" == "true" ]] && echo -n ' selected>' || echo -n '>'
									echo ''${txt_sendemail_true}'</option>'
									echo -n '<option value="problem"'; \
									[[ "${var[sendemail]}" == "problem" ]] && echo -n ' selected>' || echo -n '>'
									echo ''${txt_sendemail_problem}'</option>'
									echo '
								</select>
							</div>
							<div class="col">
								<label for="emailfrom" class="form-label text-secondary">'${txt_emailfrom_label}'
									<a class="text-danger text-decoration-none" data-bs-toggle="collapse" href="#emailfrom-note" role="button" aria-expanded="false" aria-controls="emailfrom-note">'${note}'</a>
									<div class="collapse" id="emailfrom-note">
										<div class="card card-body border-0">
											<small>'${txt_emailfrom_note}'</small>
										</div>
									</div>
								</label>
								<input type="emailfrom" class="form-control form-control-sm" name="emailfrom" id="emailfrom" value="'${var[emailfrom]:-${smtp_mail}}'" placeholder="'${txt_email_format}'" />
							</div>
							<div class="col">
								<label for="emailto" class="form-label text-secondary">'${txt_emailto_label}'</label>
								<input type="emailto" class="form-control form-control-sm" name="emailto" id="emailto" value="'${var[emailto]:-${event_mail}}'" placeholder="'${txt_email_format}'" />
							</div>
						</div>'

						# Signalsteuerung
						# ...
						echo '
						<div class="row g-3 mb-3">
							<div class="col">
								<label for="optical" class="form-label text-secondary">'${txt_signal_label_optical}'
									<a class="text-danger text-decoration-none" data-bs-toggle="collapse" href="#optical-note" role="button" aria-expanded="false" aria-controls="optical-note">'${note}'</a>
									<div class="collapse" id="optical-note">
										<div class="card card-body border-0">
											<small>'${txt_signal_optical_note}'</small>
										</div>
									</div>
								</label>
								<select id="optical" name="optical" class="form-select form-select-sm" required >'
									echo -n '<option value="false"'; \
									[[ "${var[optical]}" == "false" ]] && echo -n ' selected>' || echo -n '>'
									echo ''${txt_signal_opt_false}'</option>'
									echo -n '<option value="true"'; \
									[[ "${var[optical]}" == "true" ]] && echo -n ' selected>' || echo -n '>'
									echo ''${txt_signal_opt_true}'</option>'
									echo '
								</select>
							</div>
							<div class="col">
								<label for="acoustical" class="form-label text-secondary">'${txt_signal_label_acoustical}'
									<a class="text-danger text-decoration-none" data-bs-toggle="collapse" href="#acoustical-note" role="button" aria-expanded="false" aria-controls="acoustical-note">'${note}'</a>
									<div class="collapse" id="acoustical-note">
										<div class="card card-body border-0">
											<small>'${txt_signal_acoustical_note}'</small>
										</div>
									</div>
								</label>
								<select id="acoustical" name="acoustical" class="form-select form-select-sm" required>'
									echo -n '<option value="false"'; \
									[[ "${var[acoustical]}" == "false" ]] && echo -n ' selected>' || echo -n '>'
									echo ''${txt_signal_opt_false}'</option>'
									echo -n '<option value="true"'; \
									[[ "${var[acoustical]}" == "true" ]] && echo -n ' selected>' || echo -n '>'
									echo ''${txt_signal_opt_true}'</option>'
									echo '
								</select>
							</div>
						</div>'

						# Primäre Schaltfläche einblenden, solange die erweiterte Ansicht ausgeblendet ist
						# ...
						echo '
						<p class="text-end"><br />
							<input type="hidden" name="expand-content" value="false">
							<a href="index.cgi?page=jobedit&section=abort" class="btn btn-secondary btn-sm">'${txt_button_Cancel}'</a>&nbsp;&nbsp;&nbsp;
							<button class="btn btn-secondary btn-sm" type="submit" name="section" value="2">'${txt_button_Continue}'</button><br />
						</p>'
						echo '
					</div>'
				fi

				# Seite 2
				# ---------------------------------------------------------------------------
				if [[ "${var[section]}" == "2" ]]; then
					[[ "${pageview}" == "on" ]] && echo "Seite (page-2) - Primäre Ansicht"

					[ -f "${post_request}" ] && source "${post_request}"

					# Falls Name des Backupjobs bereits vorhanden, dann Popup - Fehler
					if [ -z "${get[edit]}" ] && [ -f "${usr_backupjobs}/${var[jobname]}.config" ]; then
						popup_modal "jobedit" "${txt_popup_input_error}" "${txt_popup_jobname_excists}" "false"
						# Syntax    "Page   " "Title                   " "Content                     " "expand-content false/true"
					fi

					if [ -z "${var[expand-content]}" ] || [[ "${var[expand-content]}" == "false" ]]; then

						# Variablen zurücksetzen: Kommend von Seite 2a - Erweiterte Ansicht
						#...
						if [[ "${var[goback]}" == "page-2" ]]; then
							var[goback]=""
							"${set_keyvalue}" "${post_request}" "var[goback]" ""
							if [[ "${get[edit]}" != "true" ]]; then
								[ -f "${post_request}" ] && rm "${post_request}"
								keep_job_settings
								keep_target_server
								if [[ "${var[targetserver]}" == "remote" ]]; then
									reset_backup_target
									reset_remote_server
								fi
								if [[ "${var[targetserver]}" == "local" ]]; then
									reset_backup_target
								fi
								[ -f "${post_request}" ] && source "${post_request}"
							fi
						fi
					fi

					# Seite 2 - Primäre Ansicht - Datensicherungsziel
					# -----------------------------------------------------------------------
					echo '
					<div class="card border-0">
						<div class="card-header ps-0 pb-0 bg-body border-0">'
							[[ "${get[edit]}" == "true" ]] && echo '<h5>'${txt_job_title}' <span class="text-blue">'$(urldecode ${get[jobname]})'</span> - '${txt_target_title}' '${txt_job_edit}'</h5>' || echo '<h5>'${txt_target_title}' '${txt_job_select}'</h5>'
							echo '
						</div>
					</div>
					<div class="card-body">'
						# Zielserver (targetserver)
						# ...
						echo '
						<div class="row g-3 mb-3">
							<div class="col">
								<label for="targetserver" class="form-label text-secondary">'${txt_targetserver_label}''
									if [[ "${var[targetserver]}" == "remote" ]]; then
										echo '
										<button type="button" class="btn btn-link btn-sm text-danger text-decoration-none" data-bs-toggle="modal" data-bs-target="#help-ssh-local">
											<sup>'${txt_sshbuild_note}'</sup>
										</button>'
									fi
									echo '
								</label>'
								if [[ "${var[expand-content]}" == "true" ]] && [ -n "${var[targetserver]}" ]; then
									# Disabled: Zielserver
									# ...
									if [[ "${var[targetserver]}" == "local" ]]; then
										echo '<input type="text" class="form-control form-control-sm" placeholder="'${txt_targetserver_opt_local}'" disabled>'
									elif [[ "${var[targetserver]}" == "remote" ]]; then
										echo '<input type="text" class="form-control form-control-sm" placeholder="'${txt_targetserver_opt_remote}'" disabled>'
									fi
								else
									echo -n '
									<select id="targetserver" name="targetserver" class="form-select form-select-sm"'; \
									[[ "${var[expand-content]}" == "true" ]] && echo ' disabled>' || echo ' required>'
										echo '<option value="" class="text-secondary" selected disabled>'${txt_targetserver_opt}'</option>'
										echo -n '<option value="local"'; \
										[[ "${var[targetserver]}" == "local" ]] && echo -n ' selected>' || echo -n '>'
										echo ''${txt_targetserver_opt_local}'</option>'
										echo -n '<option value="remote"'; \
										[[ "${var[targetserver]}" == "remote" ]] && echo -n ' selected>' || echo -n '>'
										echo ''${txt_targetserver_opt_remote}'</option>'
										echo '
									</select>'
								fi
								echo '
							</div>
						</div>'

						if [ -z "${var[expand-content]}" ] || [[ "${var[expand-content]}" == "false" ]]; then

							# Primäre Schaltfläche einblenden, solange die erweiterte Ansicht ausgeblendet ist
							# ...
							echo '
							<p class="text-end"><br />
								<input type="hidden" name="expand-content" value="true">
								<input type="hidden" name="goback" value="page-1">
								<a href="index.cgi?page=jobedit&section=abort" class="btn btn-secondary btn-sm">'${txt_button_Cancel}'</a>&nbsp;&nbsp;&nbsp;
								<button class="btn btn-secondary btn-sm disable_validation" type="submit" name="section" value="1">'${txt_button_Back}'</button>&nbsp;&nbsp;&nbsp;
								<button class="btn btn-secondary btn-sm" type="submit" name="section" value="2">'${txt_button_Continue}'</button><br />
							</p>'
						fi

						# Seite 2a - Erweiterte Ansicht - Zielordner
						# -----------------------------------------------------------------------
						if [[ "${var[expand-content]}" == "true" ]]; then
							[[ "${pageview}" == "on" ]] && echo "Seite (page-2a) - Erweiterte Ansicht"

							# Seite 2a - Lokaler Ordner und USB
							# -------------------------------------------------------------------
							if [[ "${var[targetserver]}" == "local" ]]; then
								[[ "${pageview}" == "on" ]] && echo "- Lokaler Ordner und USB"

								# Zerlegen von var[target] in /localshare und /localfolder
								if [ -n "${var[target]}" ]; then

									# Share: Behält nur die ersten beiden Komponenten aus var[target]. Ergebnis: /volume[x]/share
									var[localshare]=$(echo "${var[target]}" | cut -d'/' -f-3)

									# Folder: Löscht alle Komponenten vor dem zweiten Slash von links. Ergebnis: folder/sub
									var[localfolder]=$(echo "${var[target]}" | cut -d'/' -f4-)

									# Folder: Hängt am Anfang ein Slash an. Ergebnis: /folder/sub
									var[localfolder]=$(echo "/${var[localfolder]}")
								fi

								# Variablen zurücksetzen: Kommend von Seite 3 - Primäre Ansicht - rsync-Server Quelle(n) (Push Backup)
								#...
								if [[ "${var[goback]}" == "page-2a" ]]; then
									var[goback]=""
									"${set_keyvalue}" "${post_request}" "var[goback]" ""
									if [[ "${get[edit]}" != "true" ]]; then
										[ -f "${post_request}" ] && rm "${post_request}"
										keep_job_settings
										keep_target_server
										keep_backup_target
										keep_remote_server
										[ -f "${post_request}" ] && source "${post_request}"
									fi
								fi

								# Zielordner der Datensicherung (targetshare/targetfolder)
								# ...
								echo '
								<div class="row g-3 mb-3">
									<div class="col">
										<label for="localshare" class="form-label text-secondary">'${txt_localshare_label}'</label>
										<select id="localshare" name="localshare" class="form-select form-select-sm" required>
											<option value="" selected disabled>'${txt_localshare_opt}'</option>'
												local_target "/volume*" "localshare"
												echo '
										</select>
									</div>
									<div class="col">
										<label for="localfolder" class="form-label text-secondary">'${txt_localfolder_label}'
											<a class="text-danger text-decoration-none" data-bs-toggle="collapse" href="#localfolder-note" role="button" aria-expanded="false" aria-controls="localfolder-note">'${note}'</a>
											<div class="collapse" id="localfolder-note">
												<div class="card card-body border-0">
													<small>'${txt_localfolder_note}'</small>
												</div>
											</div>
										</label>
										<input type="text" pattern="'${txt_localfolder_regex}'" class="form-control form-control-sm" name="localfolder" id="localfolder" value="'${var[localfolder]}'" placeholder="'${txt_localfolder_format}'" required />
									</div>
								</div>'

								# UUID Check durchführen
								echo '
								<div class="row g-3 mb-3">
									<div class="col">
										<label for="uuidcheck" class="form-label text-secondary">'${txt_uuidcheck_label}' '${new}'</label>
										<select id="uuidcheck" name="uuidcheck" class="form-select form-select-sm">
											<option value="" selected></option>'
											echo -n '<option value="true"'; \
											[[ "${var[uuidcheck]}" == "true" ]] && echo -n ' selected>' || echo -n '>'
											echo ''${txt_uuidcheck_opt_true}'</option>'
											echo -n '<option value="false"'; \
											[[ "${var[uuidcheck]}" == "false" ]] && echo -n ' selected>' || echo -n '>'
											echo ''${txt_uuidcheck_opt_false}'</option>'
											echo '
										</select>'

										echo '
									</div>
								</div>'
							fi

							# Seite 2a - Remote rsync-Server (Push Backup)
							# -------------------------------------------------------------------
							if [[ "${var[targetserver]}" == "remote" ]]; then
								[[ "${pageview}" == "on" ]] && echo "- Remote rsync-Server (Push Backup)"

								# Variablen zurücksetzen: Kommend von Seite 3 - Primäre Ansicht - rsync-Server Quelle(n) (Push Backup)
								#...
								if [[ "${var[goback]}" == "page-2a" ]]; then
									var[goback]=""
									"${set_keyvalue}" "${post_request}" "var[goback]" ""
									if [[ "${get[edit]}" != "true" ]]; then
										[ -f "${post_request}" ] && rm "${post_request}"
										keep_job_settings
										keep_target_server
										keep_backup_target
										keep_remote_server
										[ -f "${post_request}" ] && source "${post_request}"
									fi
								fi

								# SSH Benutzername (sshuser) und Serveradresse (sshpush)
								# ...
								echo '
								<div class="row g-3 mb-3">
									<div class="col">
										<label for="sshuser" class="form-label text-secondary">'${txt_ssh_label_user}'</label>
										<input type="text" class="form-control form-control-sm" name="sshuser" id="sshuser" value="'${var[sshuser]}'" placeholder="'${txt_ssh_format_user}'" required />
									</div>
									<div class="col">
										<label for="sshpush" class="form-label text-secondary">'${txt_ssh_label_address}'</label>
										<input type="text" class="form-control form-control-sm" name="sshpush" id="sshpush" value="'${var[sshpush]}'" placeholder="'${txt_ssh_format_address}'" required />
									</div>
								</div>'
								# SSH Port und MAC Adresse
								# ...
								echo '
								<div class="row g-3 mb-3">
									<div class="col">
										<label for="sshport" class="form-label text-secondary">'${txt_ssh_label_port}'</label>
										<input type="number" min="1" max="65535" step="1" class="form-control form-control-sm" name="sshport" id="sshport" value="'${var[sshport]}'" placeholder="'${txt_ssh_format_port}'" required />
									</div>
									<div class="col">
										<label for="sshmac" class="form-label text-secondary">'${txt_ssh_label_mac}'
											<a class="text-danger text-decoration-none" data-bs-toggle="collapse" href="#sshmac-note" role="button" aria-expanded="false" aria-controls="sshmac-note">'${note}'</a>
												<div class="collapse" id="sshmac-note">
													<div class="card card-body border-0">
														<small>'${txt_ssh_info_mac}'</small>
													</div>
												</div>
										</label>
										<input type="text" pattern="'${txt_ssh_regex_mac}'" class="form-control form-control-sm" name="sshmac" id="sshmac" value="'${var[sshmac]}'" placeholder="'${txt_ssh_format_mac}'" />
									</div>
								</div>'
								# WOL und Shutdown
								# ...
								echo '
								<div class="row g-3 mb-3">
									<div class="col">
										<label for="wakeup" class="form-label text-secondary">'${txt_remoteserver_label_before}'</label>
										<select id="wakeup" name="wakeup" class="form-select form-select-sm" required >'
											echo -n '<option value="false"'; \
											[[ "${var[wakeup]}" == "false" ]] && echo -n ' selected>' || echo -n '>'
											echo ''${txt_remoteserver_opt_wakeup_no}'</option>'
											echo -n '<option value="60"'; \
											[[ "${var[wakeup]}" == "60" ]] && echo -n ' selected>' || echo -n '>'
											echo ''${txt_remoteserver_opt_wakeup_60}'</option>'
											echo -n '<option value="120"'; \
											[[ "${var[wakeup]}" == "120" ]] && echo -n ' selected>' || echo -n '>'
											echo ''${txt_remoteserver_opt_wakeup_120}'</option>'
											echo -n '<option value="180"'; \
											[[ "${var[wakeup]}" == "180" ]] && echo -n ' selected>' || echo -n '>'
											echo ''${txt_remoteserver_opt_wakeup_180}'</option>'
											echo '
										</select>
									</div>
									<div class="col">
										<label for="shutdown" class="form-label text-secondary">'${txt_remoteserver_label_after}'
											<a class="text-danger text-decoration-none" data-bs-toggle="collapse" href="#shutdown-note" role="button" aria-expanded="false" aria-controls="shutdown-note">'${note}'</a>
											<div class="collapse" id="shutdown-note">
												<div class="card card-body border-0">
													<small>'${txt_remoteserver_shutdown_note}'</small>
												</div>
											</div>
										</label>
										<select id="shutdown" name="shutdown" class="form-select form-select-sm" required>'
											echo -n '<option value="false"'; \
											[[ "${var[shutdown]}" == "false" ]] && echo -n ' selected>' || echo -n '>'
											echo ''${txt_remoteserver_opt_shutdown_no}'</option>'
											echo -n '<option value="always"'; \
											[[ "${var[shutdown]}" == "always" ]] && echo -n ' selected>' || echo -n '>'
											echo ''${txt_remoteserver_opt_shutdown_always}'</option>'
											echo -n '<option value="success"'; \
											[[ "${var[shutdown]}" == "success" ]] && echo -n ' selected>' || echo -n '>'
											echo ''${txt_remoteserver_opt_shutdown_success}'</option>'
											echo '
										</select>
									</div>
								</div>'
								# Privater RSA-Schlüssel
								# ...
								echo '
								<div class="row g-3 mb-3">
									<div class="col">
										<label for="privatekey" class="form-label text-secondary">'${txt_privatekey_label}' ('${txt_privatekey_format}')
											<a class="text-danger text-decoration-none" data-bs-toggle="collapse" href="#privatekey-note" role="button" aria-expanded="false" aria-controls="privatekey-note">'${note}'</a>
											<div class="collapse" id="privatekey-note">
												<div class="card card-body border-0">
													<small>'${txt_privatekey_note}'</small>
												</div>
											</div>
										</label>
										<div class="input-group input-group-sm">
											<span class="input-group-text" id="basic-addon1">/root/.ssh/</span>
											<input type="privatekey" pattern="'${txt_privatekey_regex}'" class="form-control form-control-sm" name="privatekey" id="privatekey" value="'${var[privatekey]:-id_rsa}'" placeholder="'${txt_privatekey_format}'" />
										</div>
									</div>
								</div>'
								# Zielordner der Datensicherung (targetfolder)
								# ...
								echo '
								<div class="mb-3">
									<label for="target" class="form-label text-secondary">'${txt_remotetarget_label}'
										<a class="text-danger text-decoration-none" data-bs-toggle="collapse" href="#target-note" role="button" aria-expanded="false" aria-controls="target-note">'${note}'</a>
											<div class="collapse" id="target-note">
												<div class="card card-body border-0">
													<small>'${txt_remotetarget_note}'</small>
												</div>
											</div>
									</label>
									<input type="text" pattern="'${txt_remotetarget_regex}'" class="form-control form-control-sm" name="target" id="target" value="'${var[target]}'" placeholder="'${txt_remotetarget_format}'" required />
								</div><br />'
							fi

							# Erweiterte Schaltfläche einblenden, wenn primäre Schaltfläche ausgeblendet ist
							# ...
							[[ "${pageview}" == "on" ]] && echo "goback-2"
							echo '
							<p class="text-end"><br />
								<input type="hidden" name="expand-content" value="false">
								<input type="hidden" name="goback" value="page-2">
								<a href="index.cgi?page=jobedit&section=abort" class="btn btn-secondary btn-sm">'${txt_button_Cancel}'</a>&nbsp;&nbsp;&nbsp;
								<button class="btn btn-secondary btn-sm disable_validation" type="submit" name="section" value="2">'${txt_button_Back}'</button>&nbsp;&nbsp;&nbsp;
								<button class="btn btn-secondary btn-sm" type="submit" name="section" value="3">'${txt_button_Continue}'</button><br />
							</p>'
						fi
						echo '
					</div>'
				fi

				# Seite 3
				# ---------------------------------------------------------------------------
				if [[ "${var[section]}" == "3" ]]; then
					[[ "${pageview}" == "on" ]] && echo "Seite (page-3) - Primäre Ansicht"

					if [ -z "${var[expand-content]}" ] || [[ "${var[expand-content]}" == "false" ]]; then

						# Variablen zurücksetzen. Kommend von Seite 3a - Datensicherungsquelle(n) auswählen.
						# ...
						if [[ "${var[goback]}" == "page-3" ]]; then
							var[goback]=""
							"${set_keyvalue}" "${post_request}" "var[goback]" ""
							if [[ "${get[edit]}" != "true" ]]; then
								[ -f "${post_request}" ] && rm "${post_request}"
								keep_job_settings
								keep_target_server
								keep_backup_target
								keep_remote_server
								keep_source_server
								if [[ "${var[sourceserver]}" == "remote" ]] && [[ "${var[targetserver]}" != "remote" ]]; then
									reset_backup_source
									reset_remote_server
								fi
								if [[ "${var[sourceserver]}" == "local" ]]; then
									reset_backup_source
								fi
							fi
							[ -f "${post_request}" ] && source "${post_request}"
						fi
					fi

					if [[ "${var[targetserver]}" == "local" ]]; then
						var[target]=$(echo "${var[localshare]}${var[localfolder]}")
						"${set_keyvalue}" "${post_request}" "var[target]" "${var[target]}"

						# Wenn localshare = externer Datenträger, dann bestimme UUID.
						if [[ "${var[localshare]}" == /volumeUSB[[:digit:]]/usbshare* ]] || [[ "${var[localshare]}" == /volumeSATA[[:digit:]]/satashare* ]]; then
							mountpoint=$(mount)
							mountpoint=$(echo "${mountpoint}" | grep " on ${var[localshare]} " | awk '{ print $1 }')
							device="${mountpoint}"
							uuid=$(blkid -s UUID -o value ${device})
							label=$(blkid -s LABEL -o value ${device})
							type=$(blkid -s TYPE -o value ${device})
							"${set_keyvalue}" "${post_request}" "var[uuid]" "${uuid}"
						else
							"${set_keyvalue}" "${post_request}" "var[uuid]" ""
						fi
						[ -f "${post_request}" ] && source "${post_request}"
					fi


					# Seite 3 - Primäre Ansicht - Datensicherungsquelle(n)
					# -----------------------------------------------------------------------
					echo '
					<div class="card border-0">
						<div class="card-header ps-0 pb-0 bg-body border-0">'
							[[ "${get[edit]}" == "true" ]] && echo '<h5>'${txt_job_title}' <span class="text-blue">'$(urldecode ${get[jobname]})'</span> - '${txt_sources_title}' '${txt_job_edit}'</h5>' || echo '<h5>'${txt_sources_title}' '${txt_job_select}'</h5>'
							echo '
						</div>
					</div>
					<div class="card-body">'
						# Datensicherungsquelle(n)
						# ...
						if [[ "${var[targetserver]}" == "local" ]]; then
							[[ "${pageview}" == "on" ]] && echo "Seite (page-3) - Primäre Ansicht - kommend von Seite (page-2a) - Lokaler Ordner und USB"
							# Datensicherungsquelle auswählen
							# ...
							echo '
							<div class="row g-3 mb-3">
								<div class="col">
									<label for="sourceserver" class="form-label text-secondary">'${txt_sourceserver_label}''
										if [[ "${var[sourceserver]}" == "remote" ]]; then
											echo '
											<button type="button" class="btn btn-link btn-sm text-danger text-decoration-none" data-bs-toggle="modal" data-bs-target="#help-ssh-local">
												<sup>'${txt_sshbuild_note}'</sup>
											</button>'
										fi
										echo '
									</label>'
									if [[ "${var[expand-content]}" == "true" ]] && [ -n "${var[sourceserver]}" ]; then
										# Disabled: Zielserver
										# ...
										if [[ "${var[sourceserver]}" == "local" ]]; then
											echo '<input type="text" class="form-control form-control-sm" placeholder="'${txt_sourceserver_opt_local}'" disabled>'
										elif [[ "${var[sourceserver]}" == "remote" ]]; then
											echo '<input type="text" class="form-control form-control-sm" placeholder="'${txt_sourceserver_opt_remote}'" disabled>'
										fi
									else
										echo -n '
										<select id="sourceserver" name="sourceserver" class="form-select form-select-sm"'; \
										[[ "${var[expand-content]}" == "true" ]] && echo -n ' disabled>' || echo -n ' required>'
											echo -n '<option value="" class="text-secondary" selected disabled>'${txt_sourceserver_opt}'</option>'
											echo -n '<option value="local"'; \
											[[ "${var[sourceserver]}" == "local" ]] && echo -n ' selected>' || echo -n '>'
											echo ''${txt_sourceserver_opt_local}'</option>'
											echo -n '<option value="remote"'; \
											[[ "${var[sourceserver]}" == "remote" ]] && echo -n ' selected>' || echo -n '>'
											echo ''${txt_sourceserver_opt_remote}'</option>'
											echo '
										</select>'
									fi
									echo '
								</div>
							</div>'

							# Primäre Schaltfläche einblenden, solange die erweiterte Ansicht ausgeblendet ist
							# ...
							if [ -z "${var[expand-content]}" ] || [[ "${var[expand-content]}" == "false" ]]; then
								echo '
								<p class="text-end"><br />
									<input type="hidden" name="expand-content" value="true">
									<input type="hidden" name="goback" value="page-2a">
									<a href="index.cgi?page=jobedit&section=abort" class="btn btn-secondary btn-sm">'${txt_button_Cancel}'</a>&nbsp;&nbsp;&nbsp;
									<button class="btn btn-secondary btn-sm disable_validation" type="submit" name="section" value="2">'${txt_button_Back}'</button>&nbsp;&nbsp;&nbsp;
									<button class="btn btn-secondary btn-sm" type="submit" name="section" value="3">'${txt_button_Continue}'</button><br />
								</p>'
							fi

							# Seite 3a - Erweiterte Ansicht - Quellordner
							# -------------------------------------------------------------------
							if [[ "${var[expand-content]}" == "true" ]]; then
								[[ "${pageview}" == "on" ]] && echo "Seite (page-3a) - Erweiterte Ansicht"

								# Seite 3a - Lokale Datensicherungsquelle(n)
								# ---------------------------------------------------------------
								if [[ "${var[sourceserver]}" == "local" ]]; then
									[[ "${pageview}" == "on" ]] && echo "- Lokale Datensicherungsquelle(n)"

									# Variablen zurücksetzen: Kommend von Seite 4 - Primäre Ansicht - Weitere Einstellungen
									# ...
									if [[ "${var[goback]}" == "page-3a" ]]; then
										var[goback]=""
										"${set_keyvalue}" "${post_request}" "var[goback]" ""
										if [[ "${get[edit]}" != "true" ]]; then
											[ -f "${post_request}" ] && rm "${post_request}"
											keep_job_settings
											keep_target_server
											keep_backup_target
											keep_source_server
											keep_remote_server
										fi
										[ -f "${post_request}" ] && source "${post_request}"
									fi

									# Zu sichernde Ordner auswählen
									# ...
									echo '
									<div class="row g-3 mb-3">
										<div class="col">
											<label for="sources" class="form-label text-secondary">'${txt_sources_label}''
												if ! cat /etc/group | grep ^administrators | grep -q ${app_name} ; then
													echo '
													<a class="text-danger text-decoration-none" data-bs-toggle="collapse" href="#email-note" role="button" aria-expanded="false" aria-controls="email-note">'${note}'</a>
													<div class="collapse" id="email-note">
														<div class="card card-body border-0">
															<small>'${txt_sources_rights}'</small>
														</div>
													</div>'
												fi
												echo '
											</label><br />'
											count=1
											local_sources "/volume[[:digit:]]"
											local_sources "/volumeUSB[[:digit:]]/usbshare*"
											local_sources "/volumeSATA[[:digit:]]/satashare*"
											unset count
											echo '
										</div>
									</div>'
								fi

								# Seite 3a - Remote rsync-Server Quelle(n) (Pull Backup)
								# ---------------------------------------------------------------
								if [[ "${var[sourceserver]}" == "remote" ]]; then
									[[ "${pageview}" == "on" ]] && echo "- Remote rsync-Server Quelle(n) (Pull Backup)"

									# Variablen zurücksetzen: Kommend von Seite 4 - Primäre Ansicht - Weitere Einstellungen
									# ...
									if [[ "${var[goback]}" == "page-3a" ]]; then
										var[goback]=""
										"${set_keyvalue}" "${post_request}" "var[goback]" ""
										if [[ "${get[edit]}" != "true" ]]; then
											[ -f "${post_request}" ] && rm "${post_request}"
											keep_job_settings
											keep_target_server
											keep_backup_target
											keep_source_server
											keep_remote_server
										fi
										[ -f "${post_request}" ] && source "${post_request}"
									fi

									# SSH Benutzername (sshuser) und Serveradresse (sshpush)
									# ...
									echo '
									<div class="row g-3 mb-3">
										<div class="col">
											<label for="sshuser" class="form-label text-secondary">'${txt_ssh_label_user}'</label>
											<input type="text" class="form-control form-control-sm" name="sshuser" id="sshuser" value="'${var[sshuser]}'" placeholder="'${txt_ssh_format_user}'" required />
										</div>
										<div class="col">
											<label for="sshpull" class="form-label text-secondary">'${txt_ssh_label_address}'</label>
											<input type="text" class="form-control form-control-sm" name="sshpull" id="sshpull" value="'${var[sshpull]}'" placeholder="'${txt_ssh_format_address}'" required />
										</div>
									</div>'
									# SSH Port und MAC Adresse
									# ...
									echo '
									<div class="row g-3 mb-3">
										<div class="col">
											<label for="sshport" class="form-label text-secondary">'${txt_ssh_label_port}'</label>
											<input type="number" min="1" max="65535" step="1" class="form-control form-control-sm" name="sshport" id="sshport" value="'${var[sshport]}'" placeholder="'${txt_ssh_format_port}'" required />
										</div>
										<div class="col">
											<label for="sshmac" class="form-label text-secondary">'${txt_ssh_label_mac}'
												<a class="text-danger text-decoration-none" data-bs-toggle="collapse" href="#sshmac-note" role="button" aria-expanded="false" aria-controls="sshmac-note">'${note}'</a>
												<div class="collapse" id="sshmac-note">
													<div class="card card-body border-0">
														<small>'${txt_ssh_info_mac}'</small>
													</div>
												</div>
											</label>
											<input type="text" pattern="'${txt_ssh_regex_mac}'" class="form-control form-control-sm" name="sshmac" id="sshmac" value="'${var[sshmac]}'" placeholder="'${txt_ssh_format_mac}'" />
										</div>
									</div>'
									# WOL und Shutdown
									# ...
									echo '
									<div class="row g-3 mb-3">
										<div class="col">
											<label for="wakeup" class="form-label text-secondary">'${txt_remoteserver_label_before}'</label>
											<select id="wakeup" name="wakeup" class="form-select form-select-sm" required >'
												echo -n '<option value="false"'; \
												[[ "${var[wakeup]}" == "false" ]] && echo -n ' selected>' || echo -n '>'
												echo ''${txt_remoteserver_opt_wakeup_no}'</option>'
												echo -n '<option value="60"'; \
												[[ "${var[wakeup]}" == "60" ]] && echo -n ' selected>' || echo -n '>'
												echo ''${txt_remoteserver_opt_wakeup_60}'</option>'
												echo -n '<option value="120"'; \
												[[ "${var[wakeup]}" == "120" ]] && echo -n ' selected>' || echo -n '>'
												echo ''${txt_remoteserver_opt_wakeup_120}'</option>'
												echo -n '<option value="180"'; \
												[[ "${var[wakeup]}" == "180" ]] && echo -n ' selected>' || echo -n '>'
												echo ''${txt_remoteserver_opt_wakeup_180}'</option>'
												echo '
											</select>
										</div>
										<div class="col">
											<label for="shutdown" class="form-label text-secondary">'${txt_remoteserver_label_after}'
												<a class="text-danger text-decoration-none" data-bs-toggle="collapse" href="#shutdown-note" role="button" aria-expanded="false" aria-controls="shutdown-note">'${note}'</a>
												<div class="collapse" id="shutdown-note">
													<div class="card card-body border-0">
														<small>'${txt_remoteserver_shutdown_note}'</small>
													</div>
												</div>
											</label>
											<select id="shutdown" name="shutdown" class="form-select form-select-sm" required>'
												echo -n '<option value="false"'; \
												[[ "${var[shutdown]}" == "false" ]] && echo -n ' selected>' || echo -n '>'
												echo ''${txt_remoteserver_opt_shutdown_no}'</option>'
												echo -n '<option value="always"'; \
												[[ "${var[shutdown]}" == "always" ]] && echo -n ' selected>' || echo -n '>'
												echo ''${txt_remoteserver_opt_shutdown_always}'</option>'
												echo -n '<option value="success"'; \
												[[ "${var[shutdown]}" == "success" ]] && echo -n ' selected>' || echo -n '>'
												echo ''${txt_remoteserver_opt_shutdown_success}'</option>'
												echo '
											</select>
										</div>
									</div>'
									# Privater RSA-Schlüssel
									# ...
									echo '
									<div class="row g-3 mb-3">
										<div class="col">
											<label for="privatekey" class="form-label text-secondary">'${txt_privatekey_label}' ('${txt_privatekey_format}')
												<a class="text-danger text-decoration-none" data-bs-toggle="collapse" href="#privatekey-note" role="button" aria-expanded="false" aria-controls="privatekey-note">'${note}'</a>
												<div class="collapse" id="privatekey-note">
													<div class="card card-body border-0">
														<small>'${txt_privatekey_note}'</small>
													</div>
												</div>
											</label>
											<div class="input-group input-group-sm">
												<span class="input-group-text" id="basic-addon1">/root/.ssh/</span>
												<input type="privatekey" pattern="'${txt_privatekey_regex}'" class="form-control form-control-sm" name="privatekey" id="privatekey" value="'${var[privatekey]:-id_rsa}'" placeholder="'${txt_privatekey_format}'" />
											</div>
										</div>
									</div>'
									# Zu sichernde Ordner auswählen
									# ...
									echo '
									<div class="row g-3 mb-3">
										<div class="col">
											<label for="sources" class="form-label text-secondary">'${txt_sources_label}'
												<a class="text-danger text-decoration-none" data-bs-toggle="collapse" href="#sources-note" role="button" aria-expanded="false" aria-controls="sources-note">'${note}'</a>
												<div class="collapse" id="sources-note">
													<div class="card card-body border-0">
														<small>'${txt_sources_notes}'</small>
													</div>
												</div>
											</label>
											<input type="text" pattern="'${txt_sources_regex}'" class="form-control form-control-sm" style="white-space: pre;" name="sources" id="sources" value="'${var[sources]}'" placeholder="'${txt_sources_format}'" required />
										</div>
									</div><br />'
								fi

								# Erweiterte Schaltfläche einblenden, solange primäre Schaltfläche ausgeblendet ist
								# ...
								echo '
								<p class="text-end"><br />
									<input type="hidden" name="expand-content" value="false">
									<input type="hidden" name="goback" value="page-3">
									<a href="index.cgi?page=jobedit&section=abort" class="btn btn-secondary btn-sm">'${txt_button_Cancel}'</a>&nbsp;&nbsp;&nbsp;
									<button class="btn btn-secondary btn-sm disable_validation" type="submit" name="section" value="3">'${txt_button_Back}'</button>&nbsp;&nbsp;&nbsp;
									<button class="btn btn-secondary btn-sm" type="submit" name="section" value="4">'${txt_button_Continue}'</button><br />
								</p>'
							fi

						fi

						# Remote rsync-Server Quelle(n) (Push Backup)
						# -----------------------------------------------------------------------
						if [[ "${var[targetserver]}" == "remote" ]]; then
							[[ "${pageview}" == "on" ]] && echo "Seite (page-3) - Primäre Ansicht - rsync-Server Quelle(n) (Push Backup) - kommend von Seite (page-2a) Remote rsync-Server (Push Backup)"

							# Variablen zurücksetzen. Kommend von Seite 4 - Lokale Datensicherungsquelle(n) auswerten
							# ...
							if [[ "${var[goback]}" == "page-3a" ]]; then
								var[goback]=""
								"${set_keyvalue}" "${post_request}" "var[goback]" ""
								if [[ "${get[edit]}" != "true" ]]; then
									[ -f "${post_request}" ] && rm "${post_request}"
									keep_job_settings
									keep_target_server
									keep_backup_target
									keep_remote_server
									keep_source_server
								fi
								[ -f "${post_request}" ] && source "${post_request}"
							fi

							# Datensicherungsquelle(n)
							# ...
							echo '
							<div class="row g-3 mb-3">
								<div class="col">
									<label for="sourceserver" class="form-label text-secondary">'${txt_sourceserver_label}'</label>
									<input type="text" class="form-control form-control-sm" placeholder="'${txt_sourceserver_opt_local}'" disabled>
								</div>
							</div>'

							# Variabel sourceserver auf local setzen
							# ...
							"${set_keyvalue}" "${post_request}" "var[sourceserver]" "local"

							# Zu sichernde Ordner auswählen
							# ...
							echo '
							<div class="row g-3 mb-3">
								<div class="col">
									<label for="sources" class="form-label text-secondary">'${txt_sources_label}''
										if ! cat /etc/group | grep ^administrators | grep -q ${app_name} ; then
											echo '
											<a class="text-danger text-decoration-none" data-bs-toggle="collapse" href="#email-note" role="button" aria-expanded="false" aria-controls="email-note">'${note}'</a>
											<div class="collapse" id="email-note">
												<div class="card card-body border-0">
													<small>'${txt_sources_rights}'</small>
												</div>
											</div>'
										fi
										echo '
									</label><br />'
									count=1
									local_sources "/volume[[:digit:]]"
									local_sources "/volumeUSB[[:digit:]]/usbshare*"
									local_sources "/volumeSATA[[:digit:]]/satashare*"
									unset count
									echo '
								</div>
							</div>'

							# Erweiterte Schaltfläche einblenden, solange primäre Schaltfläche ausgeblendet ist
							# ...
							echo '
							<p class="text-end"><br />
								<input type="hidden" name="expand-content" value="true">
								<input type="hidden" name="goback" value="page-2a">
								<a href="index.cgi?page=jobedit&section=abort" class="btn btn-secondary btn-sm">'${txt_button_Cancel}'</a>&nbsp;&nbsp;&nbsp;
								<button class="btn btn-secondary btn-sm disable_validation" type="submit" name="section" value="2">'${txt_button_Back}'</button>&nbsp;&nbsp;&nbsp;
								<button class="btn btn-secondary btn-sm" type="submit" name="section" value="4">'${txt_button_Continue}'</button><br />
							</p>'
						fi
						echo '
					</div>'
				fi

				# Seite 4
				# ---------------------------------------------------------------------------
				if [[ "${var[section]}" == "4" ]]; then

					# Auswerten der okalen Datensicherungsquellen
					# ...
					if [[ "${var[sourceserver]}" == "local" ]]; then

						# Auftrennen von gemeinsamen Ordnern und Unterordnern
						# ...
						shares=()
						separated_folders=()
						for path in "${!var[@]}"; do
							if [[ "${path}" == share_* ]]; then
								dir="${var[${path}]}"
								dir=$(echo ${dir} | sed -e 's/ /\ /g')
								shares+=("${dir} &")
								continue
							fi
							if [[ "${path}" == folder_* ]]; then
								dir="${var[${path}]}"
								dir=$(echo ${dir} | sed -e 's/ /\ /g')
								separated_folders+=("${dir} &")
								continue
							fi
						done

						if [ -z "${dir}" ] && [[ "${var[targetserver]}" == "remote" ]]; then

							# Validierung der Formularfelder - Syntax "Page" "Title" "Content" "expand-content false/true"
							# ...
							popup_modal "jobedit" "${txt_popup_input_error}" "${txt_popup_select_source}" "false"
						fi

						unset path dir

						# Erfasste Werte in Variabeln zusammenfassen und regelkonform formatieren
						# ...
						if [ -n "${shares}" ] && [ -n "${separated_folders}" ]; then
							shares="${shares[@]}"
							shares="${shares::-2}"
							separated_folders="${separated_folders[@]}"
							separated_folders="${separated_folders::-2}"
						elif [ -z "${shares}" ] && [ -n "${separated_folders}" ]; then
							separated_folders="${separated_folders[@]}"
							separated_folders="${separated_folders::-2}"
						elif [ -n "${shares}" ] && [ -z "${separated_folders}" ]; then
							shares="${shares[@]}"
							shares="${shares::-2}"
						fi

						# Ausschließen gemeinsamer Ordner, die alle Unterordner angehakt haben
						# ...
						excluded_folders=()
						IFS='&'
						read -r -a included <<< "${shares}"
						for share in ${included[@]}; do
							# Leerzeichen am Anfang und Ende entfernen
							share=$(echo "${share}" | sed 's/^[ \t]*//;s/[ \t]*$//')
							read -r -a excluded <<< "${separated_folders}"
							for folder in ${excluded[@]}; do
								# Leerzeichen am Anfang und Ende entfernen
								folder=$(echo "${folder}" | sed 's/^[ \t]*//;s/[ \t]*$//')
								if [[ "${share}" == "${folder%/*}" ]]; then
									excluded_folders+=("${folder} &")
								fi
							done
						done
						IFS="${backupIFS}"
						unset included share excluded folder

						# Erfasste Werte in Variabeln zusammenfassen und regelkonform formatieren
						# ...
						if [ -n "${excluded_folders}" ]; then
							excluded_folders="${excluded_folders[@]}"
							excluded_folders="${excluded_folders::-2}"
						fi

						# Einschließen aller Unterordner, die keinen gemeinsamen Ordner angehakt haben
						# ...
						folders=()
						IFS='&'
						read -r -a separated <<< "${separated_folders}"
						for included in ${separated[@]}; do
							# Leerzeichen am Anfang und Ende entfernen
							included=$(echo "${included}" | sed 's/^[ \t]*//;s/[ \t]*$//')
							skip=
							read -r -a excluded <<< "${excluded_folders}"
							for folder in ${excluded[@]}; do
								folder=$(echo "${folder}" | sed 's/^[ \t]*//;s/[ \t]*$//')
								[[ ${included} == ${folder} ]] && { skip=1; break; }
							done
							[[ -n ${skip} ]] || folders+=("${included} &")
						done
						IFS="${backupIFS}"
						unset included folder

						# Erfasste Werte in Variabeln zusammenfassen und regelkonform formatieren
						# ...
						if [ -n "${shares}" ] && [ -n "${folders}" ]; then
							folders="${folders[@]}"
							folders="${folders::-2}"
							sources="${shares} & ${folders}"
						elif [ -z "${shares}" ] && [ -n "${folders}" ]; then
							folders="${folders[@]}"
							folders="${folders::-2}"
							sources="${folders}"
						elif [ -n "${shares}" ] && [ -z "${folders}" ]; then
							sources="${shares}"
						fi

						# Erstellen der Variabel var[sources]
						# ...
						"${set_keyvalue}" "${post_request}" "var[sources]" "${sources}"
						[ -f "${post_request}" ] && source "${post_request}"
					fi

					# Seite 4 - Primäre Ansicht - Weitere Einstellungen
					# -----------------------------------------------------------------------
					echo '
					<div class="card border-0">
						<div class="card-header ps-0 pb-0 bg-body border-0">'
							[[ "${get[edit]}" == "true" ]] && echo '<h5>'${txt_job_title}' <span class="text-blue">'$(urldecode ${get[jobname]})'</span> - '${txt_rsync_title}' '${txt_job_edit}'</h5>' || echo '<h5>'${txt_rsync_title}' '${txt_job_select}'</h5>'
							echo '
						</div>
					</div>
					<div class="card-body">'

						# rsync-Optionsschalter (syncopt)
						# ...
						echo '
						<div class="row g-3 mb-3">
							<div class="col">
								<label for="syncopt" class="form-label text-secondary">'${txt_syncopt_label}'</label>
								<input type="text" class="form-control form-control-sm" name="syncopt" id="syncopt" value="'${var[syncopt]:--ah}'" placeholder="'${txt_syncopt_format}'" required />
							</div>
						</div>'

						# @recycle rotate
						# ...
						echo '
						<div class="row g-3">
							<div class="col">
								<label for="recycle" class="form-label text-secondary">'${txt_recycle_label}'
									<a class="text-danger text-decoration-none" data-bs-toggle="collapse" href="#recycle-note" role="button" aria-expanded="false" aria-controls="recycle-note">'${note}'</a>
									<div class="collapse" id="recycle-note">
										<div class="card card-body border-0">
											<small>'${txt_recycle_note}'</small>
										</div>
									</div>
								</label>
								<div class="input-group input-group-sm mb-3">
									<input type="number" class="form-control form-control-sm" name="recycle" id="recycle" value="'${var[recycle]:-90}'" aria-label="" aria-describedby="recycle" required />
									 <span class="input-group-text" id="inputGroup-sizing-sm">'${txt_days}'</span>
								</div>
							</div>
						</div>'

						# Versionierung
						# ...
						echo '
						<div class="row g-3 mb-3">
							<div class="col">
								<label for="versioning" class="form-label text-secondary">'${txt_versioning_label}'
									<a class="text-danger text-decoration-none" data-bs-toggle="collapse" href="#versioning-note" role="button" aria-expanded="false" aria-controls="versioning-note">'${note}'</a>
									<div class="collapse" id="versioning-note">
										<div class="card card-body border-0">
											<small>'${txt_versioning_note}'</small>
										</div>
									</div>
								</label>
								<select id="versioning" name="versioning" class="form-select form-select-sm" required >'
									echo -n '<option value="false"'; \
									[[ "${var[versioning]}" == "false" ]] && echo -n ' selected>' || echo -n '>'
									echo ''${txt_versioning_opt_false}'</option>'
									echo -n '<option value="true"'; \
									[[ "${var[versioning]}" == "true" ]] && echo -n ' selected>' || echo -n '>'
									echo ''${txt_versioning_opt_true}'</option>'
									echo '
								</select>
							</div>
							<div class="col">
								<label for="versions" class="form-label text-secondary">'${txt_versions_label}'</label>
								<div class="input-group input-group-sm mb-3">
									<input type="number" min="2" max="365" step="1" class="form-control form-control-sm" name="versions" id="versions" value="'${var[versions]:-2}'" placeholder="'${txt_versions_format}'" />
									<span class="input-group-text" id="inputGroup-sizing-sm">'${txt_days}'</span>
								</div>
							</div>
						</div>'


						# Muster von der Sicherung ausschließen
						#
						#echo '
						#<div class="row g-3 mb-3">
						#	<div class="col">
						#		<label for="exclude" class="form-label text-secondary">'${txt_exclude_label}'</label>
						#		<input type="text" class="form-control form-control-sm" name="exclude" id="exclude" value="'${var[exclude]:---delete-excluded --exclude=@eaDir/*** --exclude=@Logfiles/*** --exclude=#recycle/*** --exclude=#snapshot/*** --exclude=.DS_Store/***}'" />
						#	</div>
						#</div>'

						echo '
							<p class="text-end"><br />
								<input type="hidden" name="expand-content" value="true">
								<input type="hidden" name="goback" value="page-3a">
								<a href="index.cgi?page=jobedit&section=abort" class="btn btn-secondary btn-sm">'${txt_button_Cancel}'</a>&nbsp;&nbsp;&nbsp;
								<button class="btn btn-secondary btn-sm" type="submit" name="section" value="3">'${txt_button_Back}'</button>&nbsp;&nbsp;&nbsp;
								<button class="btn btn-secondary btn-sm" type="submit" name="section" value="savescript">'${txt_button_Save}'</button><br />
							</p>'

						echo '
					</div>'
				fi

				# Seite 5 - Script Speichern
				# ---------------------------------------------------------------------------
				if [[ "${var[section]}" == "savescript" ]]; then
					echo '
					<div class="card border-0">
						<div class="card-header ps-0 pb-0 bg-body border-0">'
							[[ "${get[edit]}" == "true" ]] && echo '<h5>'${txt_job_title}' <span class="text-blue">'$(urldecode ${get[jobname]})'</span> - '${txt_save_title_edit}'</h5>' || echo '<h5>'${txt_save_title_new}'</h5>'
							echo '
						</div>
					</div>
					<div class="card-body">'

						# Konfigurations- und Logdatei definieren
						[ -f "${post_request}" ] && source "${post_request}"
						scripttarget="${usr_backupjobs}/${var[jobname]}.config"
						logtarget="${usr_logfiles}/${var[jobname]}.log"

						# Loggdatei erstellen
						if [ ! -f "${logtarget}" ]; then
							touch "${logtarget}"
							chmod 0755 "${logtarget}"
							#chown "${syno_user}":"${app_name}" "${logtarget}"
						fi

						# Konfigurationsdatei erstellen
						if [[ "${old_jobname}" != "${var[jobname]}" ]]; then
							rm -f "${usr_backupjobs}/${old_jobname}.config"
							rm -f "${usr_logfiles}/${old_jobname}.log"
						fi

						echo "#!/bin/bash" > "${scripttarget}"
						echo "# Filename: ${var[jobname]}.config - coded in utf-8" >> "${scripttarget}"
						echo "jobconfig_version=\"${job_version}\"" >> "${scripttarget}"
						echo "" >> "${scripttarget}"
						echo "#                        Basic Backup" >> "${scripttarget}"
						echo "#" >> "${scripttarget}"
						echo "#        Copyright (C) 2023 by Tommes | License GNU GPLv3" >> "${scripttarget}"
						echo "#         Member of the German Synology Community Forum" >> "${scripttarget}"
						echo "#" >> "${scripttarget}"
						echo "# Extract from  GPL3   https://www.gnu.org/licenses/gpl-3.0.html" >> "${scripttarget}"
						echo "#                                     ..." >> "${scripttarget}"
						echo "# This program is free software: you can redistribute it  and/or" >> "${scripttarget}"
						echo "# modify it under the terms of the GNU General Public License as" >> "${scripttarget}"
						echo "# published by the Free Software Foundation, either version 3 of" >> "${scripttarget}"
						echo "# the License, or (at your option) any later version." >> "${scripttarget}"
						echo "#" >> "${scripttarget}"
						echo "# This program is distributed in the hope that it will be useful" >> "${scripttarget}"
						echo "# but WITHOUT ANY WARRANTY; without even the implied warranty of" >> "${scripttarget}"
						echo "# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE." >> "${scripttarget}"
						echo "#" >> "${scripttarget}"
						echo "# See the GNU General Public License for more details.You should" >> "${scripttarget}"
						echo "# have received a copy of the GNU General Public  License  along" >> "${scripttarget}"
						echo "# with this program. If not, see http://www.gnu.org/licenses/  !" >> "${scripttarget}"

						echo "" >> "${scripttarget}"; echo "declare -A var" >> "${scripttarget}"

						# var[target]
						echo "" >> "${scripttarget}"; echo "# ${txt_backuptarget_label}" >> "${scripttarget}"
						"${set_keyvalue}" "${scripttarget}" "var[target]" "${var[target]}"

						# var[uuid]
						echo "" >> "${scripttarget}"; echo "# ${txt_localuuid_label}" >> "${scripttarget}"
						"${set_keyvalue}" "${scripttarget}" "var[uuid]" "${var[uuid]}"

						# var[uuidcheck]
						echo "" >> "${scripttarget}"; echo "# ${txt_uuidcheck_label_script}" >> "${scripttarget}"
						echo "# - true  = ${txt_uuidcheck_opt_true}" >> "${scripttarget}"
						echo "# - false = ${txt_uuidcheck_opt_false}" >> "${scripttarget}"
						"${set_keyvalue}" "${scripttarget}" "var[uuidcheck]" "${var[uuidcheck]}"

						# var[sources]
						echo "" >> "${scripttarget}"; echo "# ${txt_sources_label} (${txt_sources_label_info})" >> "${scripttarget}"
						"${set_keyvalue}" "${scripttarget}" "var[sources]" "${var[sources]}"

						# var[sshuser]
						echo "" >> "${scripttarget}"; echo "# ${txt_ssh_label_user} (${txt_ssh_format_user})" >> "${scripttarget}"
						"${set_keyvalue}" "${scripttarget}" "var[sshuser]" "${var[sshuser]}"
						echo "" >> "${scripttarget}"; echo "# ${txt_ssh_label_address} (${txt_ssh_format_address})" >> "${scripttarget}"
						echo "# - ${txt_ssh_script_sshpush}" >> "${scripttarget}"
						echo "# - ${txt_ssh_script_sshpull}" >> "${scripttarget}"

						# var[sshpush]
						"${set_keyvalue}" "${scripttarget}" "var[sshpush]" "${var[sshpush]}"

						# var[sshpull]
						"${set_keyvalue}" "${scripttarget}" "var[sshpull]" "${var[sshpull]}"

						# var[sshport]
						echo "" >> "${scripttarget}"; echo "# ${txt_ssh_label_port} (${txt_ssh_format_port})" >> "${scripttarget}"
						"${set_keyvalue}" "${scripttarget}" "var[sshport]" "${var[sshport]}"

						# var[sshmac]
						echo "" >> "${scripttarget}"; echo "# ${txt_ssh_label_mac} (${txt_ssh_format_mac})" >> "${scripttarget}"
						"${set_keyvalue}" "${scripttarget}" "var[sshmac]" "${var[sshmac]}"

						# var[privatekey]
						echo "" >> "${scripttarget}"; echo "# ${txt_privatekey_label} (${txt_privatekey_format})" >> "${scripttarget}"
						"${set_keyvalue}" "${scripttarget}" "var[privatekey]" "${var[privatekey]}"

						# var[wakeup]
						echo "" >> "${scripttarget}"; echo "# ${txt_remoteserver_script_before}" >> "${scripttarget}"
						"${set_keyvalue}" "${scripttarget}" "var[wakeup]" "${var[wakeup]}"

						# var[shutdown]
						echo "" >> "${scripttarget}"; echo "# ${txt_remoteserver_script_after}" >> "${scripttarget}"
						"${set_keyvalue}" "${scripttarget}" "var[shutdown]" "${var[shutdown]}"

						# var[sendemail]
						echo "" >> "${scripttarget}"; echo "# ${txt_sendemail_label} (${txt_sendemail_format})" >> "${scripttarget}"
						"${set_keyvalue}" "${scripttarget}" "var[sendemail]" "${var[sendemail]}"

						# var[emailfrom]
						echo "" >> "${scripttarget}"; echo "# ${txt_email_label} ${txt_emailfrom_label}" >> "${scripttarget}"
						"${set_keyvalue}" "${scripttarget}" "var[emailfrom]" "${var[emailfrom]}"

						# var[emailto]
						echo "" >> "${scripttarget}"; echo "# ${txt_email_label} ${txt_emailto_label}" >> "${scripttarget}"
						"${set_keyvalue}" "${scripttarget}" "var[emailto]" "${var[emailto]}"

						# var[optical]
						echo "" >> "${scripttarget}"; echo "# ${txt_signal_label_optical} (${txt_signal_format})" >> "${scripttarget}"
						"${set_keyvalue}" "${scripttarget}" "var[optical]" "${var[optical]}"

						# var[acoustical]
						echo "" >> "${scripttarget}"; echo "# ${txt_signal_label_acoustical} (${txt_signal_format})" >> "${scripttarget}"
						"${set_keyvalue}" "${scripttarget}" "var[acoustical]" "${var[acoustical]}"

						# var[syncopt]
						echo "" >> "${scripttarget}"; echo "# ${txt_syncopt_label} (${txt_syncopt_format})" >> "${scripttarget}"
						"${set_keyvalue}" "${scripttarget}" "var[syncopt]" "${var[syncopt]}"

						# var[recycle]
						echo "" >> "${scripttarget}"; echo "# ${txt_recycle_label} (${txt_recycle_format})" >> "${scripttarget}"
						"${set_keyvalue}" "${scripttarget}" "var[recycle]" "${var[recycle]}"

						# var[versioning]
						echo "" >> "${scripttarget}"; echo "# ${txt_versioning_label} (${txt_versioning_format})" >> "${scripttarget}"
						"${set_keyvalue}" "${scripttarget}" "var[versioning]" "${var[versioning]}"

						# var[versions]
						echo "" >> "${scripttarget}"; echo "# ${txt_versions_label} (${txt_versions_format})" >> "${scripttarget}"
						"${set_keyvalue}" "${scripttarget}" "var[versions]" "${var[versions]}"

						# var[exclude]
						#echo "" >> "${scripttarget}"; echo "# ${txt_exclude_label}" >> "${scripttarget}"
						#"${set_keyvalue}" "${scripttarget}" "var[exclude]" "${var[exclude]}"

						chmod 0755 ${scripttarget}
						#chown ${syno_user}:${app_name} ${var[scripttarget]}


						if [ ! -f "${scripttarget}" ]; then
							echo ''${txt_save_note_failed}''
							sleep 2
							echo '<meta http-equiv="refresh" content="0; url=index.cgi?page=main&section=start">'
						else
							if [[ "${get[edit]}" == "true" ]]; then
								echo ''${txt_save_note_edit}''
							else
								echo ''${txt_save_note_true}''
							fi
							sleep 2
							echo '<meta http-equiv="refresh" content="0; url=index.cgi?page=main&section=start">'
						fi

						echo '
					</div>'
				fi
				echo '
			</form>'
		fi
		echo '
	</div>
	<!-- col -->
</div>
<!-- row -->'

