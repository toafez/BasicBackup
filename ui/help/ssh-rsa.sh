#!/bin/bash
# Filename: ssh_rsa.sh - coded in utf-8

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

			</p>
			<p>
				Im Folgenden wird nach einem ersten Verbindungstest die SSH-Ordnerstruktur durch den Austausch des öffentlichen sowie des privaten Schlüssels vervollständigt.
			<p>
			<div class="alert alert-danger" role="alert">
				<strong>Hinweis:</strong> Vor einem ersten Verbindungstest sollten Sie sich vergewissern, das auf dem zu verbindenden <strong>Remote Server</strong> im Vorfeld die <strong>SSH Ordnerstruktur</strong> eingerichtet wurde. Sind alle Vorbereitungen getroffen, steht einem ersten Verbindungstest nichts mehr im Wege.
			</div>

			<h4 class="mt-4">Anmeldung auf der lokalen DiskStation</h4>
			<p>
				Beginnen Sie mit der Anmeldung auf der lokalen DiskStation und dem Wechsel zum Root-Konto
			</p>
			<div class="ps-4">
				<pre class="shadow-none p-1 mb-0 bg-light rounded"><span class="text-success">tux@LinuxDistro</span>:<span class="text-primary">~</span># ssh -p <span class="text-danger">22</span> <span class="text-danger">admin</span>@<span class="text-danger">192.168.2.10</span></pre>
				<pre class="shadow-none p-1 mb-0 bg-light rounded">login as: <span class="text-danger">admin</span></pre>
				<pre class="shadow-none p-1 mb-0 bg-light rounded">admin@192.168.2.10`s password:</pre>
				<pre class="shadow-none p-1 mb-0 bg-light rounded"><span class="text-success">admin@DiskStation</span>:<span class="text-primary">~</span>$ sudo -i</pre>
				<pre class="shadow-none p-1 mb-0 bg-light rounded">Password:</pre>
				<pre class="shadow-none p-1 mb-0 bg-light rounded"><span class="text-success">root@DiskStation</span>:<span class="text-primary">~</span>#</pre>
			</div>

			<h4 class="mt-4">Bekanntmachung Ihrer DiskStation mit Ihrem Remote Server</h4>
			<div class="ps-4">
				<div class="alert alert-danger" role="alert">
					<strong>Hinweis:</strong> Der nachfolgend beschriebene sogenannte <strong>Handshake</strong> wird bei jedem Erstkontakt mit einem bis dato unbekannten Remote Server durchgeführt. Hierbei muss der Benutzer den Verbindungsvorgang <strong>aktiv bestätigen</strong> Nach einer positiven Bestätigung wird ein <strong>Fingerprint</strong> des Remote Servers in der lokalen Datei <strong>~/.ssh/known_hosts</strong> Ihrer DiskStation gespeichert. Der Fingerprint basiert dabei auf dem öffentlichen Schlüssel des Remote Servers, der in der Datei <strong>~/.ssh/[FILENAME].pub</strong> enthalten ist. Im Allgemeinen dient der Fingerprint zur einfachen Identifizierung bzw. Verifizierung des Rechners, mit dem Sie sich verbinden wollen.
				</div>
				<p class="mt-3">
					<strong>Praxis Beispiel</strong><br />
					Wir verwenden im folgenden wieder die Zugangsaten, die wir bereits beispielhaft für unseren Remote Server benannt hatten. Nachdem Sie den nachfolgenden Befehl mit der Return Taste bestätigt haben, sollte eine Meldung erscheinen, die Sie am Ende des Textes darum bittet, den Verbindungsaufbau mit <strong>yes</strong> zu bestätigen... <i>Are you sure you want to continue connecting (<strong>yes</strong>/no/[fingerprint])?</i>
				</p>
				<pre class="shadow-none p-1 mb-0 bg-light rounded"><span class="text-success">root@DiskStation</span>:<span class="text-primary">~</span># ssh -p <span class="text-danger">22</span> <span class="text-danger">user</span>@<span class="text-danger">192.168.2.20</span></pre>
				<p class="shadow-none p-1 mb-0 bg-light rounded font-monospace">
					The authenticity of host `192.168.2.20 (192.168.2.20)` can`t be established.<br />
					ECDSA key fingerprint is SHA256:xjFk68MsdfbddddkEF8dKEYdfvbdsvbwe24pQqCno.<br />
					Are you sure you want to continue connecting (<strong>yes</strong>/no/[fingerprint])?<br />
				</p>
				<p class="mt-3">
					Geben Sie über die Tastaur <strong>yes</strong> ein und bestätigen Ihre Eingabe abermals mit der Return Taste. Daraufhin erscheint eine weitere Meldung die Ihnen mitteilt, das der Fingerprint des Remote Servers in der lokalen Datei known_hosts abgelegt wird. Der Vorgang muss durch Eingabe des Passwortes für Ihren Remote Server bestätigt werden...
				</p>
				<p class="shadow-none p-1 mb-0 bg-light rounded font-monospace">
					Warning: Permanently added `192.168.2.20` (ECDSA) to the list of known hosts.
					user@192.168.2.20`s password:
				</p>
				<p class="mt-3">
					Nach Eingabe des Passwortes und betätigen mit der Return Taste sollten Sie nun mit dem Terminal Ihres Remote Servers verbunden sein.
				</p>
				<pre class="shadow-none p-2 mb-1 bg-light rounded"><span class="text-success">user@RemoteServer</span>:<span class="text-primary">~</span>$</pre>
				<p class="mt-3">
					Durch die Eingabe des Befehls <strong>exit</strong>, wird die SSH Verbindung zum Remote Server wieder getrennt und Sie kehren auf das Terminal Ihrer DiskStation zurück.
				</p>
					<pre class="shadow-none p-1 mb-0 bg-light rounded"><span class="text-success">user@RemoteServer</span>:<span class="text-primary">~</span>$ exit</pre>
					<pre class="shadow-none p-1 mb-0 bg-light rounded">logout</pre>
					<pre class="shadow-none p-1 mb-0 bg-light rounded">Connection to 192.168.2.20 closed.</pre>
					<pre class="shadow-none p-1 mb-3 bg-light rounded"><span class="text-success">root@DiskStation</span>:<span class="text-primary">~</span>#</pre>
			</div>
			<h4 class="mt-4">Austausch des öffentlichen RSA-Schlüssels [FILENAME].pub</h4>
			<div class="ps-4">
				<p>
					Damit Sie zukünftig eine passwortlose SSH Verbindung mit Ihrem Remote Server aufbauen können, ist es erforderlich, den <strong>öffentlichen Schlüssel</strong> Ihrer lokalen DiskStation in der Datei <strong>authorized_keys</strong> Ihres Remote Servers zu hinterlegen. Da auf dem Remote Server die SSH Ordnerstruktur bereits vorhanden sein sollte, kann dies mit dem nachfolgenden Befehl einfach durchgeführt werden.
				</p>
				<div class="alert alert-danger" role="alert">
					<strong>Hinweis:</strong> Durch den einseitigen Handshake kann eine Verbindung auch nur von Ihrer DiskStation aus, auf Ihren Remote Server erfolgen. Der umgekehrte Weg, also der Aufbau einer Verbindung, ausgehend von Ihrem Remote Server, wird daher so lange scheitern, bis Sie den Handshake in die Gegenrichtung ausgeführt haben. Diese Verbindungsart wird für die Verwendung von Basic Backup aber nicht benötigt.
				</div>
				<strong>Syntax</strong>
				<pre class="shadow-none p-2 mb-1 bg-light rounded">cat ~/.ssh/[<span class="text-danger">FILENAME</span>].pub | ssh -p [<span class="text-danger">PORT</span>] [<span class="text-danger">USERNAME</span>]@[<span class="text-danger">SERVER-ADDRESS</span>] "cat >> ~/.ssh/authorized_keys"</pre>
				<p class="mt-3">
					<strong>Praxis Beispiel</strong><br />
					Als Beispiel verwenden wir wieder die bereits bekannten Zugangsdaten zu unsrem Remote Server. Nachdem Sie den nachfolgenden Befehl mit der Return Taste bestätigt haben, werden Sie aufgefordert, das Passwort für den Remote Servers anzugeben, damit die Verbindung aufgebaut werden kann. Dies wird das letzte mal sein, das Sie Ihr Passwort eingeben müssen. Bestätigen Sie die Passworteingabe wieder mit der Return Taste. Am Ende der Aktion sollten Sie sich wieder im Terminal Ihrer lokalen DiskStation befinden.
				</p>
				<pre class="shadow-none p-1 mb-0 bg-light rounded"><span class="text-success">root@DiskStation</span>:<span class="text-primary">~</span># cat ~/.ssh/<span class="text-danger">id_rsa</span>.pub | ssh -p <span class="text-danger">22</span> <span class="text-danger">user</span>@<span class="text-danger">192.168.2.20</span> "cat >> ~/.ssh/authorized_keys"</pre>
				<pre class="shadow-none p-1 mb-0 bg-light rounded"> user@192.168.2.20`s password:</pre>
				<pre class="shadow-none p-1 mb-0 bg-light rounded"><span class="text-success">root@DiskStation</span>:<span class="text-primary">~</span>#</pre>
				<p class="mt-3">
					Um zu überprüfen, ob alles geklappt hat, melden Sie sich erneut am Remote Server an. Dieses mal sollte die Verbindung ohne Handshake und Passworteingabe erfolgen.
				</p>
				<pre class="shadow-none p-1 mb-0 bg-light rounded"><span class="text-success">root@DiskStation</span>:<span class="text-primary">~</span># ssh -p <span class="text-danger">22</span> <span class="text-danger">user</span>@<span class="text-danger">192.168.2.20</span></pre>
				<pre class="shadow-none p-1 mb-0 bg-light rounded"><span class="text-success">user@RemoteServer</span>:<span class="text-primary">~</span>$</pre>
				<p class="mt-3">
					Trennen Sie die Verbindung erneut mit einem <strong>exit</strong>
				</p>
				<pre class="shadow-none p-2 mb-1 bg-light rounded"><span class="text-success">user@RemoteServer</span>:<span class="text-primary">~</span>$ exit</pre>
				<p class="mt-3">
					Sie haben nun erfolgreich Ihre lokale DiskStation mit Ihrem Remote Server bekannt gemacht und somit eine grundlegende Voraussetzung geschaffen, ein Pull- oder Push Backup auszuführen.
				</p>
				<p class="text-end"><br />
					<button type="button" class="btn btn-secondary btn-sm" data-bs-dismiss="modal">'${txt_button_Close}'</button>
				</p>
			</div>
		</div>
	</div>'
else
	# Englische Sprachausgabe
	# --------------------------------------------------------------
	echo '
	<div class="row">
		<div class="col">
			<p>

			</p>
			<p>
				In the following, after an initial connection test, the SSH folder structure is completed by exchanging the public key as well as the private key.
			<p>
			<div class="alert alert-danger" role="alert">
				<strong>Note:</strong> Before an initial connection test, make sure that the <strong>SSH folder structure</strong> has been set up in advance on the <strong>Remote Server</strong> to be connected. Once all preparations have been made, there is nothing standing in the way of a first connection test.
			</div>

			<h4 class="mt-4">Logging on to the local DiskStation</h4>
			<p>
				Start by logging in to the local DiskStation and switching to the root account
			</p>
			<div class="ps-4">
				<pre class="shadow-none p-1 mb-0 bg-light rounded"><span class="text-success">tux@LinuxDistro</span>:<span class="text-primary">~</span># ssh -p <span class="text-danger">22</span> <span class="text-danger">admin</span>@<span class="text-danger">192.168.2.10</span></pre>
				<pre class="shadow-none p-1 mb-0 bg-light rounded">login as: <span class="text-danger">admin</span></pre>
				<pre class="shadow-none p-1 mb-0 bg-light rounded">admin@192.168.2.10`s password:</pre>
				<pre class="shadow-none p-1 mb-0 bg-light rounded"><span class="text-success">admin@DiskStation</span>:<span class="text-primary">~</span>$ sudo -i</pre>
				<pre class="shadow-none p-1 mb-0 bg-light rounded">Password:</pre>
				<pre class="shadow-none p-1 mb-0 bg-light rounded"><span class="text-success">root@DiskStation</span>:<span class="text-primary">~</span>#</pre>
			</div>

			<h4 class="mt-4">Announcing your DiskStation to your remote server</h4>
			<div class="ps-4">
				<div class="alert alert-danger" role="alert">
					<strong>Note:</strong> The so-called <strong>handshake</strong> described below is performed each time the user makes initial contact with a previously unknown remote server. Here, the user must <strong>actively confirm</strong> the connection process. After a positive confirmation, a <strong>fingerprint</strong> of the remote server is stored in the local <strong>~/.ssh/known_hosts</strong> file of your DiskStation. The fingerprint is based on the remote server`s public key, which is contained in the <strong>~/.ssh/[FILENAME].pub</strong> file. In general, the fingerprint is used to easily identify or verify the computer you are trying to connect to.
				</div>
				<p class="mt-3">
					<strong>Practical example</strong><br />
					In the following, we again use the access data that we had already named as an example for our remote server. After you have confirmed the following command with the Return key, a message should appear asking you at the end of the text to confirm the connection setup with <strong>yes</strong>.. <i>Are you sure you want to continue connecting (<strong>yes</strong>/no/[fingerprint])?</i>
				</p>
				<pre class="shadow-none p-1 mb-0 bg-light rounded"><span class="text-success">root@DiskStation</span>:<span class="text-primary">~</span># ssh -p <span class="text-danger">22</span> <span class="text-danger">user</span>@<span class="text-danger">192.168.2.20</span></pre>
				<p class="shadow-none p-1 mb-0 bg-light rounded font-monospace">
					The authenticity of host `192.168.2.20 (192.168.2.20)` can`t be established.<br />
					ECDSA key fingerprint is SHA256:xjFk68MsdfbddddkEF8dKEYdfvbdsvbwe24pQqCno.<br />
					Are you sure you want to continue connecting (<strong>yes</strong>/no/[fingerprint])?<br />
				</p>
				<p class="mt-3">
					Enter <strong>yes</strong> via the keyboard and confirm your entry again with the Return key. Another message will appear telling you that the fingerprint of the remote server will be stored in the local file known_hosts. The process must be confirmed by entering the password for your remote server...
				</p>
				<p class="shadow-none p-1 mb-0 bg-light rounded font-monospace">
					Warning: Permanently added `192.168.2.20` (ECDSA) to the list of known hosts.
					user@192.168.2.20`s password:
				</p>
				<p class="mt-3">
					After entering the password and pressing the return key, you should now be connected to the terminal of your remote server.
				</p>
				<pre class="shadow-none p-2 mb-1 bg-light rounded"><span class="text-success">user@RemoteServer</span>:<span class="text-primary">~</span>$</pre>
				<p class="mt-3">
					By entering the command <strong>exit</strong>, the SSH connection to the remote server will be disconnected again and you will return to the terminal of your DiskStation.
				</p>
					<pre class="shadow-none p-1 mb-0 bg-light rounded"><span class="text-success">user@RemoteServer</span>:<span class="text-primary">~</span>$ exit</pre>
					<pre class="shadow-none p-1 mb-0 bg-light rounded">logout</pre>
					<pre class="shadow-none p-1 mb-0 bg-light rounded">Connection to 192.168.2.20 closed.</pre>
					<pre class="shadow-none p-1 mb-3 bg-light rounded"><span class="text-success">root@DiskStation</span>:<span class="text-primary">~</span>#</pre>
			</div>
			<h4 class="mt-4">RSA public key exchange [FILENAME].pub</h4>
			<div class="ps-4">
				<p>
					In order to establish a passwordless SSH connection with your remote server in the future, it is necessary to store the <strong>public key</strong> of your local DiskStation in the <strong>authorized_keys</strong> file of your remote server. Since the SSH folder structure should already exist on the remote server, this can be easily done with the following command.
				</p>
				<div class="alert alert-danger" role="alert">
					<strong>Note:</strong> Due to the one-way handshake, a connection can also only be made from your DiskStation, to your remote server. The reverse way, i.e. establishing a connection starting from your remote server, will therefore fail until you have performed the handshake in the opposite direction. However, this type of connection is not required for using Basic Backup.
				</div>
				<strong>Syntax</strong>
				<pre class="shadow-none p-2 mb-1 bg-light rounded">cat ~/.ssh/[<span class="text-danger">FILENAME</span>].pub | ssh -p [<span class="text-danger">PORT</span>] [<span class="text-danger">USERNAME</span>]@[<span class="text-danger">SERVER-ADDRESS</span>] "cat >> ~/.ssh/authorized_keys"</pre>
				<p class="mt-3">
					<strong>Practice example</strong><br />
					As an example we use again the already known access data to our remote server. After confirming the following command with the return key, you will be asked to enter the password for the remote server so that the connection can be established. This will be the last time you have to enter your password. Confirm the password entry again with the Return key. At the end of the action, you should be back in the terminal of your local DiskStation.
				</p>
				<pre class="shadow-none p-1 mb-0 bg-light rounded"><span class="text-success">root@DiskStation</span>:<span class="text-primary">~</span># cat ~/.ssh/<span class="text-danger">id_rsa</span>.pub | ssh -p <span class="text-danger">22</span> <span class="text-danger">user</span>@<span class="text-danger">192.168.2.20</span> "cat >> ~/.ssh/authorized_keys"</pre>
				<pre class="shadow-none p-1 mb-0 bg-light rounded"> user@192.168.2.20`s password:</pre>
				<pre class="shadow-none p-1 mb-0 bg-light rounded"><span class="text-success">root@DiskStation</span>:<span class="text-primary">~</span>#</pre>
				<p class="mt-3">
					To check if everything worked, log in to the remote server again. This time the connection should be made without handshake and password entry.
				</p>
				<pre class="shadow-none p-1 mb-0 bg-light rounded"><span class="text-success">root@DiskStation</span>:<span class="text-primary">~</span># ssh -p <span class="text-danger">22</span> <span class="text-danger">user</span>@<span class="text-danger">192.168.2.20</span></pre>
				<pre class="shadow-none p-1 mb-0 bg-light rounded"><span class="text-success">user@RemoteServer</span>:<span class="text-primary">~</span>$</pre>
				<p class="mt-3">
					Disconnect again with an <strong>exit</strong>
				</p>
				<pre class="shadow-none p-2 mb-1 bg-light rounded"><span class="text-success">user@RemoteServer</span>:<span class="text-primary">~</span>$ exit</pre>
				<p class="mt-3">
					You have now successfully made your local DiskStation known to your remote server, thus creating a basic requirement to perform a pull or push backup.
				</p>
				<p class="text-end"><br />
					<button type="button" class="btn btn-secondary btn-sm" data-bs-dismiss="modal">'${txt_button_Close}'</button>
				</p>
			</div>
		</div>
	</div>'
fi
