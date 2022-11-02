#!/bin/bash
# Filename: debug.sh - coded in utf-8

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


# Horizontale Navigationsleiste laden
# --------------------------------------------------------------
mainnav

# Startseite anzeigen
# --------------------------------------------------------------
if [[ "${get[page]}" == "debug" && "${get[section]}" == "start" ]]; then

	if [[ "${get[expert]}" == "on" ]]; then
		# Debug
		# --------------------------------------------------------------
		echo '
		<div class="row">
			<div class="col">
				<div class="card border-0">
					<div class="card-header ps-0 pb-0 bg-body border-0">
						<h5>Debug - Error analysis options</h5>
					</div>
				</div>
				<div class="card-body">
					<div class="row">
						<div class="col-sm-12">
							<table class="table table-borderless table-hover table-sm">
								<thead></thead>
								<tbody>
									<tr>'
										# GET & POST requests
										if [[ "${http_requests}" == "on" ]]; then
											echo '
											<td scope="row" class="row-sm-auto">
												GET & POST Requests
											</td>
											<td class="text-end">
												<a class="material-icons text-success" href="index.cgi?page=debug&section=save&option=http_requests&query=off&expert=on">
													<i style="font-size: 1.1rem;" class="bi bi-check-square text-secondary"></i>
												</a>
											</td>'
										else
											echo '
											<td scope="row" class="row-sm-auto">
												GET & POST Requests
											</td>
											<td class="text-end">
												<a class="material-icons text-success" href="index.cgi?page=debug&section=save&option=http_requests&query=on&expert=on">
													<i style="font-size: 1.1rem;" class="bi bi-square text-secondary"></i>
												</a>
											</td>'
										fi
										echo '
									</tr>
									<tr>'
										# Group membership
										if [[ "${group_membership}" == "on" ]]; then
											echo '
											<td scope="row" class="row-sm-auto">
												Group membership
											</td>
											<td class="text-end">
												<a class="material-icons text-success" href="index.cgi?page=debug&section=save&option=group_membership&query=off&expert=on">
													<i style="font-size: 1.1rem;" class="bi bi-check-square text-secondary"></i>
												</a>
											</td>'
										else
											echo '
											<td scope="row" class="row-sm-auto">
												Group membership
											</td>
											<td class="text-end">
												<a class="material-icons text-success" href="index.cgi?page=debug&section=save&option=group_membership&query=on&expert=on">
													<i style="font-size: 1.1rem;" class="bi bi-square text-secondary"></i>
												</a>
											</td>'
										fi
										echo '
									</tr>
									<tr>'
										# Local enviroment
										if [[ "${local_enviroment}" == "on" ]]; then
											echo '
											<td scope="row" class="row-sm-auto">
												Local enviroment
											</td>
											<td class="text-end">
												<a class="material-icons text-success" href="index.cgi?page=debug&section=save&option=local_enviroment&query=off&expert=on">
													<i style="font-size: 1.1rem;" class="bi bi-check-square text-secondary"></i>
												</a>
											</td>'
										else
											echo '
											<td scope="row" class="row-sm-auto">
												Local enviroment
											</td>
											<td class="text-end">
												<a class="material-icons text-success" href="index.cgi?page=debug&section=save&option=local_enviroment&query=on&expert=on">
													<i style="font-size: 1.1rem;" class="bi bi-square text-secondary"></i>
												</a>
											</td>'
										fi
										echo '
									</tr>
									<tr>'
										# Global enviroment
										if [[ "${global_enviroment}" == "on" ]]; then
											echo '
											<td scope="row" class="row-sm-auto">
												Global enviroment
											</td>
											<td class="text-end">
												<a class="material-icons text-success" href="index.cgi?page=debug&section=save&option=global_enviroment&query=off&expert=on">
													<i style="font-size: 1.1rem;" class="bi bi-check-square text-secondary"></i>
												</a>
											</td>'
										else
											echo '
											<td scope="row" class="row-sm-auto">
												Global enviroment
											</td>
											<td class="text-end">
												<a class="material-icons text-success" href="index.cgi?page=debug&section=save&option=global_enviroment&query=on&expert=on">
													<i style="font-size: 1.1rem;" class="bi bi-square text-secondary"></i>
												</a>
											</td>'
										fi
										echo '
									</tr>
								</tbody>
							</table>
						</div>
					</div>
				</div>'

				echo '
			</div>
		</div>'
	elif [[ "${get[expert]}" == "off" ]]; then
		[ -f "${usr_debugfile}" ] && rm "${usr_debugfile}"
		echo '<meta http-equiv="refresh" content="0; url=index.cgi?page=main&section=start">'
	fi
fi

# Debug - Ausführung
# --------------------------------------------------------------
if [[ "${get[page]}" == "debug" && "${get[section]}" == "save" ]]; then
	[ -f "${get_request}" ] && rm "${get_request}"

	# Speichern der Einstellungen nach ${app_home}/settings/user_settings.txt
	"${set_keyvalue}" "${usr_debugfile}" "expert" "${get[expert]}"
	[[ "${get[option]}" == "http_requests" ]] && "${set_keyvalue}" "${usr_debugfile}" "http_requests" "${get[query]}"
	[[ "${get[option]}" == "group_membership" ]] && "${set_keyvalue}" "${usr_debugfile}" "group_membership" "${get[query]}"
	[[ "${get[option]}" == "local_enviroment" ]] && "${set_keyvalue}" "${usr_debugfile}" "local_enviroment" "${get[query]}"
	[[ "${get[option]}" == "global_enviroment" ]] && "${set_keyvalue}" "${usr_debugfile}" "global_enviroment" "${get[query]}"
	echo '<meta http-equiv="refresh" content="0; url=index.cgi?page=debug&section=start&expert=on">'
fi
