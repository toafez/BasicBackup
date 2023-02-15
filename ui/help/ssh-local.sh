#!/bin/bash
# Filename: ssh_local.sh - coded in utf-8

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
		<div class="col">
			<p>
				Bei der Secure Shell, kurz SSH genannt, handelt es sich um ein Netzwerkprotokoll zum Aufbau von verschlüsselten Verbindungen zwischen Geräten im lokalen Netzwerk oder über das Internet. Die Anmeldung erfolgt hierbei in der Regel über die Eingabe eines Benutzernamens sowie dem zugehörigen Passwortes. Neben dem Verbindungsaufbau direkt über das Terminal (auch Konsole oder Shell genannt) einer beliebigen Linux-Distribution, der Windows Eingabeaufforderung oder der Windows PowerShell, kommen auch grafische Benutzeroberflächen wie z.B. PuTTY zum Einsatz.
			</p>
			<p>
				Unter Verwendung einer RSA Schlüssel Authentifizierung entfällt während des SSH-Verbindungsaufbaues zu einem Remote Server die Eingabe von Benutzername und Passwort. Das ermöglicht einen automatisierten Verbindungsaufbau, ohne die Gegenwart eines Benutzers. Die Authentifizierung erfolgt hierbei durch einen, im Vorfeld generierten passwortlosen privaten Schlüssel, sowie ein daraus resultierender, öffentlicher Schlüssel.
			</p>
			<p>
				Durch den automatisierten Verbindungsaufbau wird Basic Backup in die Lage versetzt, Datensicherungsaufgaben von oder auf rsync-kompatible Remote Server auszuführen. Die Art der Datensicherungsrichtung bestimmt hierbei die Verbindungsart. Man unterscheidet somit zwischen zwei möglichen Verbindungsarten.
			</p>
			<div class="ps-4">
				<ul>
					<li class="mb-3">
						<strong>Push Backup, auch to SSH genannt.</strong><br />
						Hierbei werden die zu sichernden Daten von der DiskStation in Richtung des rsync-kompatiblen Remote Servers übertragen und gesichert.
					</li>
					<li>
						<strong>Pull  Backup, auch from SSH genannt.</strong><br />
						Hierbei werden die zu sichernden Daten von einem rsync-kompatiblen Remote Server, durch die DiskStation abgeholt und lokal gesichert.
					</li>
				</ul>
			</div>
			<p>
				Im Folgenden wird nun der Weg zum Aufbau einer SSH-Ordnerstruktur sowie das erzeugen eines privaten- und öffentlichen RSA-Schlüssel beschrieben.
			</p>
			<h4 class="mt-4">Anmeldung auf der lokalen DiskStation</h4>
			<div class="ps-4">
				<div class="alert alert-danger" role="alert">
					<strong>Hinweis 1:</strong><br />Aktivieren Sie im Vorfeld bitte den <strong>SSH Terminal-Dienst</strong>. Zum aktivieren des SSH Terminal-Dienstes gehen Sie zu <strong>DSM-Hauptmenü > Systemsteuerung > Terminal & SNMP</strong> und wechseln dort in den Reiter <strong>> Terminal</strong>. Aktiveren Sie die Checkbox <strong>SSH-Dienst aktivieren</strong>.<br /><br /><strong>Hinweis 2:</strong><br />Aktivieren Sie im Vorfeld bitte auch den <strong>rsync-Dienst</strong>. Zum <strong>aktivieren des rsync Dienstes</strong> gehen Sie zu <strong>DSM-Hauptmenü > Systemsteuerung > Dateidienste</strong> und wechseln dort in den Reiter <strong>> rsync</strong>. Aktiveren Sie die Checkbox <strong>rsync Dienst aktivieren</strong>. Als SSH-Verschlüsselungsport wird standardmäßig der Port 22 verwendet, welchen Sie bei Bedarf anpassen können.<br /><br /><strong>Hinweis 3:</strong><br />Aktivieren Sie im Vorfeld bitte außerdem den <strong>Benutzer-Home-Dienst</strong>, da die benötigten SSH-Verbindungsdaten im entsprechenden Benutzer-Home-Ordner des angemeldeten SSH-Benutzers abgelegt werden. Zum aktivieren des Benutzer-Home-Dienstes gehen Sie zu <strong>DSM-Hauptmenü > Systemsteuerung > Benutzer und Gruppe</strong> und wechseln dort in den Reiter <strong>> Erweitert</strong>. Aktiveren Sie unter dem Menüpunkt <strong>Benutzerbasis</strong> die Checkbox <strong>Benutzer-Home-Dienst aktiveren</strong>.
				</div>
				<p class="mt-3">
					Stellen Sie unter Verwendung Ihrer Zugangsdaten über z.B. PuTTY oder direkt über einen Terminal eine SSH-Verbindung zum Terminal Ihrer lokalen Diskstation her. Achten Sie darauf, das es nur Benutzern aus der Gruppe der Administratoren erlaubt ist, Zugriff per SSH zu erhalten. Im folgenden verwenden wir Beispielhaft diese Zugangsdaten.<br />
					<pre class="shadow-none p-1 mb-0 bg-light rounded">Benutzername : <span class="text-danger">admin</span></pre>
					<pre class="shadow-none p-1 mb-0 bg-light rounded">Hostname     : <span class="text-danger">DiskStation</span></pre>
					<pre class="shadow-none p-1 mb-0 bg-light rounded">IP-Adresse   : <span class="text-danger">192.168.2.10</span></pre>
					<pre class="shadow-none p-1 mb-0 bg-light rounded">Port         : <span class="text-danger">22</span></pre>
				</p>
				<p class="mt-3">
					Im nachfolgenen Beispiel wählen wir uns über das Terminal einer beliebigen Linux Distribution ein. Der Befehl für die Einwahl lautet...
				</p>
				<p class="mt-3">
					<strong>Syntax</strong>
					<pre class="shadow-none p-2 mb-1 bg-light rounded">ssh -p [<span class="text-danger">PORT</span>] [<span class="text-danger">USERNAME</span>]@[<span class="text-danger">SERVER-ADDRESS</span>]</pre>
				</p>
				<p class="mt-3">
					<strong>Praxis Beispiel</strong><br />
					<pre class="shadow-none p-1 mb-0 bg-light rounded"><span class="text-success">tux@LinuxDistro</span>:<span class="text-primary">~</span># ssh -p <span class="text-danger">22</span> <span class="text-danger">admin</span>@<span class="text-danger">192.168.2.10</span></pre>
				</p>
				<p class="mt-3">
					Nachdem die Verbindung zu Ihrer lokalen DiskStation aufgebaut wurde, werden Sie darum gebeten, Ihre Zugangsdaten einzugeben.
				</p>
				<pre class="shadow-none p-1 mb-0 bg-light rounded">login as: <span class="text-danger">admin</span></pre>
				<pre class="shadow-none p-1 mb-0 bg-light rounded">admin@192.168.2.10`s password:</pre>
				<p class="mt-3">
					Nach erfolgreicher Anmeldung werden Sie mit einer Warnmeldung seitens Synology begrüßt.
				</p>
				<p class="shadow-none p-1 mb-0 bg-light rounded font-monospace">
					Synology strongly advises you not to run commands as the root user, who has the highest privileges on the system. Doing so may cause major damages to the system. Please note that if you choose to proceed, all consequences are at your own risk.
				</p>
				<pre class="shadow-none p-1 mb-1 bg-light rounded"><span class="text-success">admin@DiskStation</span>:<span class="text-primary">~</span>$</pre>
			</div>
			<h4 class="mt-4">Wechsel zum Root-Konto</h4>
			<div class="ps-4">
				<div class="alert alert-danger" role="alert">
					<strong>Wichtiger Hinweis:</strong> Das Root-Konto ist nur für besondere sowie systemnahe Verwaltungsaufgaben und nicht für alltägliche Aufgaben des Systems gedacht, da es mit weitreichendsten Zugriffsrechten ausgestattet ist. Daher soll an dieser Stelle noch einmal explizit darauf hingewiesen werden, das Sie alleine die Verantwortung für alle nachfolgenden Schritte tragen.
					<p class="mt-3">
						Jedoch muss bereits im DSM-Aufgabenplaner zur Ausführung eines Basic Backup Datensicherungsauftrages, die ausgelöste- bzw. geplante Aufgabe als root ausgeführt werden. Daher muss die Einrichtung zum Aufbau einer Remote Server Verbindung ebenfalls über das Root-Konto erfolgen. Die spätere Verbindung zwischen der lokalen Diskstation und dem gewünschten Remote Server, zur Durchführung einer Datensicherung, kann bzw. sollte jedoch über einen abweichenden Benutzer mit eingeschränkten Benutzerrechten erfolgen.
					</p>
				</div>
				<p>
					Nach der Eingabe von sudo -i und der erneuten Eingabe des Passwortes des zuvor angemeldeten Benutzers <span class="text-danger">admin</span> wechseln Sie zum Root-Konto
				</p>
				<pre class="shadow-none p-1 mb-0 bg-light rounded"><span class="text-success">admin@DiskStation</span>:<span class="text-primary">~</span>$ sudo -i</pre>
				<pre class="shadow-none p-1 mb-0 bg-light rounded">Password:</pre>
				<pre class="shadow-none p-1 mb-0 bg-light rounded"><span class="text-success">root@DiskStation</span>:<span class="text-primary">~</span>#</pre>
			</div>
			<h4 class="mt-4">SSH-Ordnerstruktur erstellen</h4>
			<div class="ps-4">
				<p>
					Als erstes wird nun im Benutzer-Home-Ordner von <span class="text-danger">root</span> ein neuer, versteckter Ordner angelegt.
				</p>
				<div class="alert alert-danger" role="alert">
					<strong>Hinweis:</strong> Im allgemeinen liegt der Benutzer-Home-Ordner des Systembenutzers root unter <strong>/root</strong>, wohingegen alle anderen Benutzer im Zusammenhang mit einer Synology DiskStation unter <strong>/var/services/homes/[BENUTZERNAME]</strong> abgelegt werden. Andere Linux Distributionen verwenden hier in der Regel den Ordner <strong>/home/[BENUTZERNAME]</strong>. Durch die Verwendung von <strong>~/</strong> verweist das System aber immer auf den Benutzer-Home-Ordner <strong>des aktuell angemeldeten SSH-Benutzers.</strong>
				</div>
				<pre class="shadow-none p-2 mb-1 bg-light rounded"><span class="text-success">root@DiskStation</span>:<span class="text-primary">~</span># mkdir -p ~/.ssh</pre>
				<ul>
					<li>-p steht für „parents“. Hierbei werden übergeordnete Ordner bzw. Ordnerstrukturen gleich mit angelegt.</li>
					<li>(~/ steht für das Benutzerverzeichnis des aktuell angemeldeten Benutzerkontos, in diesem Fall /<span class="text-danger">root</span>)</li>
				</ul>
			</div>
			<h4 class="mt-4">RSA-Key erzeugen</h4>
			<div class="ps-4">
				<p>
					Als nächstes wird der eigentliche RSA-Key erzeugt, was je nach verwendeten System ein wenig Zeit in Anspruch nehmen kann. Der Befehl dazu lautet...
				</p>
				<p>
					<strong>Syntax</strong>
						<pre class="shadow-none p-2 mb-1 bg-light rounded">ssh-keygen -b 4096 -t rsa -f ~/.ssh/[<span class="text-danger">FILENAME</span>]</pre>
						<ul>
							<li>-b steht für Bit, also die Bitlänge des Verschlüsselungsschlüssels, hier 4096 Bit</li>
							<li>-t steht für type, also den Verschlüsselungstyp, hier rsa für RSA Protokoll 2</li>
							<li>-f steht für den zu verwendenden Dateinamen und [<span class="text-danger">FILENAME</span>] beschreibt den (eindeutigen) Namen der Datei.</li>
						</ul>
				</p>
				<p class="mt-3">
					<strong>Praxis Beispiel</strong><br />
					<pre class="shadow-none p-2 mb-1 bg-light rounded"><span class="text-success">root@DiskStation</span>:<span class="text-primary">~</span># ssh-keygen -b 4096 -t rsa -f ~/.ssh/<span class="text-danger">id_rsa</span></pre>
					Als Dateiname verwenden wir in diesem Beispiel die Standardbezeichnung <span class="text-danger">id_rsa</span> (ohne Dateinamenerweiterung bzw. Dateisuffix). Dieser Standard Dateiname wird dabei vom System ohne weitere Angaben erkannt und verarbeitet. Möchten Sie sich darüber hinaus mit weiteren Remote Servern verbinden, würde es sich zur Erhöhung der Sicherheit und zur besseren Identifizierung der verschiedenen Server anbieten, weitere RSA-Key Paare mit individuellen Dateinamen nach der oben aufgeführten Syntax zu erstellen. Sollten Sie einen abweichenden Dateinamen als den Standard Dateinamen id_rsa verwenden wollen, muss dieser Dateiname dem System explizit übergeben werden, um den passenden Bezug herstellen zu können. Basic Backup bietet hierfür ein entsprechendes Eingabefeld in den Auftragseinstellungen an.
				</p>
				<p>
					Gleich nach der Ausführung des Befehls wird man nach einer Passphrase, also einem Passwort gefragt...
				</p>
				<pre class="shadow-none p-1 mb-0 bg-light rounded">Generating public/private rsa key pair.</pre>
				<pre class="shadow-none p-1 mb-0 bg-light rounded">Enter passphrase (empty for no passphrase):</pre>
				<pre class="shadow-none p-1 mb-1 bg-light rounded">Enter same passphrase again:</pre>
				<p class="mt-3">
					... tragen Sie hier bitte nichts ein, sondern bestätigen Sie die beiden Abfragen einfach mit der Return Taste. Daraufhin erscheint eine ähnliche Ausgabe wie diese hier...
				</p>
				<pre class="shadow-none p-1 mb-0 bg-light rounded">Your identification has been saved in /<span class="text-danger">root</span>/.ssh/<span class="text-danger">id_rsa</span></pre>
				<pre class="shadow-none p-1 mb-0 bg-light rounded">Your public key has been saved in /<span class="text-danger">root</span>/.ssh/<span class="text-danger">id_rsa</span>.pub</pre>
				<pre class="shadow-none p-1 mb-0 bg-light rounded">The key fingerprint is:</pre>
				<pre class="shadow-none p-1 mb-0 bg-light rounded">SHA256:lZ2wkhbkjvUf05rJ7lx1xgigiuvuHhiihbwE root@DiskStation</pre>
				<pre class="shadow-none p-1 mb-0 bg-light rounded">The key`s randomart image is:</pre>
				<pre class="shadow-none p-1 mb-0 bg-light rounded">+---[RSA 4096]----+</pre>
				<pre class="shadow-none p-1 mb-0 bg-light rounded">|   ...Eo*.+  o.o.|</pre>
				<pre class="shadow-none p-1 mb-0 bg-light rounded">|    +o . * @.oo.o|</pre>
				<pre class="shadow-none p-1 mb-0 bg-light rounded">|   +  .   X B .o*|</pre>
				<pre class="shadow-none p-1 mb-0 bg-light rounded">|  .    + + . o B=|</pre>
				<pre class="shadow-none p-1 mb-0 bg-light rounded">|    . = S     = *|</pre>
				<pre class="shadow-none p-1 mb-0 bg-light rounded">|     o o     . .o|</pre>
				<pre class="shadow-none p-1 mb-0 bg-light rounded">|              . .|</pre>
				<pre class="shadow-none p-1 mb-0 bg-light rounded">|             o . |</pre>
				<pre class="shadow-none p-1 mb-0 bg-light rounded">|              o  |</pre>
				<pre class="shadow-none p-1 mb-0 bg-light rounded">+----[SHA256]-----+</pre>
				<pre class="shadow-none p-1 mb-3 bg-light rounded"><span class="text-success">root@DiskStation</span>:<span class="text-primary">~</span>#</pre>
				<p>
					Nach der Ausführung wurden nachfolgende Dateien erzeugt, wobei die Datei <span class="text-danger">id_rsa</span> den privaten Schlüssel bereithält, die Datei <span class="text-danger">id_rsa</span>.pub dagegen den öffentlichen Schlüssel.
				</p>

				<pre class="shadow-none p-1 mb-0 bg-light rounded">/<span class="text-danger">root</span>/.ssh/<span class="text-danger">id_rsa</span></pre>
				<pre class="shadow-none p-1 mb-0 bg-light rounded">/<span class="text-danger">root</span>/.ssh/<span class="text-danger">id_rsa</span>.pub</pre>
			</div>
			<h4 class="mt-4">authorized_keys anlegen</h4>
			<div class="ps-4">
				<p>
					In der Datei "authorized_keys" werden im späteren Verlauf neben dem eigenen-, auch alle öffentlichen Schlüssel bekannter Remote Server eingetragen, um so einen passwortlosen Verbindungsaufbau zu ermöglichen. Da die Datei noch nicht existiert, wird diese nun durch Eingabe von...
				</p>
				<pre class="shadow-none p-2 mb-1 bg-light rounded"><span class="text-success">root@DiskStation</span>:<span class="text-primary">~</span># touch ~/.ssh/authorized_keys</pre>
				<p class="mt-3">
					...erstellt und im Anschluss gleich der eigene, öffentliche Schlüssel darin eintragen.
				</p>
				<p>
					<strong>Syntax</strong>
						<pre class="shadow-none p-2 mb-1 bg-light rounded">cat ~/.ssh/[<span class="text-danger">FILENAME</span>].pub >> ~/.ssh/authorized_keys</pre>
						<ul>
							<li>Anstelle von [<span class="text-danger">FILENAME</span>] hier bitte wieder den Dateinamen eintragen, den Sie weiter oben ausgewählt haben.</li>
							<li>In diesem Beispiel lautet der Dateiname <span class="text-danger">id_rsa</span>.pub</li>
						</ul>
				</p>
				<pre class="shadow-none p-2 mb-1 bg-light rounded"><span class="text-success">root@DiskStation</span>:<span class="text-primary">~</span># cat ~/.ssh/<span class="text-danger">id_rsa</span>.pub >> ~/.ssh/authorized_keys</pre>
			</div>
			<h4 class="mt-4">Ordner- und Dateirechte setzen</h4>
			<div class="ps-4">
				<p>
					Zugriffsrechte für den erstellten Ordner ~/.ssh, sowie den beinhaltenden Dateien anpassen.
				</p>
				<pre class="shadow-none p-1 mb-0 bg-light rounded"><span class="text-success">root@DiskStation</span>:<span class="text-primary">~</span># chmod 0700 ~/.ssh</pre>
				<pre class="shadow-none p-1 mb-0 bg-light rounded"><span class="text-success">root@DiskStation</span>:<span class="text-primary">~</span># chmod 0600 ~/.ssh/<span class="text-danger">id_rsa</span>*</pre>
				<pre class="shadow-none p-1 mb-0 bg-light rounded"><span class="text-success">root@DiskStation</span>:<span class="text-primary">~</span># chmod 0600 ~/.ssh/authorized_keys</pre>
			</div>
			<p class="mt-3">
				Die SSH-Ordnerstruktur für diese DiskStation ist nun eingerichtet.
			</p>
			<p class="text-end"><br />
				<button type="button" class="btn btn-secondary btn-sm" data-bs-toggle="modal" data-bs-target="#help-ssh-remote">Weiter mit '${txt_link_help_ssh_remote}'</button>
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
				Secure Shell, or SSH for short, is a network protocol for establishing encrypted connections between devices in the local network or via the Internet. Login is usually done by entering a user name and the corresponding password. In addition to establishing a connection directly via the terminal (also called console or shell) of any Linux distribution, the Windows command prompt or the Windows PowerShell, graphical user interfaces such as PuTTY are also used.
			</p>
			<p>
				Using RSA key authentication, there is no need to enter a user name and password when establishing an SSH connection to a remote server. This enables an automated connection setup without the presence of a user. Authentication is carried out using a previously generated passwordless private key and a resulting public key.
			</p>
			<p>
				The automated connection setup enables Basic Backup to execute backup tasks from or to rsync-compatible remote servers. The type of backup direction determines the connection type. Thus, a distinction is made between two possible connection types.
			</p>
			<div class="ps-4">
				<ul>
					<li class="mb-3">
						<strong>Push backup, also called to SSH.</strong><br />
						Here, the data to be backed up is transferred from DiskStation towards the rsync-compatible remote server and backed up.
					</li>
					<li>
						<strong>Pull backup, also called from SSH.</strong><br />
						Here, the data to be backed up is fetched from an rsync-compatible remote server, through DiskStation and backed up locally.
					</li>
				</ul>
			</div>
			<p>
				The following now describes the way to build an SSH folder structure and generate a private and public RSA key.
			</p>
			<h4 class="mt-4">Logging in to the local DiskStation</h4>
			<div class="ps-4">
				<div class="alert alert-danger" role="alert">
					<strong> Note 1: </strong> <br /> Please activate the <strong> SSH terminal service </strong> in advance. To activate the SSH terminal service, go to <strong> DSM main menu> Control panel> Terminal & SNMP </strong> and switch to the <strong>> Terminal </strong> tab. Activate the checkbox <strong> Activate SSH service </strong>. <br /> <br /> <strong> Note 2: </strong> <br /> Please activate the <strong> rsync- Service </strong>. To <strong> activate the rsync service </strong> go to <strong> DSM main menu> Control Panel> File Services </strong> and switch to the <strong>> rsync </strong> tab. Activate the checkbox <strong> Activate rsync service </strong>. Port 22 is used by default as the SSH encryption port, which you can adjust if necessary. <br /> <br /> <strong> Note 3: </strong> <br /> Please also activate the <strong> in advance User home service </strong>, since the required SSH connection data is stored in the corresponding user home folder of the logged in SSH user. To activate the user home service, go to <strong> DSM main menu> Control Panel> Users and Groups </strong> and switch to the <strong>> Advanced </strong> tab. Activate the checkbox <strong> Activate user home service </strong> under the menu item <strong> User base </strong>.
				</div>
				<p class="mt-3">
					Using your credentials via e.g. PuTTY or directly via a terminal, establish an SSH connection to the terminal of your local disk station. Make sure that only users from the administrators group are allowed to get access via SSH. In the following we use exemplarily these access data)<br />
					<pre class="shadow-none p-1 mb-0 bg-light rounded">Username   : <span class="text-danger">admin</span></pre>
					<pre class="shadow-none p-1 mb-0 bg-light rounded">Hostname   : <span class="text-danger">DiskStation</span></pre>
					<pre class="shadow-none p-1 mb-0 bg-light rounded">IP address : <span class="text-danger">192.168.2.10</span></pre>
					<pre class="shadow-none p-1 mb-0 bg-light rounded">Port       : <span class="text-danger">22</span></pre>
				</p>
				<p class="mt-3">
					In the following example, we dial in via the terminal of any Linux distribution. The command for dialing in is...
				</p>
				<p class="mt-3">
					<strong>Syntax</strong>
					<pre class="shadow-none p-2 mb-1 bg-light rounded">ssh -p [<span class="text-danger">PORT</span>] [<span class="text-danger">USERNAME</span>]@[<span class="text-danger">SERVER-ADDRESS</span>]</pre>
				</p>
				<p class="mt-3">
					<strong>Practice example</strong><br />
					<pre class="shadow-none p-1 mb-0 bg-light rounded"><span class="text-success">tux@LinuxDistro</span>:<span class="text-primary">~</span># ssh -p <span class="text-danger">22</span> <span class="text-danger">admin</span>@<span class="text-danger">192.168.2.10</span></pre>
				</p>
				<p class="mt-3">
					After the connection to your local DiskStation is established, you will be asked to enter your credentials.
				</p>
				<pre class="shadow-none p-1 mb-0 bg-light rounded">login as: <span class="text-danger">admin</span></pre>
				<pre class="shadow-none p-1 mb-0 bg-light rounded">admin@192.168.2.10`s password:</pre>
				<p class="mt-3">
					After successful login, you will be greeted with a warning message from Synology.
				</p>
				<p class="shadow-none p-1 mb-0 bg-light rounded font-monospace">
					Synology strongly advises you not to run commands as the root user, who has the highest privileges on the system. Doing so may cause major damages to the system. Please note that if you choose to proceed, all consequences are at your own risk.
				</p>
				<pre class="shadow-none p-1 mb-1 bg-light rounded"><span class="text-success">admin@DiskStation</span>:<span class="text-primary">~</span>$</pre>
			</div>
			<h4 class="mt-4">Switch to root account</h4>
			<div class="ps-4">
				<div class="alert alert-danger" role="alert">
					<strong>Important note:</strong> The root account is intended only for special as well as system-related administrative tasks and not for everyday tasks of the system, as it is equipped with the most extensive access rights. Therefore, it should be explicitly pointed out at this point that you alone are responsible for all subsequent steps.
					<p class="mt-3">
						However, already in the DSM task scheduler for the execution of a Basic Backup data backup job, the triggered or scheduled task must be executed as root. Therefore, the setup for establishing a remote server connection must also be done using the root account. However, the subsequent connection between the local disk station and the desired remote server, to perform a backup, can or should be done via a different user with limited user rights.
					</p>
				</div>
				<p>
					After entering sudo -i and re-entering the password of the previously logged in user <span class="text-danger">admin</span>, switch to the root account
				</p>
				<pre class="shadow-none p-1 mb-0 bg-light rounded"><span class="text-success">admin@DiskStation</span>:<span class="text-primary">~</span>$ sudo -i</pre>
				<pre class="shadow-none p-1 mb-0 bg-light rounded">Password:</pre>
				<pre class="shadow-none p-1 mb-0 bg-light rounded"><span class="text-success">root@DiskStation</span>:<span class="text-primary">~</span>#</pre>
			</div>
			<h4 class="mt-4">Create SSH folder structure</h4>
			<div class="ps-4">
				<p>
					First, a new hidden folder is now created in the user home folder of <span class="text-danger">root</span>
				</p>
				<div class="alert alert-danger" role="alert">
					<strong>Note:</strong> Generally, the user home folder of the system user root is located under <strong>/root</strong>, whereas all other users in the context of a Synology DiskStation are stored under <strong>/var/services/homes/[USERNAME]</strong>. Other Linux distributions usually use the folder <strong>/home/[USERNAME]</strong> here. By using <strong>~/</strong>, however, the system always points to the user home folder <strong>of the SSH user currently logged in.</strong>
				</div>
				<pre class="shadow-none p-2 mb-1 bg-light rounded"><span class="text-success">root@DiskStation</span>:<span class="text-primary">~</span># mkdir -p ~/.ssh</pre>
				<ul>
					<li>-p stands for "parents". Here, parent folders or folder structures are created at the same time.</li>
					<li>(~/ stands for the user directory of the currently logged in user account, in this case /<span class="text-danger">root</span>)</li>
				</ul>
			</div>
			<h4 class="mt-4">Generate RSA key</h4>
			<div class="ps-4">
				<p>
					Next, the actual RSA key is generated, which can take a little time depending on the system used. The command for this is...
				</p>
				<p>
					<strong>Syntax</strong>
						<pre class="shadow-none p-2 mb-1 bg-light rounded">ssh-keygen -b 4096 -t rsa -f ~/.ssh/[<span class="text-danger">FILENAME</span>]</pre>
						<ul>
							<li>-b stands for bit, i.e. the bit length of the encryption key, here 4096 bits</li>
							<li>-t stands for type, i.e. the encryption type, here rsa for RSA protocol 2</li>
							<li>-f stands for the file name to be used and [<span class="text-danger">FILENAME</span>] describes the (unique) name of the file.</li>
						</ul>
				</p>
				<p class="mt-3">
					<strong>Practice example</strong><br />
					<pre class="shadow-none p-2 mb-1 bg-light rounded"><span class="text-success">root@DiskStation</span>:<span class="text-primary">~</span># ssh-keygen -b 4096 -t rsa -f ~/.ssh/<span class="text-danger">id_rsa</span></pre>
					In this example, we use the standard name <span class="text-danger">id_rsa</span> (without file name extension or file suffix) as the file name. This standard file name is recognised and processed by the system without any further information. If you would like to connect to additional remote servers, it would make sense to create additional RSA key pairs with individual file names according to the syntax listed above to increase security and better identify the various servers. If you want to use a file name other than the standard file name id_rsa, this file name must be explicitly passed to the system in order to be able to establish the appropriate reference. Basic Backup offers a corresponding input field for this in the job settings.
				</p>
				<p>
					Immediately after executing the command you will be asked for a passphrase, i.e. a password...
				</p>
				<pre class="shadow-none p-1 mb-0 bg-light rounded">Generating public/private rsa key pair.</pre>
				<pre class="shadow-none p-1 mb-0 bg-light rounded">Enter passphrase (empty for no passphrase):</pre>
				<pre class="shadow-none p-1 mb-1 bg-light rounded">Enter same passphrase again:</pre>
				<p class="mt-3">
					... please do not enter anything here, but simply confirm the two queries with the Return key. Thereupon a similar output like this one appears...
				</p>
				<pre class="shadow-none p-1 mb-0 bg-light rounded">Your identification has been saved in /<span class="text-danger">root</span>/.ssh/<span class="text-danger">id_rsa</span></pre>
				<pre class="shadow-none p-1 mb-0 bg-light rounded">Your public key has been saved in /<span class="text-danger">root</span>/.ssh/<span class="text-danger">id_rsa</span>.pub</pre>
				<pre class="shadow-none p-1 mb-0 bg-light rounded">The key fingerprint is:</pre>
				<pre class="shadow-none p-1 mb-0 bg-light rounded">SHA256:lZ2wkhbkjvUf05rJ7lx1xgigiuvuHhiihbwE root@DiskStation</pre>
				<pre class="shadow-none p-1 mb-0 bg-light rounded">The key`s randomart image is:</pre>
				<pre class="shadow-none p-1 mb-0 bg-light rounded">+---[RSA 4096]----+</pre>
				<pre class="shadow-none p-1 mb-0 bg-light rounded">|   ...Eo*.+  o.o.|</pre>
				<pre class="shadow-none p-1 mb-0 bg-light rounded">|    +o . * @.oo.o|</pre>
				<pre class="shadow-none p-1 mb-0 bg-light rounded">|   +  .   X B .o*|</pre>
				<pre class="shadow-none p-1 mb-0 bg-light rounded">|  .    + + . o B=|</pre>
				<pre class="shadow-none p-1 mb-0 bg-light rounded">|    . = S     = *|</pre>
				<pre class="shadow-none p-1 mb-0 bg-light rounded">|     o o     . .o|</pre>
				<pre class="shadow-none p-1 mb-0 bg-light rounded">|              . .|</pre>
				<pre class="shadow-none p-1 mb-0 bg-light rounded">|             o . |</pre>
				<pre class="shadow-none p-1 mb-0 bg-light rounded">|              o  |</pre>
				<pre class="shadow-none p-1 mb-0 bg-light rounded">+----[SHA256]-----+</pre>
				<pre class="shadow-none p-1 mb-3 bg-light rounded"><span class="text-success">root@DiskStation</span>:<span class="text-primary">~</span>#</pre>
				<p>
					After execution, the following files were created, where the file <span class="text-danger">id_rsa</span> holds the private key, whereas the file <span class="text-danger">id_rsa</span>.pub holds the public key.
				</p>

				<pre class="shadow-none p-1 mb-0 bg-light rounded">/<span class="text-danger">root</span>/.ssh/<span class="text-danger">id_rsa</span></pre>
				<pre class="shadow-none p-1 mb-0 bg-light rounded">/<span class="text-danger">root</span>/.ssh/<span class="text-danger">id_rsa</span>.pub</pre>
			</div>
			<h4 class="mt-4">Create authorized_keys</h4>
			<div class="ps-4">
				<p>
					In the "authorized_keys" file, all public keys of known remote servers are entered in addition to the user`s own key, in order to enable a password-free connection. Since the file does not yet exist, it is now created by entering...
				</p>
				<pre class="shadow-none p-2 mb-1 bg-light rounded"><span class="text-success">root@DiskStation</span>:<span class="text-primary">~</span># touch ~/.ssh/authorized_keys</pre>
				<p class="mt-3">
					...and then immediately enter your own public key in it.
				</p>
				<p>
					<strong>Syntax</strong>
						<pre class="shadow-none p-2 mb-1 bg-light rounded">cat ~/.ssh/[<span class="text-danger">FILENAME</span>].pub >> ~/.ssh/authorized_keys</pre>
						<ul>
							<li>Instead of [<span class="text-danger">FILENAME</span>] please enter here again the filename you have selected above.</li>
							<li>In this example the filename is. <span class="text-danger">id_rsa</span>.pub</li>
						</ul>
				</p>
				<pre class="shadow-none p-2 mb-1 bg-light rounded"><span class="text-success">root@DiskStation</span>:<span class="text-primary">~</span># cat ~/.ssh/<span class="text-danger">id_rsa</span>.pub >> ~/.ssh/authorized_keys</pre>
			</div>
			<h4 class="mt-4">Set folder and file permissions</h4>
			<div class="ps-4">
				<p>
					Adjust access rights for the created ~/.ssh folder, as well as the containing files.
				</p>
				<pre class="shadow-none p-1 mb-0 bg-light rounded"><span class="text-success">root@DiskStation</span>:<span class="text-primary">~</span># chmod 0700 ~/.ssh</pre>
				<pre class="shadow-none p-1 mb-0 bg-light rounded"><span class="text-success">root@DiskStation</span>:<span class="text-primary">~</span># chmod 0600 ~/.ssh/<span class="text-danger">id_rsa</span>*</pre>
				<pre class="shadow-none p-1 mb-0 bg-light rounded"><span class="text-success">root@DiskStation</span>:<span class="text-primary">~</span># chmod 0600 ~/.ssh/authorized_keys</pre>
			</div>
			<p class="mt-3">
				The SSH folder structure for this DiskStation is now set up.
			</p>
			<p class="text-end"><br />
				<button type="button" class="btn btn-secondary btn-sm" data-bs-toggle="modal" data-bs-target="#help-ssh-remote">Next with '${txt_link_help_ssh_remote}'</button>
				<button type="button" class="btn btn-secondary btn-sm" data-bs-dismiss="modal">'${txt_button_Close}'</button>
			</p>
		</div>
	</div>'
fi
