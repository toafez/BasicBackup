#!/bin/bash
# Filename: recovery.sh - coded in utf-8

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


# Horizontale Navigationsleiste laden
# --------------------------------------------------------------
mainnav

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
		done <<< "$( find ${volume}/* -type d ! -path '*/lost\+found' ! -path '*/\@*' ! -path '*/\$RECYCLE.BIN' ! -path '*/Repair' ! -path '*/recovery Volume Information' -maxdepth 0 )"
	done <<< "$( find ${1} -maxdepth 0 -type d )"
	unset volume share
}

# Startseite anzeigen
# --------------------------------------------------------------
if [[ "${get[page]}" == "recovery" && "${get[section]}" == "start" ]]; then

	# Konfiguration sichern
	# --------------------------------------------------------------
	echo '
	<form action="index.cgi?page=recovery" method="post" id="recovery-form" autocomplete="on">
		<div class="row">
			<div class="col">
				<div class="card border-0">
					<div class="card-header ps-0 pb-0 bg-body border-0">
						<h5>'${txt_import_export_title}'</h5>
					</div>
				</div>
				<div class="card-body">
					<div class="row">
						<div class="col-sm-12">
							<p class="text-secondary">'${txt_import_export_info}'</p><br />
							<div class="row g-3 mb-3">
								<div class="col">
									<label for="configshare" class="form-label text-secondary">'${txt_targetpath_label}'</label>
									<select id="configshare" name="configshare" class="form-select form-select-sm" required>
										<option value="" selected disabled>'${txt_targetshare_opt}'</option>'
											local_target "/volume*" "configshare"
											echo '
									</select>
								</div>
								<div class="col">
									<label for="configfolder" class="form-label text-secondary">'${txt_targetlocation_label}'</span>
										<a class="text-danger text-decoration-none" data-bs-toggle="collapse" href="#configfolder-note" role="button" aria-expanded="false" aria-controls="configfolder-note">'${note}'</a>
										<div class="collapse" id="configfolder-note">
											<div class="card card-body border-0">
												<small>'${txt_localfolder_note}'</small>
											</div>
										</div>
									</label>
									<input type="text" pattern="'${txt_localfolder_regex}'" class="form-control form-control-sm" name="configfolder" id="configfolder" value="'${var[configfolder]}'" placeholder="'${txt_folderpath_format_path}'" required />
								</div>
							</div>'

							echo '
							<p class="text-end"><br />
								<input type="hidden" name="load" value="true">
								<a href="index.cgi?page=main&section=start" class="btn btn-secondary btn-sm">'${txt_button_Back}'</a>&nbsp;&nbsp;&nbsp;
								<button class="btn btn-danger btn-sm" type="submit" name="section" value="import">'${txt_button_restore}'</button>&nbsp;&nbsp;&nbsp;
								<button class="btn btn-success btn-sm" type="submit" name="section" value="export">'${txt_button_secure}'</button><br />
							</p>'

							echo '
						</div>
					</div>
				</div>'

				echo '
			</div>
		</div>
	</form>'
fi

# Konfiguration exportieren - Ausführung
# --------------------------------------------------------------
if [[ "${get[page]}" == "recovery" && "${var[section]}" == "export" ]]; then
	[ -f "${get_request}" ] && rm "${get_request}"
	[ -f "${post_request}" ] && rm "${post_request}"

	if [ -d "${var[configshare]}" ]; then
		if [ ! -d "${var[configshare]}${var[configfolder]}" ]; then
			mkdir -p -m 755 "${var[configshare]}${var[configfolder]}/usersettings"
		fi

		if [ -d "${var[configshare]}${var[configfolder]}/usersettings" ]; then

			cp -ar /var/packages/BasicBackup/target/ui/usersettings/backupjobs "${var[configshare]}${var[configfolder]}"/usersettings/backupjobs/
			chmod 777 -R "${var[configshare]}${var[configfolder]}"/usersettings/backupjobs
			exit_cp=${?}

			if [[ ${exit_cp} -eq 0 ]]; then
				popup_modal "recovery" "${txt_link_note}" "${txt_export_true_note}" ""
			else
				popup_modal "recovery" "${txt_error_occurred_note}" "${txt_export_false_note}" ""
			fi
		else
			popup_modal "recovery" "${txt_error_occurred_note}" "${txt_folder_not_create_info}" ""
		fi

	else
		popup_modal "recovery" "${txt_error_occurred_note}" "${txt_share_not_found_note}" ""
	fi
fi

# Konfiguration importieren - Ausführung
# --------------------------------------------------------------
if [[ "${get[page]}" == "recovery" && "${var[section]}" == "import" ]]; then
	[ -f "${get_request}" ] && rm "${get_request}"
	[ -f "${post_request}" ] && rm "${post_request}"

	if [ -d "${var[configshare]}" ]; then

		if [ -d "${var[configshare]}${var[configfolder]}/usersettings" ]; then

			cp -ru "${var[configshare]}${var[configfolder]}"/usersettings/backupjobs /var/packages/BasicBackup/target/ui/usersettings/
			exit_cp=${?}

			if [[ ${exit_cp} -eq 0 ]]; then
				popup_modal "recovery" "${txt_link_note}" "${txt_import_true_note}" ""
			else
				popup_modal "recovery" "${txt_error_occurred_note}" "${txt_import_false_note}" ""
			fi

		else
			popup_modal "recovery" "${txt_error_occurred_note}" "${txt_folder_not_found_info}" ""
		fi

	else
		popup_modal "recovery" "${txt_error_occurred_note}" "${txt_share_not_found_note}" ""
	fi
fi

