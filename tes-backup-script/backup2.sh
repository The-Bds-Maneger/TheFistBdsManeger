#!/bin/bash
clear

#Software
BDS="$(wget -qO- https://raw.githubusercontent.com/Sirherobrine23/Minecraft-Bedrock-auto-install/linux/Update.txt)"
#caminho da instalação e do backup

if [[ -e installed.txt ]]; then
read -rp "qual diretorio está instalado: " -e -i "$(cat installed.txt)" PATH_TO_INSTALL
echo "Depois pode alterar o diretorio no installed.txt"
else
read -rp "a onde vai ser instalado: " -e -i "/home/minecraft" PATH_TO_INSTALL
touch installed.txt -a $PATH_TO_INSTALL
echo "$PATH_TO_INSTALL" >> installed.txt
fi




#PATH_TO_INSTALL="/mnt/d/Gitlab/Minecraft-Bedrock-auto-install/tes-backup-script/mcpe-teste/"
#Usuario
USUARIO=./
#OLD
#NEW

#Preparando
echo " "
echo "Backup?"
      read -rp "Nome do backup:  " -e -i "$(TZ=UTC+3 date +"%d-%m-%Y")" BACKUP
echo " "
echo "Por padrão é no /home/Minecraft-Backup, mais esse diretorio será a apagado depois mantendo os novos no $PATH_TO_INSTALL (debug)"
      read -rp "Aonde vai ser o backup: " -e -i "/home/Minecraft-Backup" PATH_TO_BACKUP
echo " "
echo "arquivos temporarios (debug)"
      read -rp "A onde vai ser a pasta temporaria: " -e -i "/tmp/mcpe-update" TMP_UPDATE
      read -rp  "A onde sera savo o backup para amazenamento: " -e -i "$(cd ~/;pwd)/mcpe-Backup" PATHBACKUP
echo " "
echo " "

#---------------------------------------------------------------------------------------------------------
cat "$PATH_TO_INSTALL/mcpe/server.properties" | grep "level-name=" >> "$TMP_UPDATE/level.txt" ;
sed -i "s|level-name=||g" "$TMP_UPDATE/level.txt"
MAPA=$(cat $TMP_UPDATE/level.txt) >>$USUARIO/log.txt 2>&1 ;
#---------------------------------------------------------------------------------------------------------
echo " "
echo " "

#copia
cp -r "$PATH_TO_INSTALL/mcpe/worlds" "$PATH_TO_BACKUP"
cp "$PATH_TO_INSTALL/mcpe/server.properties" "$PATH_TO_BACKUP"
cp "$PATH_TO_INSTALL/mcpe/whitelist.json" "$PATH_TO_BACKUP"

#copia de seguraça
apt-get install zip unzip -y
zip  "$PATHBACKUP/$BACKUP".zip -r "$PATH_TO_INSTALL"

#exterminar versao antig
rm -rf "$PATH_TO_INSTALL"

#baixar a nova versão
wget "$BDS" -O mcpe.zip
unzip mcpe.zip -d mcpe

#removendo alguns arquivos
rm -r mcpe/server.properties
rm -r mcpe/whitelist.json


#copiar mundo e as configuraçoe
cp -r "$PATH_TO_BACKUP/worlds" "./mcpe"
cp "$PATHBACKUP/server.properties" "./mcpe"
cp "$PATH_TO_BACKUP/whitelist.json" "./mcpe"

#movendo
mkdir $PATH_TO_INSTALL/
mv mcpe/ $PATH_TO_INSTALL

#remover arquivos antigos
rm mcpe.zip
rm -rf mcpe/
rm -rf $PATH_TO_BACKUP
rm -rf $TMP_UPDATE