![]( https://raw.githubusercontent.com/Scan-Rec/Scan-Rec/master/Ressourcen/Scan-Reg%20Logo.png)

# Einleitung
Das Projekt Kennzeichen-Scan Enttarnen wurde geschaffen um die geheimgehaltenen Positionen der stationären sog. automatisierten Kennzeichenerfassung (kurz AKE) zu finden. Mehr Informationen zur Kennzeichenerfassung gibt es unter https://www.sueddeutsche.de/auto/automatische-kennzeichenerkennung-wo-ihr-nummernschild-erfasst-wird-1.2188409 
> Petri bemängelt vor allem die Heimlichkeit, mit der in Bayern und Baden-Württemberg die Daten gesammelt werden. Denn Autofahrer würden nicht merken, dass ihre Kennzeichen gescannt werden. "Dadurch könnte der Eindruck entstehen, dass man sich nicht ungestört bewegen kann."

Dieser Heimlichkeit wird hiermit ein Ende bereitet. Wir haben bereits 13 der 15 (https://www.stmi.bayern.de/med/pressemitteilungen/pressearchiv/2018/303b/index.php ) Standorte gefunden und hoffen auf eure eifrige Unterstützung. 
Auf dieser Seite geht es um das Einrichten des State of the Art Enttarnungssystems. Bereits allein durch das Auge lassen sich die Kennzeichenscanner ebenfalls entdecken. Alle weiteren Enttarnungsmöglichkeiten, Schutzmaßnahmen, insbesondere die [Standorte der bayerischen AKE Anlagen](https://github.com/Scan-Rec/Scan-Rec/wiki/AKE-Bayern-Standorte), sowie weitere Informationen finden sich im [AKE Wiki](https://github.com/Scan-Rec/Scan-Rec/wiki).

# Bezeichnung „Scan-Rec“
Scan-Rec hat eine doppelte Bedeutung.
Das Logo „Scan-Rec“ vermittelt, dass ein Kennzeichen aufgenommen wird. Gleichzeitig steht es dafür, dass wir diese Scan-Anlagen aufzeichnen. 

# Kurzbeschreibung
Mittels der Infrarotkamera des Raspberry-PI wird der charakteristische Infrarot-Blitz der Kennzeichenscanner sichtbar gemacht. Die Kamera befindet sich auf der Hutablage des Fahrzeugs und filmt nach hinten hinaus (getönte Heckscheiben vermeiden, siehe Tipps und Tricks). Die Kamera ist fast senkrecht, minimal nach oben ausgerichtet positioniert, sodass die Straße fast gar nicht mehr, nachfolgende Fahrzeuge gut sichtbar sind. Wir haben noch nicht getestet ob es auch bei Fahrzeugen mit getönten Heckscheiben klappt, siehe auch unter Tipps und Tricks. Hier könnte die Infrarotabsorption in der Scheibe zu groß sein. Wir freuen uns über Rückmeldungen hierzu im Bereich „Issues“.

## Alle Infos
Diese Seite befasst sich mit dem Setup der Enttarnungsanlage. Alle Infos wie z.B. Standorte, Schutzmaßnahmen und Funktionsweise der Kennzeichenscanner sind im Wiki https://github.com/Scan-Rec/Scan-Rec/wiki zu finden.

# Die Anlage
So könnte eure Anlage aussehen. Es gibt eine Powerbank zur Stromversorgung, den Raspberry-PI, die Kamera und den GPS-Dongle an einem USB-Verlängerungskabel um GPS-Störungen durch die Kamera/Kamerakabel zu minimieren.

![](https://raw.githubusercontent.com/Scan-Rec/Scan-Rec/master/Ressourcen/DieAnlage.jpg)

# Mitsuchen und Gutschein erhalten
An die ersten 3 Einsender von neuen Kennzeichenscan-Anlagen verschenken wir je einen 25 Euro Gutschein. Einsendungen bitte über https://encrypt.to/0x4E3C9B04 

Voraussetzungen:
* Die Anlagen sind noch nicht im Layer "AKE verifiziert" in unserer Karte https://umap.openstreetmap.fr/en/map/ake-deutschland_234435 enthalten
* Tipp: Wir haben in der Karte vermutete Positionen. Dort ist die Wahrscheinlichkeit Anlagen zu finden aus unserer Sicht besonders hoch.
* Für die erste Suche reicht es aus die Augen offen zu halten und erst bei Fund diesen videotechnisch festzuhalten, siehe https://github.com/Scan-Rec/Scan-Rec/wiki/Weitere-einfache-Erkennungsm%C3%B6glichkeiten
* Aus dem Foto/Video muss die Position der Anlage klar hervorgehen, z.B. durch eine GPS-Einblendung oder einen ausreichend langen Ausschnitt um die Position durch Abfahrtsnamen auf der Gegenfahrbahn verifizieren zu können. D.h. sollte das Video keine GPS-Koordinaten zeigen, muss mindestens die komplette Fahrt zwischen 2 Ausfahrten eingesendet werden
* Das Foto/Video muss die Anlage bei Tag zeigen. Ein Video/Foto bei Nacht des IR-Blitzes nehmen wir gerne zusätzlich auf.
* Bei mehrfachen Einsendungen zur selben Anlage bekommt der Ersteinsender den Gutschein. Um Mehrfacheinsendungen zu vermeiden, werden wir die Position so schnell wie möglich in die Karte mit dem Hinweis auf ausstehende Verifikation eintragen. Den Gutschein senden wir erst nach Verifikation zu.
* Videoeinsendungen zur Durchfahrt der Anlage sind wünschenswert und erleichtert es uns die Position zu verifizieren.

Möchtet ihr namentlich oder mit einem Pseudonym als Entdecker sowohl hier, als auch auf der Karte genannt werden, teilt uns das bitte mit in welcher Form das geschehen soll. Wir verweisen auch gerne auf eure Homepage.

# Raspberry-PI Setup
1. Download des Rasperry-PI Images von https://www.raspberrypi.org/downloads/raspbian/ hier „Raspbian Stretch with desktop“ wählen (Update 05.11.2019 Raspian Lite wird nun auch unterstützt). Danach mit Etcher auf eine SD-Karte schreiben. Eine Anleitung dazu findet sich z.B. hier
https://couchpirat.de/tutorial-wie-man-mit-etcher-und-win32diskimager-das-betriebsystem-raspbian-installiert/ oder die offizielle Anleitung auf Englisch gibt es hier https://www.raspberrypi.org/documentation/installation/installing-images/README.md 
Bitte auf die aktuellste Etcher-Version achten, besonders wenn Etcher beim Valideren Fehler meldet
ACHTUNG: Windows 10 zeigt nach dem Flashen eventuell an, dass Dateien nicht gelesen werden könnten bzw. die Karte formatiert werden soll. Sollte dies der Fall sein: Hier unbedingt abbrechen klicken, es handelt sich hierbei um wichtige Linux-Partitionen, die Windows nicht lesen kann.
1. SD-Karte kurz entfernen und wieder einstecken, damit Windows die Partitionierungstabelle neu einliest
1. Eine Datei „ssh“ ohne Erweiterung auf der lesbaren „boot“ Partition erstellen und das Installationsskript „installieren.sh“ ebenfalls auf diese Partition kopieren. Gegebenenfalls muss Windows umgestellt werden, dass die Dateierweiterungen angezeigt werden oder einfach die ssh Datei aus dem Repository hier herunterladen.
1. Per SSH auf den Raspberry-PI mit Adresse „raspberrypi“ zugreifen. Der Benutzername lautet „pi“, das Kennwort „raspberry“. Es wird empfohlen dieses Kennwort zu ändern. Jetzt /boot/installieren.sh ausführen, KEIN SUDO davorsetzen. Ein ausführliches Tutorial für den SSH-Zugriff findet sich unter https://tutorials-raspberrypi.de/raspberry-pi-ssh-windows-zugriff-putty/ Mit Enter nun unverändert alle Dialoge bestätigen. Der Raspberry startet neu und das System ist einsatzbereit. Wichtig: Für den Zeitpunkt der Installation wird eine Internetverbindung auf dem RasperryPi benötigt, danach läuft das System komplett ohne Internet! Die Kamera braucht ebenfalls nicht im Setup aktiviert zu werden, wird durch das Skript erledigt.

Das Herzstück ist das RPi_Cam_Web_Interface https://github.com/silvanmelchior/RPi_Cam_Web_Interface welches durch das Skript automatisch heruntergeladen und installiert wird. Ein großes Dankeschön hierfür an den User silvanmelchior!

Eine Anleitung zum Anschließen der Kamera ist hier zu finden http://www.netzmafia.de/skripten/hardware/RasPi/kamera/index.html

# Zugriff
Ihr könnt natürlich per LAN und der Adresse http://raspberrypi am PC auf die Weboberfläche zugreifen, das Kamerabild betrachten und die Videos herunterladen. http://raspberrypi/html/media um alle Videos runterzuladen und auch GPS-Logs (Rechtsklick Speichern unter…)

Zugriff per WLAN:

**SSID**: Scan-Rec

**Passwort**: FindeAnlagen

Konfigurierbar über hostapd.conf direkt im Benutzerverzeichnis des Nutzers pi oder direkt das Installationsskript bearbeiten.

Zeile ssid= Scan-Rec (ziemlich weit oben)

Zeile wpa_passphrase= FindeAnlagen (ganz unten)

Über WLAN kann das Video manchmal ruckeln bis hin zu Aussetzern. Das tritt bei manchen WLAN-Chipkombinationen auf. Das aufgenommene Video ist fehlerfrei! Habt ihr große Probleme: Mit einen externen WLAN-Adapter und Anpassung der Konfiguration sollte es sich beheben lassen.

Durch Klick auf „Record Video start“ wird aufgenommen. Durch Klick auf „Record Video stop“ entsprechend gestoppt. Die Einstellungen bis auf die Rotation so belassen wie sie sind, sie wurden automatisch gesetzt um das Beste herauszuholen. Das Video wird gedreht aufgenommen um durch die Einblendung die oben angebrachten Scanner nicht z verdecken. Im VLC kann über Werkzeuge :arrow_forward: Effekte und Filter :arrow_forward: VideoEffekte :arrow_forward: Geometrie :arrow_forward: Transfomieren das Video um 180 in die richte Position gedreht werden. Sollen Videos der NoIR-Kamera automatisch nach Hochfahren gestartet werden (Automatische Aufnahme): „Edit schedule settings“ :arrow_forward: bei „Period Start“ „ca 1“ eintragen :arrow_forward: oben „Save Setttings“ klicken

Die Videos können in bis zu 4facher Geschwindigkeit (Rechnerabhängig ob es flüssig läuft) auf der Suche nach dem Infrarotblitz angesehen werden. Damit man das Üben kann, haben wir Beispielmaterial zur Verfügung gestellt, https://github.com/Scan-Rec/Scan-Rec/blob/master/Ressourcen/BlitzSerie/IR%20Blitz%20von%20hinten.mp4 

# Hardware
Folgende Hardware wird zwingend benötigt
* Raspberry PI 3B(+) (ca. 35 €)
* PI Camera NOIR V2 (ca. 30 €)
* Mikro-SD-Karte, mind. 16 GB empfohlen (ergibt ca. 5 Stunden Videokapazität)
* USB-KFZ Adapter oder Powerbank

## Optionale Komponenten
* 850 nm IR-Filter um bei Tag die Anlagen zweifelsfrei festzustellen z.B. aus diesem Set https://www.amazon.de/Neewer%C2%AE-St%C3%BCck-Infrarot-R%C3%B6ntgen-Filter/dp/B015XMSUB0/
* GPS-Dongle zur Positionseinblendung und Zeitsetzung, z.B. VK-172 https://www.ebay.de/sch/i.html?_nkw=VK-172&_sacat=0 Mit u-Center kann eine Updaterate von 10 Hz eingestellt werden. Die Kamera und GPS stören sich etwas, daher für optimalen Empfang den GPS-Dongle via USB-Verlängerungskabel anschließen. Die grüne LED des GPS-Dongle eventuell abkleben, da nachts durch Blinken ziemlich auffällig.
* Gehäuse für den Raspberry-PI
* Antirutschmatte zum Ablegen des Raspberry + Powerbank auf Hutablage
* Gehäuse für die Raspberry-PI Kamera. Wer mit dem Bohrer umgehen kann, nimmt https://www.amazon.de/Raspberry-Pi-Kameratasche-Klar-Transparent/dp/B00IJZJKK4 Das Kamera Loch ist für die Version 2 der Kamera zu klein und muss ausgeweitet werden. Wer diese Hürde meistert kann das Gehäuse durch Löcher sehr gut befestigen und die Kamera hat einen guten Aufnahmewinkel. Die optimale Ausrichtung der Kamera ist fast senkrecht, minimal nach oben geneigt. So ausgerichtet, dass unmittelbar oberhalb der nachfahrenden Autos gefilmt wird.
