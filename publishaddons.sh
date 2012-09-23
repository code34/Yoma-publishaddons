#!/bin/bash
#
# Export to YOMA by =[A*C]= code34
#


rsync -r --delete --force --update --exclude '*.7z' --exclude '.*' /home/arma/_serveur/arrowhead2/@* /home/arma/_serveur/updater/

rm /home/arma/_serveur/serverinfo/Addons.xml

STR='<?xml version="1.0" standalone="yes"?>\n
<DSServer xmlns="http://tempuri.org/DSServer.xsd">'
echo -e $STR >> /home/arma/_serveur/serverinfo/Addons.xml

cd /home/arma/_serveur/updater/

find . ! -name "*.7z" -type f -ls > /home/arma/_serveur/tmpfile

while read LINE
do
URL=`echo $LINE | /usr/bin/gawk '{ print $11}' | sed -e 's/\.\///'`
if [ -f $URL ]
then
NAME=`basename $URL`
SUM=`md5sum $URL | /usr/bin/gawk '{ print toupper($1) }'`
SIZE=`echo $LINE | /usr/bin/gawk '{ print $7 }'`
URLPATH=`dirname $URL | sed -e 's/\//\\\/g'`
STR="<Addons>\n
	<Md5>$SUM</Md5>\n
	<Path>$URLPATH</Path>\n
	<Pbo>$NAME</Pbo>\n
	<Size>$SIZE</Size>\n
	<Url>$URL.7z</Url>\n
</Addons>"
echo $URL.7z
if [ -f "/home/arma/_serveur/updater/$URL.7z" ]
then
DATEFILE=`ls -la /home/arma/_serveur/updater/$URL | gawk '{print $6}'`
HOUR=`ls -la /home/arma/_serveur/updater/$URL | gawk '{print $7}'`
DATEFILEZ=`7zr l /home/arma/_serveur/updater/$URL.7z | grep ' '$NAME | gawk '{print $1}'`
HOURZ=`7zr l /home/arma/_serveur/updater/$URL.7z | grep ' '$NAME | gawk '{print $2}'|gawk 'BEGIN { FS=":" }{print $1":"$2}'`
if [ -z "$DATEFILEZ" ]
then
DATEFILEZ='2000-01-01'
fi
if [ $HOURZ != $HOUR ] 
then
DATEFILEZ='2000-01-01'
fi
if [ $DATEFILE != $DATEFILEZ ]
then
rm -rf  /home/arma/_serveur/updater/$URL.7z
rm -rf /home/arma/_serveur/updater/$URL
rsync -r /home/arma/_serveur/arrowhead2/$URL /home/arma/_serveur/updater/$URL
7zr a /home/arma/_serveur/updater/$URL.7z /home/arma/_serveur/updater/$URL
fi
else
7zr a /home/arma/_serveur/updater/$URL.7z /home/arma/_serveur/updater/$URL
fi
echo $STR >> /home/arma/_serveur/serverinfo/Addons.xml
fi
done < /home/arma/_serveur/tmpfile

STR='</DSServer>'
echo -e $STR >> /home/arma/_serveur/serverinfo/Addons.xml

cd /home/arma/_serveur/
chmod -R 755 /home/arma/_serveur/updater/*
7zr a serverinfo.7z serverinfo/
mv serverinfo.7z updater/
