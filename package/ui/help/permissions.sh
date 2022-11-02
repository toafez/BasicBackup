#!/bin/bash
# Filename: permissions.sh - coded in utf-8

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

#lang="enu"

# Deutsche Sprachausgabe
# --------------------------------------------------------------
if [ "${gui_lang}" == "ger" ]; then
	echo '
	<div class="row">
		<div class="col">
			<p>
				Nach der Installation von Basic Backup verfügt die App zunächst nur über sehr eingeschränkte Berechtigungen. Das hat zur Folge, das u.a. der Zugriff auf die freigegebenen Ordner sowie die Ausführung von Dateioperationen nur teilweise möglich ist. Des weiteren kann eine Vielzahl systemnaher Befehle nicht ausgeführt werden, die den reibungslosen Betrieb von Basic Backup stören.
			</p>
			<p>
				Zur Aufhebung der grade genannten Beschränkungen kann man veranlassen, das Basic Backup in die Gruppe der Administratoren aufgenommen wird, was jedoch Root Berechtigungen voraussetzt. Da Basic Backup jedoch über keine Root Berechtigungen verfügt, muss dieser Schritt durch den Benutzer bzw. durch einen Administrator selbst vorgenommen werden. Im Folgenden wird nun beschrieben, wie man die App-Berechtigungen von Basic Backup erweitern und auch wieder einschränken kann. Letzteres wäre z.B. vor einer Deinstallation von Basic Backup anzuraten.
			</p>
			<br />
			<ul class="list-unstyled ps-4">
				<li><strong>Erweitern bzw. beschränken der App-Berechtigungen über die Konsole</strong></li>
					<ol>
						<li>Melden Sie sich als Benutzer <span class="text-danger fst-italic">root</span> auf der Konsole Ihrer DiskStation an.
							<ul class="list-unstyled ps-3 pt-2">
								<li>Befehl zum erweiteren der App-Berechtigungen</li>
								<li>
									<small>
										<pre class="text-dark p-1 border border-1 rounded bg-light">/usr/syno/synoman/webman/3rdparty/'${app_name}'/app_permissions.sh "adduser"</pre>
									</small>
								</li>
							</ul>
							<ul class="list-unstyled ps-3 pt-2">
								<li>Befehl, um die App-Berechtigungen wieder zu beschränken</li>
								<li>
									<small>
										<pre class="text-dark p-1 border border-1 rounded bg-light">/usr/syno/synoman/webman/3rdparty/'${app_name}'/app_permissions.sh "deluser"</pre>
									</small>
								</li>
							</ul>
						</li>
					</ol>
				<li><strong>Erweitern bzw. beschränken der App-Berechtigungen über den Aufgabenplaner</strong></li>
					<ol>
						<li>
							Im DSM unter <span class="text-danger fst-italic">Hauptmenü</span> > <span class="text-danger fst-italic">Systemsteuerung</span> den <span class="text-danger fst-italic">Aufgabenplaner</span> öffnen.
						</li>
						<li>
							Im Aufgabenplaner über die Schaltfläche <span class="text-danger fst-italic">Erstellen</span> > <span class="text-danger fst-italic">Geplante Aufgabe</span> > <span class="text-danger fst-italic">Benutzerdefiniertes Script</span> auswählen.
						</li>
						<li>
							In dem nun geöffneten Pop-up-Fenster im Reiter <span class="text-danger fst-italic">Allgemein</span> > <span class="text-danger fst-italic">Allgemeine Einstellungen</span> der Aufgabe einen Namen geben und als Benutzer <span class="text-danger fst-italic">root</span> auswählen. Außerdem den Haken bei <span class="text-danger fst-italic">Aktiviert</span> entfernen.
						</li>
						<li>
							Im Reiter <span class="text-danger fst-italic">Aufgabeneinstellungen</span> > <span class="text-danger fst-italic">Befehl ausführen</span> > <span class="text-danger fst-italic">Benutzerdefiniertes Script</span> nachfolgenden Befehl in das Textfeld einfügen...
						</li>
							<ul class="list-unstyled ps-3 pt-2">
								<li>Befehl zum erweiteren der App-Berechtigungen</li>
								<li>
									<small>
										<pre class="text-dark p-1 border border-1 rounded bg-light">/usr/syno/synoman/webman/3rdparty/'${app_name}'/app_permissions.sh "adduser"</pre>
									</small>
								</li>
							</ul>
							<ul class="list-unstyled ps-3 pt-2">
								<li>Befehl, um die App-Berechtigungen wieder zu beschränken</li>
								<li>
									<small>
										<pre class="text-dark p-1 border border-1 rounded bg-light">/usr/syno/synoman/webman/3rdparty/'${app_name}'/app_permissions.sh "deluser"</pre>
									</small>
								</li>
							</ul>
						<li>
							Eingaben mit <span class="text-danger fst-italic">OK</span> speichern und die anschließende Warnmeldung ebenfalls mit <span class="text-danger fst-italic">OK</span> bestätigen.
						</li>
						<li>
							Die grade erstellte Aufgabe in der Übersicht des Aufgabenplaners <span class="text-danger fst-italic">markieren</span>, jedoch <span class="text-decoration-underline">nicht</span> aktivieren (die Zeile sollte nach dem markieren blau hinterlegt sein).
						</li>
						<li>
							Führen Sie die Aufgabe durch Betätigen Sie Schaltfläche <span class="text-danger fst-italic">Ausführen</span> einmalig aus.
						</li>
						<li>
							Schließen Sie '${app_name}' und rufen die App erneut auf, damit die Änderungen wirksam werden.
						</li>
					</ol>
			</ul>
			<p class="text-end"><br />
				<button type="button" class="btn btn-secondary btn-sm" data-bs-dismiss="modal">'${txt_button_Close}'</button>
			</p>
		</div>
	</div>'
else
	# Englische Sprachausgabe
	# --------------------------------------------------------------
	echo '
	<div class="row">
		<div class="col">
			<p>
				After installing Basic Backup, the app initially has only very limited permissions. This means that, among other things, access to the shared folders and the execution of file operations is only partially possible. Furthermore, a large number of system-related commands cannot be executed, which disrupts the smooth operation of Basic Backup.
			</p>
			<p>
				In order to remove the above-mentioned restrictions, Basic Backup can be added to the administrators group, which, however, requires root permissions. Since Basic Backup does not have root permissions, this step must be taken by the user or by an administrator. In the following, we will describe how the app permissions of Basic Backup can be extended and also restricted again. The latter would be advisable, for example, before uninstalling Basic Backup.
			</p>
			<br />
			<ul class="list-unstyled ps-4">
				<li><strong>Extending or restricting app permissions via the console</strong></li>
					<ol>
						<li>Log in as user <span class="text-danger fst-italic">root</span> on your DiskStation`s console.
							<ul class="list-unstyled ps-3 pt-2">
								<li>Command to extend the app permissions</li>
								<li>
									<small>
										<pre class="text-dark p-1 border border-1 rounded bg-light">/usr/syno/synoman/webman/3rdparty/'${app_name}'/app_permissions.sh "adduser"</pre>
									</small>
								</li>
							</ul>
							<ul class="list-unstyled ps-3 pt-2">
								<li>Command to restrict the app permissions again</li>
								<li>
									<small>
										<pre class="text-dark p-1 border border-1 rounded bg-light">/usr/syno/synoman/webman/3rdparty/'${app_name}'/app_permissions.sh "deluser"</pre>
									</small>
								</li>
							</ul>
						</li>
					</ol>
				<li><strong>Extend or restrict app permissions via the task planner</strong></li>
					<ol>
						<li>
							In the DSM under <span class="text-danger fst-italic">Main menu</span> > <span class="text-danger fst-italic">Control Panel</span> open the <span class="text-danger fst-italic">Task Scheduler</span>.
						</li>
						<li>
							In the task planner via the <span class="text-danger fst-italic">Create button</span> > <span class="text-danger fst-italic">Select scheduled task</span> > <span class="text-danger fst-italic">Custom script</span>.
						</li>
						<li>
							In the pop-up window that now opens, in the <span class="text-danger fst-italic">General</span> > <span class="text-danger fst-italic">General settings</span> tab , give the task a name and select <span class="text-danger fst-italic">root</span> as the user. Also remove the checkmark from<span class="text-danger fst-italic">Enabled</span>.
						</li>
						<li>
							In the <span class="text-danger fst-italic">Task setting tab</span> > <span class="text-danger fst-italic">Execute command</span> > <span class="text-danger fst-italic">Paste custom script</span> the following command into the text field...
						</li>
							<ul class="list-unstyled ps-3 pt-2">
								<li>Command to extend the app permissions</li>
								<li>
									<small>
										<pre class="text-dark p-1 border border-1 rounded bg-light">/usr/syno/synoman/webman/3rdparty/'${app_name}'/app_permissions.sh "adduser"</pre>
									</small>
								</li>
							</ul>
							<ul class="list-unstyled ps-3 pt-2">
								<li>Command to restrict the app permissions again</li>
								<li>
									<small>
										<pre class="text-dark p-1 border border-1 rounded bg-light">/usr/syno/synoman/webman/3rdparty/'${app_name}'/app_permissions.sh "deluser"</pre>
									</small>
								</li>
							</ul>
						<li>
							Save entries with <span class="text-danger fst-italic">OK</span> and confirm the subsequent warning message also with <span class="text-danger fst-italic">OK</span>.
						</li>
						<li>
							The just created task in the overview of the task planner <span class="text-danger fst-italic">mark</span>, but <span class="text-decoration-underline">do not</span> activate (the line should be highlighted in blue after marking).
						</li>
						<li>
							Execute the task by pressing button <span class="text-danger fst-italic">Run</span> once.
						</li>
						<li>
							Close '${app_name}' and call the app again for the changes to take effect.
						</li>
					</ol>
			</ul>
			<p class="text-end"><br />
				<button type="button" class="btn btn-secondary btn-sm" data-bs-dismiss="modal">'${txt_button_Close}'</button>
			</p>
		</div>
	</div>'
fi
