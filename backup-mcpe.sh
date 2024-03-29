#!/bin/bash
DATE="$(TZ=UTC+3 date +"%H-%M-%S")"
DA2TE=""$(TZ=UTC+3 date +"%d/%m/%Y-%H-%M-%S")"
TM="/tmp/"
MKDIRID="IDSh23"
rm -rf "$TM/ID.txt"
gdrive mkdir $(echo $DA2TE) -p "$MKDIRID" >> "$TM/ID.txt"
sed -i "s| created||g" "$TM/ID.txt"
sed -i "s|Directory ||g" "$TM/ID.txt"
GDRIVE_FOLDE="$(cat $TM/ID.txt)"
# leste
PATH_TO_INSTALL="MINESh23"
PATH_TO_BACKUP="MINE2Sh23"
MAPS_DO="NAMESh23"
ALLNAME="$MAPS_DO-$DATE"
########################################
cd "$PATH_TO_INSTALL/worlds/"
zip "$ALLNAME.zip" -r "$MAPS_DO"
cp "$ALLNAME.zip" "$PATH_TO_BACKUP/"
gdrive upload "$ALLNAME.zip" --parent "$GDRIVE_FOLDE"
rm "$ALLNAME.zip"
