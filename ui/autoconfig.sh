#!/bin/bash
# Filename: autoconfig.sh - coded in utf-8

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


# Horizontale Navigationsleiste laden
# --------------------------------------------------------------
mainnav

# Startseite anzeigen
# --------------------------------------------------------------
if [[ "${get[page]}" == "autoconfig" && "${get[section]}" == "start" ]]; then

	echo '
	<div class="row">
		<div class="col">'

			# USB/SATA-AutoPilot Einstellungen
			# --------------------------------------------------
			echo '
			<div class="card border-0">
				<div class="card-header ps-0 pb-0 bg-body border-0">
					<h5>'${txt_pilot_settings}'</h5>
				</div>
			</div>
			<div class="card-body">
				<div class="row">
					<div class="col-sm-12">
						<table class="table table-borderless table-hover table-sm">
							<thead></thead>
							<tbody>
								<tr>'
									# Einhängen ein/aus
									echo -n '
									<td scope="row" class="row-sm-auto">
										'${txt_pilot_connect}'
									</td>
									<td class="text-end">'
										echo -n '
										<a class="material-icons text-success" href="index.cgi?page=autoconfig&section=save&option=connect&'; \
											if [[ "${connect}" == "true" ]]; then
												echo -n 'query=false">
												<i style="font-size: 1.1rem;" class="bi bi-check-square text-secondary"></i>'
											else
												echo -n 'query=true">
												<i style="font-size: 1.1rem;" class="bi bi-square text-secondary"></i>'
											fi
											echo -n '
										</a>
									</td>
								</tr>
								<tr>'
									# Auswerfen ein/aus
									echo -n '
									<td scope="row" class="row-sm-auto">
										'${txt_pilot_disconnect}'
									</td>
									<td class="text-end">&nbsp;</td>
								</tr>
								<tr>'
									# Niemals auswerfen ein/aus
									echo '
									<td scope="row" class="row-sm-auto">
										<span class="ps-3">
											<i class="bi bi-dot"></i> '${txt_pilot_disconnect_never}'
										</span>
									</td>
									<td class="text-end">'
										echo -n '
										<a class="material-icons text-success" href="index.cgi?page=autoconfig&section=save&option=disconnect&'; \
											if [[ "${disconnect}" == "false" ]]; then
												echo -n 'query=">
												<i style="font-size: 1.1rem;" class="bi bi-check-square text-secondary"></i>'
											else
												echo -n 'query=false">
												<i style="font-size: 1.1rem;" class="bi bi-square text-secondary"></i>'
											fi
											echo -n '
										</a>
									</td>
								</tr>
								<tr>'
									# Automatisch auswerfen ein/aus
									echo '
									<td scope="row" class="row-sm-auto">
										<span class="ps-3">
											<i class="bi bi-dot"></i> '${txt_pilot_disconnect_auto}'
										</span>
									</td>
									<td class="text-end">'
										echo -n '
										<a class="material-icons text-success" href="index.cgi?page=autoconfig&section=save&option=disconnect&'; \
											if [[ "${disconnect}" == "auto" ]]; then
												echo -n 'query=">
												<i style="font-size: 1.1rem;" class="bi bi-check-square text-secondary"></i>'
											else
												echo -n 'query=auto">
												<i style="font-size: 1.1rem;" class="bi bi-square text-secondary"></i>'
											fi
											echo -n '
										</a>
									</td>
								</tr>
								<tr>'
									# Manuell auswerfen ein/aus
									echo '
									<td scope="row" class="row-sm-auto">
										<span class="ps-3">
											<i class="bi bi-dot"></i> '${txt_pilot_disconnect_manual}'
										</span>
									</td>
									<td class="text-end">'
										echo -n '
										<a class="material-icons text-success" href="index.cgi?page=autoconfig&section=save&option=disconnect&'; \
											if [[ "${disconnect}" == "manual" ]]; then
												echo -n 'query=">
												<i style="font-size: 1.1rem;" class="bi bi-check-square text-secondary"></i>'
											else
												echo -n 'query=manual">
												<i style="font-size: 1.1rem;" class="bi bi-square text-secondary"></i>'
											fi
											echo -n '
										</a>
									</td>
								</tr>
								<tr>'
									# Optische und akustische Signalausgabe ein/aus
									echo '
									<td scope="row" class="row-sm-auto">
										'${txt_pilot_signal}'
									</td>
									<td class="text-end">'
										echo -n '
										<a class="material-icons text-success" href="index.cgi?page=autoconfig&section=save&option=signal&'; \
											if [[ "${signal}" == "true" ]]; then
												echo -n 'query=">
												<i style="font-size: 1.1rem;" class="bi bi-check-square text-secondary"></i>'
											else
												echo -n 'query=true">
												<i style="font-size: 1.1rem;" class="bi bi-square text-secondary"></i>'
											fi
											echo -n '
										</a>
									</td>
								</tr>
							</tbody>
						</table>
					</div>
				</div>
			</div>'

			# Einen externen Datenträger für USB/SATA-AutoPilot einrichten
			# --------------------------------------------------
			echo '
			<div class="card border-0">
				<div class="card-header ps-0 pb-0 bg-body border-0">
					<h5>'${txt_pilot_external_setting}'</h5>
				</div>
			</div>
			<div class="card-body">
				<div class="row">
					<div class="col-sm-12">'
						# Externen Datenträger über die Konsole einrichten
						echo '
						<div class="accordion" id="Accordion-03">
							<div class="accordion-item border-0 pb-1">
								<h2 class="accordion-header" id="Heading-03">
									<button class="accordion-button collapsed bg-light accordion-glow-off py-2" type="button" data-bs-toggle="collapse" data-bs-target="#Collapse-03" aria-expanded="false" aria-controls="collapseTwo">
										<span class="text-dark">
											'${txt_pilot_external_console}'
										</span>
									</button>
								</h2>
								<div id="Collapse-03" class="accordion-collapse collapse border-white" aria-labelledby="Heading-03" data-bs-parent="#Accordion-03">
									<div class="accordion-body">
										<ol>
											<li>'${txt_pilot_ext_console_step_1}'</li>
											<li>'${txt_pilot_ext_console_step_2}'
												<br /><br />
												<ul class="list-unstyled ps-3">
													<li>
														<small>
															<pre class="text-dark p-1 border border-1 rounded bg-light">cd /volumeUSB1/usbshare</pre>
														</small>
													</li>
												</ul>
											</li>
											<li>'${txt_pilot_ext_console_step_3}'
												<br /><br />
												<ul class="list-unstyled ps-3">
													<li>
														<small>
															<pre class="text-dark p-1 border border-1 rounded bg-light">touch autopilot</pre>
															<pre class="text-dark p-1 border border-1 rounded bg-light">chmod a+x autopilot</pre>
														</small>
													</li>
												</ul>
											</li>
											<li>'${txt_pilot_ext_console_step_4}'
												<br /><br />
												<ul class="list-unstyled ps-3">
													<li>
														'${txt_pilot_ext_console_step_5}'<br /><br />
														<small>
															<pre class="text-dark p-1 border border-1 rounded bg-light">cat > autopilot</pre>
														</small>
														'${txt_pilot_ext_console_step_6}'<br /><br />
														<small>
															<pre class="text-dark p-1 border border-1 rounded bg-light">#!/bin/bash<br />bash /usr/syno/synoman/webman/3rdparty/BasicBackup/rsync.sh --job-name="<span class="text-danger fst-italic">TASKNAME</span>"<br />exit ${?}</pre>
														</small>
														'${txt_pilot_ext_console_step_7}'
													</li>
												</ul>
											</li><br />
											<li>'${txt_pilot_ext_console_step_8}'</li>
										</ol>
									</div>
								</div>
							</div>
						</div>'
						# Externen Datenträger über den DSM einrichten
						echo '
						<div class="accordion" id="Accordion-04">
							<div class="accordion-item border-0">
								<h2 class="accordion-header" id="Heading-04">
									<button class="accordion-button collapsed bg-light accordion-glow-off py-2" type="button" data-bs-toggle="collapse" data-bs-target="#Collapse-04" aria-expanded="false" aria-controls="collapseTwo">
										<span class="text-dark">
											'${txt_pilot_external_gui}'
										</span>
									</button>
								</h2>
								<div id="Collapse-04" class="accordion-collapse collapse border-white" aria-labelledby="Heading-04" data-bs-parent="#Accordion-04">
									<div class="accordion-body">
										<ol>
											<li>'${txt_pilot_ext_gui_step_1}'</li>
											<li>'${txt_pilot_ext_gui_step_2}'</li>
											<li>'${txt_pilot_ext_gui_step_3}'
												<br /><br />
												<ul class="list-unstyled ps-3">
													<li>
														<small>
															<pre class="text-dark p-1 border border-1 rounded bg-light">#!/bin/bash<br />bash /usr/syno/synoman/webman/3rdparty/BasicBackup/rsync.sh --job-name="<span class="text-danger fst-italic">TASKNAME</span>"<br />exit ${?}</pre>
														</small>
													</li>
												</ul>
											</li>
											<li>'${txt_pilot_ext_gui_step_4}'</li>
											<li>'${txt_pilot_ext_gui_step_5}'</li>
												<br />
												<ul>
													<li>'${txt_pilot_ext_gui_step_6}'</li>
													<br />
													<li>'${txt_pilot_ext_gui_step_7}'</li>
												</ul>
												<br />
											<li>'${txt_pilot_ext_gui_step_8}'</li>
										</ol>
									</div>
								</div>
							</div>
						</div>'

						echo '
					</div>
				</div>
			</div>'

			echo '
		</div>
	</div>'
fi

# autoconfig - Speichern
# --------------------------------------------------------------
if [[ "${get[page]}" == "autoconfig" && "${get[section]}" == "save" ]]; then
	[ -f "${get_request}" ] && rm "${get_request}"

	# Speichern der Einstellungen nach ${app_home}/settings/user_settings.txt
	[[ "${get[option]}" == "connect" ]] && "${set_keyvalue}" "${usr_autoconfig}" "connect" "${get[query]}"
	[[ "${get[option]}" == "disconnect" ]] && "${set_keyvalue}" "${usr_autoconfig}" "disconnect" "${get[query]}"
	[[ "${get[option]}" == "signal" ]] && "${set_keyvalue}" "${usr_autoconfig}" "signal" "${get[query]}"
	echo '<meta http-equiv="refresh" content="0; url=index.cgi?page=autoconfig&section=start">'
fi