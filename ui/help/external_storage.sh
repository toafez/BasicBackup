#!/bin/bash
# Filename: external_storage.sh - coded in utf-8

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

#lang="enu"

# Deutsche Sprachausgabe
# --------------------------------------------------------------
if [ "${gui_lang}" == "ger" ]; then
	echo '
	<div class="row">
		<div class="col">'
			# Externen Datenträger über die Konsole einrichten
			echo '
			<ul class="list-unstyled ps-4">
				<li><h5>'${txt_pilot_external_console}'</h5></li>
				<li>
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
				</li>
			</ul><br />'
			# Externen Datenträger über den DSM einrichten
			echo '
			<ul class="list-unstyled ps-4">
				<li><h5>'${txt_pilot_external_gui}'</h5></li>	
				<li>
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
				</li>
			</ul>
		</div>
	</div>'
else
	# Englische Sprachausgabe
	# --------------------------------------------------------------
	echo '
	<div class="row">
		<div class="col">'
			# Externen Datenträger über die Konsole einrichten
			echo '
			<ul class="list-unstyled ps-4">
				<li><h5>'${txt_pilot_external_console}'</h5></li>
				<li>
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
				</li>
			</ul><br />'
			# Externen Datenträger über den DSM einrichten
			echo '
			<ul class="list-unstyled ps-4">
				<li><h5>'${txt_pilot_external_gui}'</h5></li>	
				<li>
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
				</li>
			</ul>
		</div>
	</div>'
fi
