#!/bin/bash
# Filename: versioning.sh - coded in utf-8

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
				Im Gegensatz zu einer synchronisierten Datensicherung werden bei einer versionierten Datensicherung alle, seit der letzten Datensicherung entstandenen Änderungen der Quelle, in einen separaten Ordner, benannt nach Datum und Uhrzeit der aktuellen Datensicherung, im Ziel abgelegt. Zusätzlich zu allen Änderungen sollen aber auch alle unveränderten Daten in den grade genannten Ordner mit einfließen, um im Bedarfsfall auch hier ein einfaches wiederherstellen des kompletten Datensatzes, oder Auszügen daraus, zum Zeitpunkt der Datensicherung zu ermöglichen. Das würde aber bedeuten, das für jede Datensicherung, neben dem ersten, initialen Vollbackup, stets ein weiteres Vollbackup pro Sicherung erstellt werden müsste. Um das zu vermeiden, greift Basic Backup hier auf die Verwendung von Hardlinks zurück.
			</p>
			<h4>Was ist ein Hardlink</h4>
			<div class="ps-4">
				<p>
					Um zu verstehen, was ein Hardlink ist und wie dieser arbeitet, muss man verstehen wie Unix-Systeme ihre Dateisysteme organisieren. Ohne aber jetzt zu weit auszuholen, beschränken wir uns hier auf folgende Gegebenheiten.
				</p>
				<p>
					Unter Unix-Systemen wie z.B. Linux enthält jede Partition ein Dateisystem. Jedes Dateisystem wiederum enthält eine Art Inhaltsverzeichnis, die sogenannte I-Node-Liste. Innerhalb dieser I-Node-Liste werden wiederum in den sogenannten I-Nodes Informationen wie Metadaten und Speicherorte zu Nutzdaten abgelegt, also wo im Dateisystem (in welchen Blöcken) z.B. eine Datei abgelegt wurde und welche Eigenschaften wie Eigentümer, Gruppenzugehörigkeit, Zugriffsrechte, usw. diese hat.
				</p>
				<p>
					Ein I-Node wird dabei nicht über den Namen einer Datei angesprochen, sondern über eine eindeutige Nummer innerhalb des Dateisystems. Ein Dateiname beinhaltet demnach nur den Verweis auf den entsprechenden I-Node bzw. auf dessen Nummer. Das wiederum hat zur Folge, das unterschiedliche Dateinamen auf ein und den selben I-Node verweisen können, also den selben Inhalt ausgeben, dafür aber keinen zusätzlichen Speicherplatz im Dateisystem verbrauchen. Oder anders ausgedrückt, ein I-Node Eintrag bleib solange in der I-Node-Liste enthalten, solang ein oder mehrere Dateinamen auf diesen verweisen. Wird ein Dateiname gelöscht, wird nur der Verweis zum I-Node gelöscht, nicht aber der I-Node selber, jedenfalls solange nicht, wie noch weitere Dateinamen auf diesen I-Node verweisen. Erst wenn kein Dateiname mehr auf den I-Node verweist, wird dieser aus dem Dateisystem entfernt, also aus der I-Node-Liste gelöscht und der Speicherplatz wird wieder freigegeben. Was bedeutet das jetzt für die Versionierung von Basic Backup?
				</p>
			</div>
			<h4>Aufbau und Funktion der Versionierung, basierend auf Hardlinks</h4>
			<div class="ps-4">
				<p>Die Ordnerstruktur für die Aufnahme von Versionen ist unter Basic Backup folgendermaßen aufgebaut.</p>
				<p>
					<pre class="shadow-none p-1 mb-0 bg-light rounded">/Hauptversion</pre>
					<pre class="shadow-none p-1 mb-0 bg-light rounded">/Versionsverlauf</pre>
					<pre class="shadow-none p-1 mb-0 bg-light rounded">&nbsp;&nbsp;&nbsp;&nbsp;/Jahr-Monat-Tag_Stunde[h]-Minute[m]-Sekunde[s]</pre>
					<pre class="shadow-none p-1 mb-0 bg-light rounded">&nbsp;&nbsp;&nbsp;&nbsp;/Jahr-Monat-Tag_Stunde[h]-Minute[m]-Sekunde[s]</pre>
					<pre class="shadow-none p-1 mb-0 bg-light rounded">&nbsp;&nbsp;&nbsp;&nbsp;/...</pre>
				</p>
				<p>
					Während des ersten, initialen Vollbackups werden sämtliche Daten aus den Quellordnern, im Ordner /Hauptversion gespeichert. Nach Beendigung dieses Vorganges wird mittels Hardlinks ein Abbild des Ordners /Hauptversion in den Ordner /Versionsverlauf gelegt, benannt nach Datum und Uhrzeit der aktuellen Datensicherung.
				</p>
				<p>
					Hier erkennt man bereits einen der Vorteile bei der Verwendung von Hardlinks. Für alle übertragenen Daten wurden entsprechende I-Nodes generiert und der I-Node-Liste zugeführt. Somit weiß das Dateisystem anhand der Meta- und Nutzdaten stets, wo sich eine Datei innerhalb einer Partition befindet. Durch das anschließende hart verlinken wird einfach je ein weiterer Eintrag in der I-Note Liste des grade gesicherten Datensatzes erzeugt, welcher auf die Inhalte des Ordners /Versionsverlauf/Jahr-Monat-Tag_Stunde[h]-Minute[m]-Sekunde[s] verweist. Damit zeigt ein ensprechender I-Note nunmehr auf mindestens zwei Dateinamen, welche sich jedoch in unterschiedlichen Ordnern bzw. an unterschiedlichen Orten befinden.
				</p>
				<p>
					Bei allen nachfolgenden Datensicherungen werden nun die Quelldaten mit den Daten des Ordners /Hauptversion verglichen, welcher den aktuellen Stand der letzten Datensicherung enthält. Zwischenzeitlich neu erstellte oder geänderte Daten werden dabei dem Datensatz hinzugefügt, zwischenzeitlich gelöschte Daten werden aus dem Datensatz entfernt. Nach Beendigung dieses Vorganges wird erneut mittels Hardlinks ein Abbild des Ordners /Hauptversion in den Ordner /Versionsverlauf gelegt, wieder benannt nach Datum und Uhrzeit der aktuellen Datensicherung. Diese Daten erhalten wiederum einen I-Node Eintrag, sowohl für bereits bestehende bzw. geänderte Daten, als auch für neu hinzugefügte Daten. Neu hinzugefügte Daten verbrauchen dabei natürlich Speicherplatz, da diese dem Dateisystem bisher nicht bekannt waren, oder nicht mehr der Originaldatei (dem original I-Node) entsprechen. Zwischenzeitlich gelöschten Daten tauchen somit in diesem Datensatz nicht mehr auf. Man erhält also einen recht schlanken Datensatz und verbraucht nur einen Bruchteil dessen an Speicherplatz als das bei einem weiteren Vollbackup der Fall wäre.
				</p>
				<div class="alert alert-danger" role="alert">
					<p>
						Jeder neu erstellte I-Node Eintrag, welcher entweder durch neu hinzukommende Dateien oder aber durch zwischenzeitlich veränderte Dateien initiiert wird, belegt natürlich dem realen Speicherplatz der jeweils übertragenen Datei. Bei zwischenzeitlich geänderten Dateien wird hierbei aber nicht nur dessen Delta, also nur die geänderten Bereiche einer Datei übertragen, wie dies rsync beim Übertragen von Daten über SSH erledigt, sondern die reale Dateigröße übertragen. Existieren also 5 verschiedenen Versionen einer Datei im Ziel, wird auch 5 mal der volle Speicherplatz für diese Datei belegt, da für jede Dateiversion ein anderer I-Node steht.
					</p>
				</div>
				<p>
				Bei der Verwendung von Hardlinks handelt es sich so gesehen also nur um die Summe einer Sammlung aus ursprünglichen, zwischenzeitlich geänderten und neu hinzugekommenen I-Node Verweisen, welche aber keinen weiteren Speicherplatz im System belegen. Des Weiteren dient der Ordner /Hauptversion dem Abgleich der Daten zwischen Quelle und Ziel während einer Sicherung als auch als Wiederherstellungsordner, welcher den letzten aktuellen Stand der Datensicherung in sich trägt.
				</p>
				<div class="alert alert-danger" role="alert">
					<h4>Bekannte Probleme</h4>
						<p>
							Hardlinks haben leider die negative Eigenschaft, das diese von den meisten Datei-Managern, wie auch dem DSM File-Manager falsch interpretiert werden und das aus folgendem Grund. Jede Datei und somit jeder I-Node Eintrag benötigt und verbraucht Speicherplatz im Dateisystem. Ein Hardlink verbraucht primär aber keinen Speicherplatz, da ein Hardlink nur ein Verweis auf einen bestehenden I-Node Eintrag darstellt. Sekundär trägt aber jeder Hardlink auch die Metadaten eines I-Nodes in sich, welcher u.a. Informationen zur Dateigröße beinhaltet. Und genau diese Dateigrößen-Informationen werden von den meisten Datei-Manager bei jedem Hardlink mitgerechnet, obwohl der zugehörige I-Node-Eintrag nur einmal existiert und somit nur einmal Speicherplatz benötigt. Daher entsteht der Eindruck, das mit jeder versionierten Datensicherung innerhalb Basic Backup immer ein Vollbackup erstellt wird. Dem ist, wie oben ausführlich beschrieben, aber nicht so. Einzig der Linux Terminal bietet eine zuverlässige Aussage über den bereits verbrauchten Speicherplatzes eines Backupsets.
						</p>
				</div>
			</div>
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
				In contrast to a synchronized backup, a versioned backup stores all changes made to the source since the last backup in a separate folder named after the date and time of the current backup. In addition to all changes, however, all unchanged data should also be included in the folder just mentioned, in order to enable a simple restoration of the complete data set, or excerpts from it, at the time of the data backup. This would mean, however, that for each backup, in addition to the first, initial full backup, another full backup would have to be created for each backup. To avoid this, Basic Backup resorts to the use of hard links here.
			</p>
			<h4>What is a hardlink</h4>
			<div class="ps-4">
				<p>
					To understand what a hardlink is and how it works, you need to understand how Unix systems organize their file systems. However, without going too far now, we will limit ourselves here to the following facts.
				</p>
				<p>
					On Unix systems such as Linux, each partition contains a file system. Each file system in turn contains a kind of table of contents, called the I-node list. Within this I-node list, in turn, information such as metadata and locations to user data is stored in the so-called I-nodes, i.e. where in the file system (in which blocks), for example, a file was stored and what properties such as owner, group membership, access rights, etc. it has.
				</p>
				<p>
					An I-Node is not addressed thereby over the name of a file, but over a unique number within the file system. A file name contains therefore only the reference to the appropriate I-Node and/or on its number. This in turn means that different file names can refer to one and the same I-Node, i.e. output the same content, but do not consume any additional storage space in the file system. In other words, an I-Node entry remains in the I-Node list as long as one or more file names refer to it. If a filename is deleted, only the reference to the I-Node is deleted, but not the I-Node itself, at least not as long as there are other filenames referring to this I-Node. Only when no file name refers to the I-Node any more, it is removed from the file system, i.e. deleted from the I-Node list and the storage space is freed again. What does this mean now for the versioning of Basic Backup?
				</p>
			</div>
			<h4>Construction and function of versioning, based on hardlinks</h4>
			<div class="ps-4">
				<p>The folder structure for recording versions is as follows under Basic Backup</p>
				<p>
					<pre class="shadow-none p-1 mb-0 bg-light rounded">/MainVersion</pre>
					<pre class="shadow-none p-1 mb-0 bg-light rounded">/VersionHistory</pre>
					<pre class="shadow-none p-1 mb-0 bg-light rounded">&nbsp;&nbsp;&nbsp;/year-month-day_hour[h]-minute[m]-second[s]</pre>
					<pre class="shadow-none p-1 mb-0 bg-light rounded">&nbsp;&nbsp;&nbsp;/year-month-day_hour[h]-minute[m]-second[s]</pre>
					<pre class="shadow-none p-1 mb-0 bg-light rounded">&nbsp;&nbsp;&nbsp;/...</pre>
				</p>
				<p>
					During the first, initial full backup, all data from the source folders, is stored in the /main version folder. After this process is complete, hardlinks are used to place an image of the /main version folder into the /version history folder, named after the date and time of the current backup.
				</p>
				<p>
					Here you can already see one of the advantages of using hard links. For all transferred data appropriate I-Nodes were generated and supplied to the I-Node list. Thus the file system knows on the basis the Meta and user data always, where a file is within a partition. By the following hard linking simply a further entry in the I-Note list of the just saved data set is generated, which refers to the contents of the folder /version history/year-month-day_hour[h]-minute[m]-second[s]. Thus, a corresponding I-Note now points to at least two file names, which are, however, in different folders or locations.
				</p>
				<p>
					For all subsequent backups, the source data is now compared with the data in the /main version folder, which contains the current status of the last backup. New data created or changed in the meantime will be added to the data set, data deleted in the meantime will be removed from the data set. After this process has been completed, another hard link is used to place an image of the /Main Version folder in the /Version History folder, again named after the date and time of the current backup. This data again receives an I-Node entry, both for already existing or changed data, and for newly added data. Newly added data consumes storage space, of course, since it was not known to the file system before, or no longer corresponds to the original file (the original I-Node). Data that has been deleted in the meantime will therefore no longer appear in this data set. One receives thus a quite slim data set and uses only a fraction of that at storage space than that with a further full backup the case would be.
				</p>
				<div class="alert alert-danger" role="alert">
					<p>
						Each newly created I-Node entry, which is initiated either by newly added files or by files that have been changed in the meantime, naturally occupies the real storage space of the respective transferred file. With files changed in the meantime, however, not only its delta, thus only the changed ranges of a file is transferred, as rsync does when transferring data over SSH, but the real file size is transferred. If there are 5 different versions of a file in the target, the full memory for this file will be used 5 times, because there is a different I-Node for each file version.
					</p>
				</div>
				<p>
				With the use of Hardlinks it concerns in such a way seen thus only the sum of a collection from original, in the meantime changed and again added I-Node references, which occupy however no further storage place in the system. Furthermore, the folder /main version serves the comparison of the data between source and target during a backup as well as a restore folder, which carries the last current state of the backup in itself.
				</p>
				<div class="alert alert-danger" role="alert">
					<h4>Known issues</h4>
						<p>
							Hardlinks unfortunately have the negative property that they are misinterpreted by most file managers, as well as the DSM file manager, and here`s why. Each file and thus each I-Node entry needs and consumes storage space in the file system. A hardlink does not primarily consume memory, because a hardlink is only a reference to an existing I-Node entry. Secondarily, however, each hard link also carries the metadata of an I-Node, which includes information about the file size. And it is precisely this file size information that most file managers include with each hard link, even though the associated I-Node entry exists only once and thus requires storage space only once. Therefore the impression arises that with each versioned backup within Basic Backup always a full backup is created. However, as described in detail above, this is not the case. Only the Linux terminal offers a reliable statement about the already used storage space of a backup set.
						</p>
				</div>
			</div>
			<p class="text-end"><br />
				<button type="button" class="btn btn-secondary btn-sm" data-bs-dismiss="modal">'${txt_button_Close}'</button>
			</p>
		</div>
	</div>'
fi
