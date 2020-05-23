#!/bin/bash

#ins Homeverzeichnis wechseln
cd 

sudo apt update -y
sudo apt-get install gpsd gpsd-clients git python3-pip -y

#GPSD Option zum Autostart setzen
sudo sed -i 's/^GPSD_OPTIONS=.*$/GPSD_OPTIONS="-n"/' /etc/default/gpsd


#GPS Library verfügbar machen
sudo pip3 install gpsd-py3
sudo pip3 install RPi.GPIO

sudo apt-get install ntp -y

sudo apt-get install hostapd dnsmasq rng-tools -y

#Kamera aktivieren, benötigt neustart

sudo raspi-config nonint do_camera 0

#Zeitzonesetzen
sudo timedatectl set-timezone Europe/Berlin



#GPS-Einblendung

cat > GPSEinblendung.py <<'endmsg'
#!/usr/bin/env python3

from time import sleep

import time
import gpsd #https://pypi.python.org/pypi/gpsd-py3/0.2.0
import warnings
import tempfile
import shutil
import subprocess
import RPi.GPIO as GPIO

# Connect to the local gpsd

time.sleep(10) #Ein bisschen Zeit geben bis GPSD hochgefahren ist

gpsd.connect()

updaterate = 10 #Anzahl der Updates pro Sekunde

# Get gps position

#packet = gpsd.get_current()
gpsZeit = None
# See the inline docs for GpsResponse for the available data
pausiert = False

print("GPS-Einblendung läuft...")

i = 0
temperatur = "Warte"
throttleStatus = "Warte"

global packet

while True:

    zeitstart=int(round(time.time() * 1000))
    try:
        packet = gpsd.get_current()
    except UserWarning:
        print("GPS gerade nicht verfügbar, warte 1 Sekunde")
        time.sleep(1)
        pausiert = True
        continue
    if(pausiert):
        pausiert = False
        print("GPS wieder verfügbar, GPS-Einblendung läuft wieder")
    gpsZeitZuvor=gpsZeit
    gpsZeit=packet.time

    if(not(gpsZeitZuvor == gpsZeit)): #nur wenn neue Daten vorliegen

        GPS = "UTC: " + gpsZeit + " Lat: " + ((str)(packet.lat)).ljust(12,'0')+ " Long: " + ((str)(packet.lon)).ljust(12,'0') + " Hoehe: " + (str)(packet.alt).rjust(6,'0') +"\nGes. " \
              + ((str)(round(packet.hspeed*3.6,1))).rjust(5,'0') + " km/h Richtung: " + (str)(round(packet.track)).rjust(3,'0') \
               + " Grad Sats: " + (str)(packet.sats_valid).rjust(2,'0')+ " / " + (str)(packet.sats).rjust(2,'0')# + "\n"

        
        i = i + 1
        if(i==updaterate): #einmal pro Updateintervall prüfen
            
            #Spannungs- und Temperaturinformationen holen
            temperatur = subprocess.run(['/opt/vc/bin/vcgencmd', 'measure_temp'], stdout=subprocess.PIPE)
            temperatur=str(temperatur.stdout)
            temperatur=temperatur[7:-3]
            #print(temperatur)
            throttleStatus = subprocess.run(['/opt/vc/bin/vcgencmd', 'get_throttled'], stdout=subprocess.PIPE)
            throttleStatus = str(throttleStatus.stdout)
            throttleStatus = throttleStatus[12:-3]
            #print(throttleStatus)
            i=0

        GPS = GPS + " CPU-Temp: " + temperatur + " Throttle-Status: " + throttleStatus + "\n"
        

        #tempDatei = tempfile.NamedTemporaryFile(mode='w',delete=False,encoding='iso-8859-1')
        #tempDatei.write(GPS)
        #print(tempDatei.name)
        #tempDatei.close()

        #shutil.move(tempDatei.name,'/dev/shm/mjpeg/user_annotate.txt')
       

        gpsTextDatei = open('/dev/shm/mjpeg/user_annotate.txt', 'w', encoding='iso-8859-1')
        gpsTextDatei.write(GPS)
        gpsTextDatei.close()

        #print(GPS)
        

    zeitende=int(round(time.time() * 1000))
    sleepzeit=abs((1000/updaterate)-(zeitende-zeitstart)-1) #;Minus Konstante um Zeit zu geben, abs() damit kein negativer Wert herauskommt
    #print(sleepzeit) #Genau die Zeit schlafen, sodass 100 ms pause sind
    time.sleep(sleepzeit / 1000.0)


#



endmsg

chmod +x GPSEinblendung.py

#GPS-Logger

cat > GPSLogger.sh <<'endmsg'
#!/bin/sh

dateipfad="/var/www/html/media/" #wichtig auf abschließenden Schrägstrich achten!
dateiname=$dateipfad`date "+%d.%m.%Y %H.%M"`.nmea


echo  Speichere GPS-Log in $dateiname

gpspipe -r -o "$dateiname" &

endmsg

chmod +x GPSLogger.sh

#Webcam-Aufzeichnen

cat > Webcam-Aufzeichnung.sh <<'endmsg'
#!/bin/sh

while true
do

dateipfad="/var/www/html/media/" #wichtig auf abschließenden Schrägstrich achten!
dateiname=$dateipfad`date "+%d.%m.%Y %H.%M.%S"`.h264


echo  Speichere Video in $dateiname

geraet=$(v4l2-ctl --list-devices | grep -A 1 usb | grep '/dev/video[0-9]*' | tr -d "[:space:]")

ffmpeg -f v4l2 -input_format h264 -framerate 30 -video_size 1920x1080 -i $geraet -codec:v copy "$dateiname"

#Wenn keine Kamera angeschlossen ist
sleep 10s

done


endmsg

chmod +x Webcam-Aufzeichnung.sh

#H264 in MP4 umwandeln, manuell

cat > H264zuMP4.sh <<'endmsg'
#!/bin/bash

for datei in /var/www/html/media/*.h264
do
#echo ${datei%%.h264}.mp4
sudo MP4Box -fps 30 -add "$datei" -new "${datei%%.h264}.mp4"

#Eingabedatei nur löschen, wenn alles gut gegangen ist
if [ $? -eq 0 ]
then
echo gut
sudo rm "$datei"
fi

done
endmsg

chmod +x H264zuMP4.sh



#WLAN Zugriff einrichten

sudo apt-get install hostapd dnsmasq -y

cat > startHostapd.sh <<'endmsg'
#!/bin/bash

#Skript um erst nach einiger Wartezeig hostapd zu starten

#Seit Debian Buster erforderlich, sonst kann keine WLAN Verbindung hergestellt werden
rfkill unblock wifi


sleep 10s
hostapd /home/pi/hostapd.conf > /home/pi/hostapd.log
endmsg

chmod +x startHostapd.sh

cat > hostapd.conf <<'endmsg'
# Schnittstelle und Treiber
interface=wlan0
driver=nl80211

# WLAN-Konfiguration
ssid=Scan-Rec
channel=1

# ESSID sichtbar
ignore_broadcast_ssid=0

# Ländereinstellungen
country_code=DE
ieee80211d=1

# Übertragungsmodus g = 2,4 GHz
hw_mode=g

# Enable 802.11n
ieee80211n=1

# Enable 40MHz channels with 20ns guard interval
ht_capab=[HT40][SHORT-GI-20][DSSS_CCK-40]

# Optionale Einstellungen
# supported_rates=10 20 55 110 60 90 120 180 240 360 480 540

# Draft-N Modus aktivieren (optional, nur für entsprechende Karten)
# ieee80211n=1

# Übertragungsmodus / Bandbreite 40MHz
# ht_capab=[HT40+][SHORT-GI-40][DSSS_CCK-40]

# Beacons
beacon_int=100
dtim_period=2

# Accept all MAC addresses
macaddr_acl=0

# max. Anzahl der Clients
max_num_sta=20

# Größe der Datenpakete/Begrenzung
rts_threshold=2347
fragm_threshold=2346

# hostapd Log Einstellungen
#logger_syslog=-1
#logger_syslog_level=2
#logger_stdout=-1
#logger_stdout_level=2

# temporäre Konfigurationsdateien
#ctrl_interface=/var/run/hostapd
#ctrl_interface_group=0

# Authentifizierungsoptionen 
auth_algs=3

# wmm-Funktionalität
wmm_enabled=1

# Verschlüsselung / hier rein WPA2
wpa=2
#rsn_preauth=1
#rsn_preauth_interfaces=wlan0
wpa_key_mgmt=WPA-PSK
rsn_pairwise=CCMP

# Schlüsselintervalle / Standardkonfiguration
wpa_group_rekey=600
wpa_ptk_rekey=600
wpa_gmk_rekey=86400

# Zugangsschlüssel (PSK) / hier in Klartext (ASCII)
wpa_passphrase=FindeAnlagen
endmsg


#statische IP für WLAN konfigurieren

echo interface wlan0 | sudo tee -a /etc/dhcpcd.conf
echo static ip_address=192.168.3.1/24 | sudo tee -a /etc/dhcpcd.conf

#Zeit per GPS beziehen

echo server 127.127.28.0 minpoll 4 maxpoll 4 | sudo tee -a /etc/ntp.conf
echo fudge 127.127.28.0 time1 0.535 refid GPS flag1 1 | sudo tee -a /etc/ntp.conf

sudo mv /etc/dnsmasq.conf /etc/dnsmasq.conf.org
sudo bash -c "cat > /etc/dnsmasq.conf <<'endmsg'
interface=wlan0
listen-address=192.168.3.1
dhcp-range=192.168.3.10,192.168.3.250,255.255.255.0,24h
dhcp-option=6,192.168.3.1
port=0
resolv-file=
no-resolv
no-poll
server=192.168.3.1
domain=local

endmsg"


#Startskripte installieren

(crontab -l ; echo "@reboot sudo /home/pi/GPSLogger.sh") | sort - | uniq - | crontab -
(crontab -l ; echo "@reboot /home/pi/GPSEinblendung.py") | sort - | uniq - | crontab -
(crontab -l ; echo "@reboot sudo /home/pi/startHostapd.sh") | sort - | uniq - | crontab -
#ausgenommen, weil aufnahme über PiCamera gestartet wird
#(crontab -l ; echo "@reboot /home/pi/Webcam-Aufzeichnung.sh") | sort - | uniq - | crontab -

#Raspberry Kamera installieren
git clone https://github.com/silvanmelchior/RPi_Cam_Web_Interface.git
cd RPi_Cam_Web_Interface
./install.sh

#Kamera stoppen, nur dann kann Skript überschrieben werden
./stop.sh


#Wieder ins Homeverzeichnis zurückwechseln
cd 

#Konfiguration für PiCamera schreiben
cat > /home/pi/uconfig <<'endmsg'
annotation %aRPi Cam %D.%M.%Y %h:%m:%s.%u
anno_background 1
anno_text_size 22
video_stabilisation 0
exposure_mode nightpreview
colour_effect_en 0
rotation 180
hflip 0
vflip 0
raw_layer 0
width 1024
video_width 1640
video_height 1232
video_fps 30
video_bitrate 0
MP4Box 2
MP4Box_fps 30
image_quality 40
vector_preview 0
endmsg

sudo mv /home/pi/uconfig /var/www/html/uconfig
sudo chown www-data /var/www/html/uconfig
sudo chgrp www-data /var/www/html/uconfig

#H264 in MP4 umwandeln, automatisch bei start
cat > startstop.sh <<'endmsg'
#!/bin/bash
# example start up script which converts any existing .h264 files into MP4
#Check if script already running
mypidfile=/var/www/html/macros/startstopX.sh.pid

NOW=`date +"-%Y/%m/%d %H:%M:%S-"`
if [ -f $mypidfile ]; then
        echo "${NOW} Script already running..." >> /var/www/html/scheduleLog.txt
        exit
fi
#Remove PID file when exiting
trap "rm -f -- '$mypidfile'" EXIT

echo $$ > "$mypidfile"

#Do conversion
if [ "$1" == "start" ]; then
  #Code um h264 Dateien in MP4 zu wandeln
  for datei in /var/www/html/media/*.h264
do
#echo ${datei%%.h264}.mp4
MP4Box -fps 30 -add "$datei" -new "${datei%%.h264}.mp4"

#Eingabedatei nur löschen, wenn alles gut gegangen ist
if [ $? -eq 0 ]
then
echo gut
rm "$datei"
fi
done
/home/pi/Webcam-Aufzeichnung.sh &
fi
endmsg

chmod +x startstop.sh
sudo chown www-data startstop.sh
sudo mv startstop.sh /var/www/html/macros/startstop.sh


cat > /home/pi/throttleMonitor.sh <<'endmsg'
#!/bin/sh

while true
do
temp=`/opt/vc/bin/vcgencmd measure_temp`
status=`./throttleStatus.sh`
frequenz=`/opt/vc/bin/vcgencmd measure_clock arm | tr -d "frequency(45)="`
#declare -i frequenz
frequenz=$(($frequenz/1000000))  #in MHz umrechnen
clear
echo $temp
echo Taktfrequenz $frequenz MHz
echo "$status"
sleep 1s
done


endmsg

chmod +x throttleMonitor.sh



cat > throttleStatus.sh <<'endmsg'
#!/bin/bash

#Flag Bits
UNDERVOLTED=0x1
CAPPED=0x2
THROTTLED=0x4
HAS_UNDERVOLTED=0x10000
HAS_CAPPED=0x20000
HAS_THROTTLED=0x40000

#Text Colors
GREEN=`tput setaf 2`
RED=`tput setaf 1`
NC=`tput sgr0`

#Output Strings
GOOD="${GREEN}NO${NC}"
BAD="${RED}YES${NC}"

#Get Status, extract hex
STATUS=$(vcgencmd get_throttled)
STATUS=${STATUS#*=}

echo -n "Status: "
(($STATUS!=0)) && echo "${RED}${STATUS}${NC}" || echo "${GREEN}${STATUS}${NC}"

echo "Undervolted:"
echo -n "   Now: "
((($STATUS&UNDERVOLTED)!=0)) && echo "${BAD}" || echo "${GOOD}"
echo -n "   Run: "
((($STATUS&HAS_UNDERVOLTED)!=0)) && echo "${BAD}" || echo "${GOOD}"

echo "Throttled:"
echo -n "   Now: "
((($STATUS&THROTTLED)!=0)) && echo "${BAD}" || echo "${GOOD}"
echo -n "   Run: "
((($STATUS&HAS_THROTTLED)!=0)) && echo "${BAD}" || echo "${GOOD}"

echo "Frequency Capped:"
echo -n "   Now: "
((($STATUS&CAPPED)!=0)) && echo "${BAD}" || echo "${GOOD}"
echo -n "   Run: "
((($STATUS&HAS_CAPPED)!=0)) && echo "${BAD}" || echo "${GOOD}"

endmsg

chmod +x throttleStatus.sh

#Speicherplatz gewinnen, ca. 1 GB

sudo apt-get remove --purge wolfram-engine scratch minecraft-pi sonic-pi dillo gpicview oracle-java8-jdk openjdk-7-jre oracle-java7-jdk openjdk-8-jre -y
sudo apt-get clean
sudo apt-get autoremove -y





#endgültiger Neustart
cd .. #eine ebene nach oben und dann Skript selbst löschen um erneute Installationsversuche zu verhindern
sudo rm /boot/installieren.sh ; sudo reboot