#!/bin/bash
# Filename: ssh_remote.sh - coded in utf-8

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

#lang="enu"

# Deutsche Sprachausgabe
# --------------------------------------------------------------
if [ "${gui_lang}" == "ger" ]; then
	echo '
	<div class="row">
		<div class="col">
			<p>
				Im Folgenden wird nun der Weg zum Aufbau einer SSH-Ordnerstruktur für einem Remote Server beschrieben.
			<p>
			<div class="alert alert-danger" role="alert">
				<strong>Hinweis 1:</strong><br />Handelt es sich bei dem verwendeten Remote Server um eine <strong>Synology DiskStation</strong>, dann aktivieren Sie im Vorfeld bitte den <strong>SSH Terminal-Dienst</strong>. Zum aktivieren des SSH Terminal-Dienstes gehen Sie zu <strong>DSM-Hauptmenü > Systemsteuerung > Terminal & SNMP</strong> und wechseln dort in den Reiter <strong>> Terminal</strong>. Aktiveren Sie die Checkbox <strong>SSH-Dienst aktivieren</strong>.<br /><br /><strong>Hinweis 2:</strong><br />Handelt es sich bei dem verwendeten Remote Server um eine <strong>Synology DiskStation</strong>, dann aktivieren Sie im Vorfeld bitte auch den <strong>rsync-Dienst</strong>. Zum <strong>aktivieren des rsync Dienstes</strong> gehen Sie zu <strong>DSM-Hauptmenü > Systemsteuerung > Dateidienste</strong> und wechseln dort in den Reiter <strong>> rsync</strong>. Aktiveren Sie die Checkbox <strong>rsync Dienst aktivieren</strong>. Als SSH-Verschlüsselungsport wird standardmäßig der Port 22 verwendet, welchen Sie bei Bedarf anpassen können.
				<br /><br /><strong>Hinweis 3:</strong><br />Handelt es sich bei dem verwendeten Remote Server um eine <strong>Synology DiskStation</strong>, dann aktivieren Sie im Vorfeld bitte außerdem den <strong>Benutzer-Home-Dienst</strong>, da die benötigten SSH-Verbindungsdaten im entsprechenden Benutzer-Home-Ordner des angemeldeten SSH-Benutzers abgelegt werden. Zum aktivieren des Benutzer-Home-Dienstes gehen Sie zu <strong>DSM-Hauptmenü > Systemsteuerung > Benutzer und Gruppe</strong> und wechseln dort in den Reiter <strong>> Erweitert</strong>. Aktiveren Sie unter dem Menüpunkt <strong>Benutzerbasis</strong> die Checkbox <strong>Benutzer-Home-Dienst aktiveren</strong>.<br /><br />Sollte es sich bei dem verwendeten <strong>Remote Server</strong> um ein anderes Gerät als eine Synology DiskStation handeln, stellen Sie bitte im Vorfeld sicher, das der <strong>SSH Dienst</strong> aktiviert sowie ein gültige <strong>Portnummer</strong> vergeben wurde. Stellen Sie des weiteren sicher, das die Verwendung des <strong>rsync-Dienstes</strong> sowie entsprechende <strong>Benutzer-Home-Ordner</strong> zur Verfügung stehen bzw. aktiviert wurden.
			</div>
			<h4 class="mt-4">Anmeldung auf dem Remote Server</h4>
			<div class="ps-4">
				<p>
					Stellen Sie unter Verwendung Ihrer Zugangsdaten über z.B. PuTTY oder direkt über einen Terminal, eine SSH-Verbindung zum Terminal Ihrers Remote Servers her. Im folgenden verwenden wir Beispielhaft diese Zugangsdaten.<br />
					<pre class="shadow-none p-1 mb-0 bg-light rounded">Benutzername : <span class="text-danger">user</span></pre>
					<pre class="shadow-none p-1 mb-0 bg-light rounded">Hostname     : <span class="text-danger">RemoteServer</span></pre>
					<pre class="shadow-none p-1 mb-0 bg-light rounded">IP-Adresse   : <span class="text-danger">192.168.2.20</span></pre>
					<pre class="shadow-none p-1 mb-0 bg-light rounded">Port         : <span class="text-danger">22</span></pre>
				</p>
				<div class="alert alert-danger" role="alert">
					<strong>Hinweis:</strong> Im Unterschied zur Einrichtung einer "SSH Verbindung auf der lokalen DiskStation", sollte hierbei nach Möglichkeit <strong>nicht</strong> das Root-Konto verwendet werden. Stattdessen sollte ein Benutzer ausgewählt werden, der über die nötigen Berechtigungen verfügt, eine SSH Verbindung aufzubauen und Zugriff auf die zu sichernden Daten hat. Handelt es sich bei dem Remote Server um eine <strong>Synology DiskStation</strong> ist weithin darauf zu achten, <strong>das nur Benutzer aus der Gruppe der Administratoren eine SSH Verbindung aufbauen dürfen</strong> Eine SSH-Verbindung als Systembenutzer root kann dagegen nur aufgebaut werden, wenn im DSM das Standard admin Konto aktiviert ist.
				</div>
				<p class="mt-3">
					<strong>Praxis Beispiel</strong><br />
					Im nachfolgenen Beispiel wählen wir uns wieder über das Terminal einer beliebigen Linux Distributionen ein.
				</p>
				<pre class="shadow-none p-1 mb-0 bg-light rounded"><span class="text-success">tux@LinuxDistro</span>:<span class="text-primary">~</span># ssh -p <span class="text-danger">22</span> <span class="text-danger">user</span>@<span class="text-danger">192.168.2.20</span></pre>
				<p class="mt-3">
					Nachdem die Verbindung zu Ihrem Remote Server aufgebaut wurde, werden Sie darum gebeten, Ihre Zugangsdaten einzugeben.
				</p>
				<pre class="shadow-none p-1 mb-0 bg-light rounded">login as: <span class="text-danger">user</span></pre>
				<pre class="shadow-none p-1 mb-1 bg-light rounded">user@192.168.2.20`s password:</pre>

				<p class="mt-3">
					Nach erfolgreicher Anmeldung sollte das Terminal ungefähr so aussehen.
				</p>
				<pre class="shadow-none p-2 mb-1 bg-light rounded"><span class="text-success">user@RemoteServer</span>:<span class="text-primary">~</span>$</pre>
				<p class="mt-3">
					<div class="alert alert-danger" role="alert">
						<strong>Hinweis:</strong> Handelt es sich bei dem Remote Server um ein Synology NAS kann es vorkommen, <strong>das der eigene Benutzer-Home-Ordner ~/ die falsche Gruppen- und Benutzerrechte</strong> (chmod 777 bzw. drwxrwxrwx) aufweist. Ist dies der Fall, wird ein künftiger SSH-Verbindungsversuch womöglich scheitern. Prüfen Sie daher die Gruppen- und Benutzerrechte und ändern diese gegebenenfalls auf <strong>chmod 755 bzw. drwxr-xr-x</strong>. Verwenden Sie dafür den Befehl <strong>sudo chmod 755 /var/services/homes/[USERNAME]</strong>
					</div>
				</p>
			</div>
			<h4 class="mt-4">SSH-Ordnerstruktur erstellen</h4>
			<div class="ps-4">
				<p>
					Als erstes wird im Benutzer-Home-Ordner von <span class="text-danger">user</span> ein neuer, versteckter Ordner angelegt.
				</p>
				<pre class="shadow-none p-2 mb-1 bg-light rounded"><span class="text-success">user@RemoteServer</span>:<span class="text-primary">~</span># mkdir -p ~/.ssh</pre>
				<ul>
					<li>-p steht für „parents“. Hierbei werden übergeordnete Ordner bzw. Ordnerstrukturen gleich mit angelegt.</li>
					<li>(~/ steht für das Benutzerverzeichnis des aktuell angemeldeten Benutzerkontos)</li>
				</ul>
			</div>
			<h4 class="mt-4">RSA-Key erzeugen</h4>
			<div class="ps-4">
				<p>
					An dieser Stelle würde auch hier ein RSA-Key erzeugt werden und zwar nach dem selben Prinzip, wie Sie es zuvor bereits auf Ihrer lokalen Synology DiskStation durchgeführt haben. Für die Arbeit mit Basic Backup ist dieser Schritt jedoch irrelevant und wird daher nicht weiter beschrieben.
				</p>
			</div>
			<h4 class="mt-4">authorized_keys anlegen</h4>
			<div class="ps-4">
				<p>
					In der Datei "authorized_keys" wird im späteren Verlauf der öffentliche Schlüssel Ihrer lokalen Synology DiskStation sowie weiterer bekannter Remote Server eingetragen, um so einen passwortlosen Verbindungsaufbau zu ermöglichen. Da die Datei noch nicht existiert, wird diese nun durch Eingabe des nachfolgenden Befehles erstellt.
				</p>
				<pre class="shadow-none p-2 mb-1 bg-light rounded"><span class="text-success">user@RemoteServer</span>:<span class="text-primary">~</span># touch ~/.ssh/authorized_keys</pre>
			</div>
			<h4 class="mt-4">Ordner- und Dateirechte setzen</h4>
			<div class="ps-4">
				<p>
					Zugriffsrechte für den erstellten Ordner ~/.ssh, sowie den beinhaltenden Dateien anpassen.
				</p>
				<pre class="shadow-none p-1 mb-0 bg-light rounded"><span class="text-success">user@RemoteServer</span>:<span class="text-primary">~</span># chmod 0700 ~/.ssh</pre>
				<pre class="shadow-none p-1 mb-0 bg-light rounded"><span class="text-success">user@RemoteServer</span>:<span class="text-primary">~</span># chmod 0600 ~/.ssh/authorized_keys</pre>
			</div>
			<p class="mt-3">
				Die SSH-Ordnerstruktur für Ihren Remote Server ist nun eingerichtet.
			</p>
			<p class="text-end"><br />
				<button type="button" class="btn btn-secondary btn-sm" data-bs-toggle="modal" data-bs-target="#help-ssh-rsa">Weiter mit '${txt_link_help_ssh_rsa}'</button>
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
				The following is now the way to set up an SSH folder structure for a remote server.
			<p>
			<div class="alert alert-danger" role="alert">
				<strong> Note 1: </strong> <br /> If the remote server used is a <strong> Synology DiskStation </strong>, please activate the <strong> SSH terminal service in advance </strong>. To activate the SSH terminal service, go to <strong> DSM main menu> Control panel> Terminal & SNMP </strong> and switch to the <strong>> Terminal </strong> tab. Activate the checkbox <strong> Activate SSH service </strong>. <br /> <br /> <strong> Note 2: </strong> <br /> If the remote server used is a <strong> Synology DiskStation </strong>, then please activate the <strong> rsync service </strong> in advance. To <strong> activate the rsync service </strong> go to <strong> DSM main menu > Control Panel > File Services </strong> and switch to the <strong>> rsync </strong> tab. Activate the checkbox <strong> Activate rsync service </strong>. Port 22 is used by default as the SSH encryption port, which you can adjust if necessary.
				<br /> <br /> <strong> Note 3: </strong> <br /> If the remote server used is a <strong> Synology DiskStation </strong>, then please also activate the in advance <strong> User home service </strong>, since the required SSH connection data is stored in the corresponding user home folder of the logged in SSH user. To activate the user home service, go to <strong> DSM main menu > Control Panel > Users and Groups </strong> and switch to the <strong>> Advanced </strong> tab. Activate the <strong> Activate user home service </strong> checkbox under the menu item <strong> User base </strong>. <br /> <br /> If the <strong> Remote Server </strong> is a device other than a Synology DiskStation, please make sure in advance that the <strong> SSH service </strong> has been activated and a valid <strong> port number </strong> has been assigned. Furthermore, make sure that the use of the <strong> rsync service </strong> and the corresponding <strong> user home folder </strong> are available or have been activated.
			</div>

			<h4 class="mt-4">Logging in to the remote server</h4>
			<div class="ps-4">
				<p>
					Using your credentials via e.g. PuTTY or directly via a terminal, establish an SSH connection to the terminal of your remote server. In the following we use exemplarily these access data.<br />
					<pre class="shadow-none p-1 mb-0 bg-light rounded">Username   : <span class="text-danger">user</span></pre>
					<pre class="shadow-none p-1 mb-0 bg-light rounded">Hostname   : <span class="text-danger">RemoteServer</span></pre>
					<pre class="shadow-none p-1 mb-0 bg-light rounded">IP address : <span class="text-danger">192.168.2.20</span></pre>
					<pre class="shadow-none p-1 mb-0 bg-light rounded">Port       : <span class="text-danger">22</span></pre>
				</p>
				<div class="alert alert-danger" role="alert">
					<strong>Note:</strong> Unlike setting up an "SSH connection on the local DiskStation", this should <strong>not</strong> use the root account if possible. Instead, a user should be selected who has the necessary permissions to establish an SSH connection and has access to the data to be backed up. If the remote server is a <strong>Synology DiskStation</strong>, care should be taken to ensure <strong>that only users from the Administrators group are allowed to establish an SSH connection</strong> On the other hand, an SSH connection as the root system user can only be established if the default admin account is enabled in the DSM.
				</div>
				<p class="mt-3">
					<strong>Practical example</strong><br />
					In the following example, we again dial in via the terminal of any Linux distribution.
				</p>
				<pre class="shadow-none p-1 mb-0 bg-light rounded"><span class="text-success">tux@LinuxDistro</span>:<span class="text-primary">~</span># ssh -p <span class="text-danger">22</span> <span class="text-danger">user</span>@<span class="text-danger">192.168.2.20</span></pre>
				<p class="mt-3">
					After the connection to your remote server is established, you will be asked to enter your credentials.
				</p>
				<pre class="shadow-none p-1 mb-0 bg-light rounded">login as: <span class="text-danger">user</span></pre>
				<pre class="shadow-none p-1 mb-1 bg-light rounded">user@192.168.2.20`s password:</pre>

				<p class="mt-3">
					After successful login, the terminal should look something like this.
				</p>
				<pre class="shadow-none p-2 mb-1 bg-light rounded"><span class="text-success">user@RemoteServer</span>:<span class="text-primary">~</span>$</pre>
				<p class="mt-3">
					<div class="alert alert-danger" role="alert">
						<strong>Note:</strong> If the remote server is a Synology NAS, it is possible that <strong>its own home folder ~/ has the wrong group and user permissions</strong> (chmod 777 or drwxrwxrwx). If this is the case, a future SSH connection attempt may fail. Therefore, check the group and user permissions and change them to <strong>chmod 755 or drwxr-xr-x</strong> if necessary. To do this, use the command <strong>sudo chmod 755 /var/services/homes/[USERNAME]</strong>
					</div>
				</p>
			</div>
			<h4 class="mt-4">Create SSH folder structure</h4>
			<div class="ps-4">
				<p>
					First, a new hidden folder is created in the user home folder of <span class="text-danger">user</span>.
				</p>
				<pre class="shadow-none p-2 mb-1 bg-light rounded"><span class="text-success">user@RemoteServer</span>:<span class="text-primary">~</span># mkdir -p ~/.ssh</pre>
				<ul>
					<li>-p stands for "parents". Here, parent folders or folder structures are created at the same time.</li>
					<li>(~/ stands for the user directory of the currently logged in user account)</li>
				</ul>
			</div>
			<h4 class="mt-4">Generate RSA key</h4>
			<div class="ps-4">
				<p>
					At this point, an RSA key would also be generated here, using the same principle as you have already done on your local Synology DiskStation before. However, this step is irrelevant for working with Basic Backup and is therefore not described further.
				</p>
			</div>
			<h4 class="mt-4">Create authorized_keys</h4>
			<div class="ps-4">
				<p>
					Later, the public key of your local Synology DiskStation and other known remote servers will be entered in the file "authorised_keys" to enable a password-free connection. Since the file does not yet exist, it is now created by entering the following command.
				</p>
				<pre class="shadow-none p-2 mb-1 bg-light rounded"><span class="text-success">user@RemoteServer</span>:<span class="text-primary">~</span># touch ~/.ssh/authorized_keys</pre>
			</div>
			<h4 class="mt-4">Set folder and file permissions</h4>
			<div class="ps-4">
				<p>
					Adjust access rights for the created ~/.ssh folder, as well as the containing files.
				</p>
				<pre class="shadow-none p-1 mb-0 bg-light rounded"><span class="text-success">user@RemoteServer</span>:<span class="text-primary">~</span># chmod 0700 ~/.ssh</pre>
				<pre class="shadow-none p-1 mb-0 bg-light rounded"><span class="text-success">user@RemoteServer</span>:<span class="text-primary">~</span># chmod 0600 ~/.ssh/authorized_keys</pre>
			</div>
			<p class="mt-3">
				The SSH folder structure for your remote server is now set up.
			</p>
			<p class="text-end"><br />
				<button type="button" class="btn btn-secondary btn-sm" data-bs-toggle="modal" data-bs-target="#help-ssh-rsa">Next with '${txt_link_help_ssh_rsa}'</button>
				<button type="button" class="btn btn-secondary btn-sm" data-bs-dismiss="modal">'${txt_button_Close}'</button>
			</p>
		</div>
	</div>'
fi
