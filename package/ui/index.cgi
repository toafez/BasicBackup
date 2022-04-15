#!/bin/bash
# Filename: index.cgi - coded in utf-8
app_version="0.6-300"
job_version="0.6-000"

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

# Debug - Error analysis options
# --------------------------------------------------------------
# Basic Backup mit rechter Maustaste im neuen Fenster öffnen
#
# Optionen ein: index.cgi?page=debug&section=start&expert=on
# Optionen aus: index.cgi?page=debug&section=start&expert=off

# System initiieren
# --------------------------------------------------------------
	PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/syno/bin:/usr/syno/sbin

	app_name="BasicBackup"
	app_title="Basic Backup"
	app_home=$(echo /volume*/@appstore/${app_name}/ui)
	app_link=$(echo /webman/3rdparty/${app_name})
	[ ! -d "${app_home}" ] && exit

	# Zurücksetzten möglicher Zugangsberechtigungen
	unset syno_login rar_data syno_privilege syno_token syno_user user_exist is_admin is_authenticated

	# Version des rsync-Scriptes anpassen (job_version = script_version)
	rsync_script="${app_home}/rsync.sh"
	script_version=$(cat "${rsync_script}" | grep script_version | cut -d '"' -f2)

	if dpkg --compare-versions ${job_version} gt ${script_version}; then
		sed -i 's/script_version.*$/script_version="'${job_version}'"/' ${rsync_script}
	fi

# App Authentifizierung auswerten
# --------------------------------------------------------------
	# Zum auswerten des SynoToken, REQUEST_METHOD auf GET ändern
	[[ "${REQUEST_METHOD}" == "POST" ]] && REQUEST_METHOD="GET" && OLD_REQUEST_METHOD="POST"


	# Auslesen und prüfen der Login Berechtigung  ( login.cgi )
	# ----------------------------------------------------------
		syno_login=$(/usr/syno/synoman/webman/login.cgi)

		# SynoToken ( nur bei eingeschaltetem Schutz gegen Cross-Site Request Forgery Attacken )
		if echo ${syno_login} | grep -q SynoToken ; then
			syno_token=$(echo "${syno_login}" | grep SynoToken | cut -d ":" -f2 | cut -d '"' -f2)
		fi
		if [ -n "${syno_token}" ]; then
			[ -z ${QUERY_STRING} ] && QUERY_STRING="SynoToken=${syno_token}" || QUERY_STRING="${QUERY_STRING}&SynoToken=${syno_token}"
		fi

		# Login Berechtigung ( result=success )
		if echo ${syno_login} | grep -q result ; then
			login_result=$(echo "${syno_login}" | grep result | cut -d ":" -f2 | cut -d '"' -f2)
		fi
		[[ ${login_result} != "success" ]] && { echo 'Access denied'; exit; }

		# Login erfolgreich ( success=true )
		if echo ${syno_login} | grep -q success ; then
			login_success=$(echo "${syno_login}" | grep success | cut -d "," -f3 | grep success | cut -d ":" -f2 | cut -d " " -f2 )
		fi
		[[ ${login_success} != "true" ]] && { echo 'Access denied'; exit; }


	# REQUEST_METHOD wieder zurück auf POST setzen
	[[ "${OLD_REQUEST_METHOD}" == "POST" ]] && REQUEST_METHOD="POST" && unset OLD_REQUEST_METHOD


	# Auslesen von Benutzer/Gruppe aus der authenticate.cgi
	# ----------------------------------------------------------
		syno_user=$(/usr/syno/synoman/webman/authenticate.cgi)

		# Prüfen, ob der Benutzer existiert
		user_exist=$(grep -o "^${syno_user}:" /etc/passwd)
		[ -n "${user_exist}" ] && user_exist="yes" || exit

		# Prüfen, ob der lokale Benutzer der Gruppe "administrators" angehört
		if id -G "${syno_user}" | grep -q 101; then
			is_admin="yes"
		else
			is_admin="no"
		fi


	# Authentifizierung auf Anwendungsebene auswerten
	# ----------------------------------------------------------
		# Zum auswerten der Authentifizierung muss die Datei /usr/syno/bin/synowebapi
		# nach ${app_home}/modules/synowebapi kopiert, sowie die Besitzrechte
		# auf ${app_name}:${app_name} angepasst werden.

		if [ -f "${app_home}/modules/synowebapi" ]; then
			rar_data=$($app_home/modules/synowebapi --exec api=SYNO.Core.Desktop.Initdata method=get version=1 runner="$syno_user" | jq '.data.AppPrivilege')
			syno_privilege=$(echo "${rar_data}" | grep "SYNO.SDS._ThirdParty.App.${app_name}" | cut -d ":" -f2 | cut -d '"' -f2)
			if echo "${syno_privilege}" | grep -q "true"; then
				is_authenticated="yes"
			else
				is_authenticated="no"
			fi
		else
			is_authenticated="no"
			txtActivatePrivileg="<strong>To enable app level authentication do...</strong><br /><strong>root@[local-machine]:~#</strong> cp /usr/syno/bin/synowebapi /var/packages/${app_name}/target/ui/modules<br /><strong>root@[local-machine]:~#</strong> chown ${app_name}.${app_name} /var/packages/${app_name}/target/ui/modules/synowebapi"
		fi


	# Variablen zum Schutz auf "readonly" setzen oder Inhalt leeren
	# ----------------------------------------------------------
		unset syno_login rar_data syno_privilege
		readonly syno_token syno_user user_exist is_admin is_authenticated


# Umgebungsvariablen festlegen
# --------------------------------------------------------------
	# Ordner für temporäre Daten einrichten
	app_temp="${app_home}/temp"
	[ ! -d "${app_temp}" ] && mkdir -p -m 755 "${app_temp}"
	result="${app_temp}/result.txt"

	# POST und GET Requests auswerten und in Dateien zwischenspeichern
	set_keyvalue="/usr/syno/bin/synosetkeyvalue"
	get_keyvalue="/bin/get_key_value"
	get_request="$app_temp/get_request.txt"
	post_request="$app_temp/post_request.txt"

	# Ordner für Benutzerdaten einrichten
	usr_settings="${app_home}/usersettings"
	[ ! -d "${usr_settings}" ] && mkdir -p -m 755 "${usr_settings}"

	# Ordner für Backupaufträge einrichten
	usr_backupjobs="${usr_settings}/backupjobs"
	[ ! -d "${usr_backupjobs}" ] && mkdir -p -m 755 "${usr_backupjobs}"

	# Ordner für Logfiles einrichten
	usr_logfiles="${usr_settings}/logfiles"
	[ ! -d "${usr_logfiles}" ] && mkdir -p -m 755 "${usr_logfiles}"

	# Ordner für Benutzerdefinierte Einstellungen einrichten
	usr_systemconfig="${usr_settings}/system"
	[ ! -d "${usr_systemconfig}" ] && mkdir -p -m 755 "${usr_systemconfig}"

	# Systemprotokoll einrichten
	usr_systemlog="${usr_logfiles}/${app_name}.history"
	if [ ! -f "${usr_systemlog}" ]; then
		touch "${usr_systemlog}"
		chmod 777 "${usr_systemlog}"
		chown "${app_name}":"${app_name}" "${usr_systemlog}"
	fi

	# Konfigurationsdatei für Debug Modus einrichten
	usr_debugfile="${usr_systemconfig}/debug.config"
	if [ ! -f "${usr_debugfile}" ]; then
		touch "${usr_debugfile}"
		chmod 777 "${usr_debugfile}"
		chown "${app_name}":"${app_name}" "${usr_debugfile}"
	fi
	[ -f "${usr_debugfile}" ] && source "${usr_debugfile}"

	# Konfigurationsdatei für USB/SATA-AutoPilot einrichten
	usr_autoconfig="${usr_systemconfig}/autopilot.config"
	if [ ! -f "${usr_autoconfig}" ]; then
		touch "${usr_autoconfig}"
		chmod 777 "${usr_autoconfig}"
		chown "${app_name}":"${app_name}" "${usr_autoconfig}"
	fi
	[ -f "${usr_autoconfig}" ] && source "${usr_autoconfig}"

	# Wenn keine Seite gesetzt, dann Startseite anzeigen
	if [ -z "${get[page]}" ]; then
		"${set_keyvalue}" "${get_request}" "get[page]" "main"
		"${set_keyvalue}" "${get_request}" "get[section]" "start"
		"${set_keyvalue}" "${get_request}" "get[SynoToken]" "$syno_token"
	fi


# Verarbeitung von GET/POST-Request Variablen
# --------------------------------------------------------------
	# urlencode und urldecode Funktion aus der ../modules/parse_url.sh laden
	[ -f "${app_home}/modules/parse_url.sh" ] && source "${app_home}/modules/parse_url.sh" || exit

	[ -z "${POST_STRING}" -a "${REQUEST_METHOD}" = "POST" -a ! -z "${CONTENT_LENGTH}" ] && read -n ${CONTENT_LENGTH} POST_STRING

	# Sicherung des Internal Field Separator (IFS) sowie das separieren der
	# GET/POST key/value Anfragen, durch Lokalisierung des Trennzeichen "&"
	if [ -z "${backupIFS}" ]; then
		backupIFS="${IFS}"
		IFS='=&'
		GET_vars=(${QUERY_STRING})
		POST_vars=(${POST_STRING})
		readonly backupIFS
		IFS="${backupIFS}"
	fi

	# Analysieren eingehende GET-Anfragen und Verarbeitung zu ${get[key]}="$value" Variablen
	declare -A get
	for ((i=0; i<${#GET_vars[@]}; i+=2)); do
		GET_key=get[${GET_vars[i]}]
		GET_value=${GET_vars[i+1]}
		#GET_value=$(urldecode ${GET_vars[i+1]})

		# Zurücksetzen gespeicherter GET/POST-Requests falls main gesetzt
		if [[ "${get[page]}" == "main" ]] && [ -z "${get[section]}" ]; then
			[ -f "${get_request}" ] && rm "${get_request}"
			[ -f "${post_request}" ] && rm "${post_request}"
		fi

		# Speichern von GET-Requests zur späteren Weiterverarbeitung
		"${set_keyvalue}" "${get_request}" "$GET_key" "$GET_value"
	done
		# Hinzufügen des SynoTokens an die GET-Request Verarbeitung
		"${set_keyvalue}" "${get_request}" "get[SynoToken]" "$syno_token"

	# Analysieren eingehende POST-Anfragen und Verarbeitung zu ${var[key]}="$value" Variablen
	declare -A var
	for ((i=0; i<${#POST_vars[@]}; i+=2)); do
		POST_key=var[${POST_vars[i]}]
		#POST_value=${POST_vars[i+1]}
		POST_value=$(urldecode ${POST_vars[i+1]})

		# Speichern von POST-Requests zur späteren Weiterverarbeitung
		"${set_keyvalue}" "${post_request}" "$POST_key" "$POST_value"
	done

	# Einbinden der temporär gespeicherten GET/POST-Requests ( key="value" ) sowie der Benutzereinstellungen
	[ -f "${get_request}" ] && source "${get_request}"
	[ -f "${post_request}" ] && source "${post_request}"
	#[ -f "${user_settings}" ] && source "${user_settings}"

# Layoutausgabe
# --------------------------------------------------------------
if [ $(synogetkeyvalue /etc.defaults/VERSION majorversion) -ge 7 ]; then

	# Spracheinstellungen aus der ../modules/parse_language.sh laden
	# --------------------------------------------------------------
	[ -f "${app_home}/modules/parse_language.sh" ] && source "${app_home}/modules/parse_language.sh" || exit
	language "GUI"

	# Websitefunktionen aus der ../modules/html.function.sh laden
	# --------------------------------------------------------------
	[ -f "${app_home}/template/html_functions.sh" ] && source "${app_home}/template/html_functions.sh" || exit

	echo "Content-type: text/html"
	echo
	echo '
	<!doctype html>
	<html lang="en">
		<head>
			<meta charset="utf-8" />
			<title>'${app_title}'</title>
			<link rel="shortcut icon" href="images/icon_32.png" type="image/x-icon" />
			<meta name="viewport" content="width=device-width, initial-scale=1, shrink-to-fit=no" />

			<!-- Einbinden eigener CSS Formatierungen -->
			<link rel="stylesheet" href="template/css/stylesheet.css" />

			<!-- Einbinden von bootstrap Framework 5.1.3 -->
			<link rel="stylesheet" href="template/bootstrap/css/bootstrap.min.css" />

			<!-- Einbinden von bootstrap Icons 1.8.1 -->
			<link rel="stylesheet" href="template/bootstrap/font/bootstrap-icons.css" />

			<!-- Einbinden von jQuery -->
			<script src="template/jquery/jquery-3.6.0.min.js"></script>

			<!-- Einbinden von JavaScript bzw. jQuery Funktionen im HTML Header  -->
			<script src="template/js/head-functions.js"></script>
		</head>
		<body>'

			if [[ "${is_admin}" == "yes" ]]; then
				echo '
				<header></header>
				<article>
					<!-- container -->
					<div class="container-lg">'

						# Funktion: Hauptnavigation anzeigen
						# --------------------------------------------------------------
						function mainnav()
						{
							echo '
							<nav class="navbar fixed-top navbar-expand-sm navbar-light bg-light">
								<div class="container-fluid">
									<a class="navbar-brand" style="color: #FF8C00;" href="index.cgi?page=main&section=reset">'${app_title}'</a>
									<button class="navbar-toggler" type="button" data-bs-toggle="collapse" data-bs-target="#navbar" aria-controls="navbar" aria-expanded="false" aria-label="Toggle navigation">
										<span class="navbar-toggler-icon"></span>
									</button>
									<div class="collapse navbar-collapse" id="navbarDropdown">
										<ul class="navbar-nav">
											<li class="nav-item">'
												echo -n '<a class="nav-link'; [[ "${get[page]}" == "jobedit" ]] && echo -n ' active" aria-current="page" ' || echo -n '" '
												echo -n 'href="index.cgi?page=jobedit&section=1&edit=false&jobname=">'${txt_link_new_job}'</a>'
												echo '
											</li>
										</ul>
									</div>
									<div class="float-end">
										<ul class="navbar-nav">

											<li class="nav-item dropdown">
												<a class="nav-link dropdown-toggle" href="#" id="navDropdown" role="button" data-bs-toggle="dropdown" aria-expanded="false">
													'${txt_link_settings}'
												</a>
												<ul class="dropdown-menu dropdown-menu-sm-end" aria-labelledby="navDropdown">
													<li><a class="dropdown-item" href="index.cgi?page=autoconfig&section=start">'${txt_link_usbautopilot}'</a></li>
													<li><a class="dropdown-item" href="index.cgi?page=recovery&section=start">'${txt_link_recovery}'</a></li>
												</ul>
											</li>

											<li class="nav-item dropdown">
												<a class="nav-link dropdown-toggle" href="#" id="navDropdown" role="button" data-bs-toggle="dropdown" aria-expanded="false">
													'${txt_link_help}'
												</a>
												<ul class="dropdown-menu dropdown-menu-sm-end" aria-labelledby="navDropdown">
													<li><button type="button" class="dropdown-item" data-bs-toggle="modal" data-bs-target="#help-ssh-local">'${txt_link_help_ssh_local}'</button></li>
													<li><button type="button" class="dropdown-item" data-bs-toggle="modal" data-bs-target="#help-ssh-remote">'${txt_link_help_ssh_remote}'</button></li>
													<li><button type="button" class="dropdown-item" data-bs-toggle="modal" data-bs-target="#help-ssh-rsa">'${txt_link_help_ssh_rsa}'</button></li>
													<li><button type="button" class="dropdown-item" data-bs-toggle="modal" data-bs-target="#help-versioning">'${txt_link_help_version}'</button></li>
												</ul>
											</li>
										</ul>
									</div>
								</div>
							</nav>
							<p>&nbsp;</p>
							<p>&nbsp;</p>'
						}

						# Funktion: Hilfeartikel im Popupfenster anzeigen
						# --------------------------------------------------------------
						function help_modal ()
						{
							echo '
							<!-- Modal -->
							<div class="modal fade" id="help-'${1}'" tabindex="-1" aria-labelledby="help-'${1}'-label" aria-hidden="true">
								<div class="modal-dialog modal-fullscreen">
									<div class="modal-content">
										<div class="modal-header bg-light">
											<h5 class="modal-title" style="color: #FF8C00;" id="help-'${1}'-label"><span class="navbar-brand">'${2}'</span></h5>
											<button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close" title="'${txt_button_Close}'"></button>
										</div>
										<div class="modal-body">'
											[ -f "${app_home}/help/${1}.sh" ] && source "${app_home}/help/${1}.sh" || echo "Page not found"
											echo '
										</div>
									</div>
								</div>
							</div>'
						}

						# Hilfeartikel laden
						# --------------------------------------------------------------
						help_modal "ssh-local" "${txt_link_help_ssh_local}"
						help_modal "ssh-remote" "${txt_link_help_ssh_remote}"
						help_modal "ssh-rsa" "${txt_link_help_ssh_rsa}"
						help_modal "versioning" "${txt_link_help_version}"

						# Hinweis Badges
						# --------------------------------------------------------------
						note="<span class=\"text-info text-uppercase\" title=\"${txt_link_note}\"><i class=\"bi bi-info-circle-fill\"></i></span>"


						# Seiteninhalte laden
						# --------------------------------------------------------------
						if [[ "${is_admin}" == "yes" ]]; then

							# Infotext: Authentifizierung auf Anwendungsebene aktivieren
							[ -n "${txtActivatePrivileg}" ] && echo ''${txtActivatePrivileg}''

							# Dynamische Seitenausgabe
							if [ -f "${get[page]}.sh" ]; then
								. ./"${get[page]}.sh"
							else
								echo 'Page '${get[page]}''${var[page]}'.sh not found!'
							fi

							# Debug - HTTP GET und POST Anfragen
							if [[ "$http_requests" == "on" ]]; then
								echo '
								<div class="row">
									<div class="col">
										<strong>GET requests</strong>
										<pre>'; cat ${get_request}; echo '</pre>
										<strong>POST requests</strong>
										<pre>'; cat ${post_request}; echo '</pre>
									</div>
								</div>'
							fi

							# Debug - Lokale Umgebung
							if [[ "$local_enviroment" == "on" ]]; then
								echo '
								<div class="row">
									<div class="col">
										<strong>Local Enviroment</strong><br />
										syno_token='${syno_token}'<br />
										login_result='${login_result}'<br />
										login_success='${login_success}'<br />
										syno_user='${syno_user}'<br />
										user_exist='${user_exist}'<br />
										is_admin='${is_admin}'<br />
										is_authenticated='${is_authenticated}'<br />
									</div>
								</div>
								<br />'
							fi

							# Debug - Gruppenmitgliedschaften der App
							if [[ "$group_membership" == "on" ]]; then
								echo '
								<div class="row">
									<div class="col">
										<strong>Group membership</strong></br />'
										if cat /etc/group | grep ^${app_name} | grep -q ${app_name} ; then
											echo ''${app_name}'<br />'
										fi
										if cat /etc/group | grep ^system | grep -q ${app_name} ; then
											echo 'system<br />'
										fi
										if cat /etc/group | grep ^administrators | grep -q ${app_name} ; then
											echo 'administrators<br />'
										fi
										if cat /etc/group | grep ^log | grep -q ${app_name} ; then
											echo 'log<br />'
										fi
										echo '
									</div>
								</div>
								<br />'
							fi

							# Debug - Globale Umgebung
							if [[ "$global_enviroment" == "on" ]]; then
								echo '
								<div class="row">
									<div class="col">
										<strong>Global Enviroment</strong>
										<pre>'; (set -o posix ; set | sed '/txt.*/d;'); echo '</pre>
									</div>
								</div>'
							fi
						else
							# Infotext: Zugriff nur für Benutzer aus der Gruppe der Administratoren erlaubt.
							echo '<p>&nbsp;</p><p class="text-center">'${txt_alert_only_admin}'</p>'
						fi
						echo '
					</div>
					<!-- container -->
				</article>

				<!-- Einbinden von bootstrap JavaScript 5.1.3 -->
				<script src="template/bootstrap/js/bootstrap.min.js"></script>

				<!-- Einbinden von JavaScript bzw. jQuery Funktionen im HTML body  -->
				<script src="template/js/body-functions.js"></script>'
			else
				echo '<p>&nbsp;</p><p class="text-center">'${txtAlertOnlyAdmin}'</p>'
			fi
			echo '
		</body>
	</html>'
fi
exit
