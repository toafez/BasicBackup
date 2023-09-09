#!/bin/bash
# Filename: view.sh - coded in utf-8

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


# Kopfzeile des Protokolls
# --------------------------------------------------------------
if [[ "${get[page]}" == "view" ]]; then
	[ -f "${get_request}" ] && rm "${get_request}"

	echo '
	<!-- Modal -->
	<div class="modal fade" id="view" tabindex="-1" aria-labelledby="view-label" aria-hidden="true">
		<div class="modal-dialog modal-fullscreen">
			<div class="modal-content">
				<div class="modal-header bg-light">'
					# Systemprotokoll
					app_title=$(urldecode ${app_title})
					if [[ "${get[section]}" == "systemlog" ]]; then
						echo '<h5 class="modal-title" style="color: #FF8C00;">'${txt_view_system_log}'</h5>'
					fi
					# Datensicherungsprotokoll
					if [[ "${get[section]}" == "scriptlog" ]]; then
						logname="${get[file]##*/}"
						logname="${logname%.*}"
						logname=$(urldecode ${logname})
						echo '<h5 class="modal-title" style="color: #FF8C00;">'${txt_view_logfile}'<span class="text-secondary"> > '${logname}'</span></h5>'
					fi
					echo '
					<a href="index.cgi?page=main&section=start" class="btn-close" aria-label="Close" title="'${txt_button_Close}'"></a>
				</div>
				<div class="modal-body">
					<div class="row">
						<div class="col">'

							# Protokoll anzeigen
							# --------------------------------------------------------------
							get[file]=$(urldecode ${get[file]})

							if [ -z "${get[process]}" ] || [[ "${get[process]}" == "false" ]]; then
								if [ -s "${get[file]}" ]; then
									# Gebe Dateiinhalt aus
									echo '
									<div class="text-monospace text-nowrap" style="font-size: 87.5%;">'
										if [[ "${get[section]}" == "systemlog" ]]; then
											tac "${get[file]}" | while read line; do
												echo ''${line}'<br>'
											done
											unset line
										else
											while read line; do
												echo ''${line}'<br>'
											done < "${get[file]}"
											unset line
										fi
										echo '
									</div>'
								else
									echo ''${txt_view_file_not_found}''
								fi
							fi

							if [[ "${get[process]}" == "true" ]]; then
								echo '
								<div class="text-monospace text-nowrap" style="font-size: 87.5%;">
									<div id="refresh">
										<div id="area">'
											while read -r line; do
												echo ''${line}'<br>'
											done < "${get[file]}"
											#echo '<meta http-equiv="refresh" content="2" />'
											unset line
											echo '
										</div>
									</div>
								</div>'
							fi
							echo '
						</div>
					</div>

				<!-- Modal -->
				</div>
				<div class="modal-footer bg-light">'

					if [[ "${get[section]}" == "systemlog" ]]; then
						if [ -s "${usr_systemlog}" ]; then
							echo '
							<a href="'${app_link}'/usersettings/logfiles/'${get[file]##*/}'" class="btn btn-secondary btn-sm" download>'${txt_button_system_log_download}'</a>'
						fi
						echo '&nbsp;<a href="index.cgi?page=view&section=systemlog&query=delete&file='${get[file]}'" class="btn btn-secondary btn-sm">'${txt_button_system_log_delete}'</a>'
					fi	
					echo '
					<a href="index.cgi?page=main&section=start" class="btn btn-secondary btn-sm" aria-label="Close">'${txt_button_Close}'</a>
				</div>
			</div>
		</div>
	</div>
	<script type="text/javascript">
		$(window).on("load", function() {
			$("#view").modal("show");
		});
	</script>'

	# Systemprotokoll löschen
	# --------------------------------------------------------------
	if [[ "${get[query]}" == "delete" ]] && [ -z "${get[delete]}" ]; then
		[[ "${get[section]}" == "systemlog" ]] && popup_modal "view" "${txt_popup_delete_conf}" "${txt_popup_delete_systemlog}" "" "systemlog"
	elif [[ "${get[query]}" == "delete" ]]  && [[ "${get[delete]}" == "true" ]]; then
		[ -f "${get_request}" ] && rm "${get_request}"
		[ -f "${get[file]}" ] && :> "${get[file]}"
		if [[ "${get[section]}" == "systemlog" ]]; then
			echo '<meta http-equiv="refresh" content="0; url=index.cgi?page=view&section=systemlog&file='${usr_systemlog}'&query=&delete=">'
		fi
	fi
fi
