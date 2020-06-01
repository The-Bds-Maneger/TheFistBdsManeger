#!/bin/bash
clear

#--unistall
REMOVE=$(pwd)

#Debian - ubuntu
sudo apt install screen net-tools -y >>$USUARIO/log.txt 2>&1 ;

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

#Usuario
USUARIO=$(cd ~/;pwd)

# Iniacialização
file=mcpe-server
FILE2=mcpe-start.sh

#pode ser aqui ali ou DEBIAN
TMP=/home/Minecraft-temp
sudo mkdir $TMP >>$USUARIO/log.txt 2>&1 ;

# Remoção dos arquivo de log
sudo rm -rf $TMP/level.txt >>$USUARIO/log.txt 2>&1 ;

#Espaço
echo "o Diretorio do seu usuario é $USUARIO"
echo "Começamos ás $(TZ=UTC+3 date +"%H:%M:%S")"
echo " "
echo "--------------"
echo " "

#Root
if [ "$EUID" -ne 0 ]; then
	echo "Você não está executando o script com root ou sudo"
	exit 1
fi
if [[ -e /etc/debian_version ]]; then
	source /etc/os-release
	OS=$ID # debian or ubuntu
else
	echo "Você não tem instalado ou não esta com sistema Debian ou Ubuntu "
	exit 1
fi
case $1 in
   "--install") 
                  #banner
                  cat banner.txt;
                  # Prerequisite
                  echo "  ";
                  echo "Instalando o Wget e unzip";
                  echo -ne "#                         (01%)\r";
                  sudo apt install -y wget unzip >>$USUARIO/log.txt 2>&1 ;
                  echo -ne "##                        (02%)\r";
                  echo " ";
                  echo "Criando diretorio do servidor no $PATH_TO_INSTALL"
                  sudo mkdir $PATH_TO_INSTALL >>$USUARIO/log.txt 2>&1 ;
                  #Download do arquivos servidor
                  echo -ne "#####                     (20%)\r";
                  echo "Baixando o Software do Servidor";
                  sudo wget "$BDS" -O mcpe.zip >>$USUARIO/log.txt 2>&1 ;
                  echo -ne "########                  (40%)\r";
                  echo "Instalando o Servidor";
                  sudo unzip mcpe.zip -d $PATH_TO_INSTALL//mcpe >>$USUARIO/log.txt 2>&1 ;
                  sudo rm -rf mcpe.zip;
                  echo -ne "#############             (50%)\r";
                  #config
                  rm -rf $PATH_TO_INSTALL//mcpe/server.properties >>$USUARIO/log.txt 2>&1 ;
                  rm -rf $PATH_TO_INSTALL//mcpe/whitelist.json >>$USUARIO/log.txt 2>&1 ;
                  cp -r ./server.properties $PATH_TO_INSTALL//mcpe/ >>$USUARIO/log.txt 2>&1 ;
                  cp -r ./whitelist.json $PATH_TO_INSTALL//mcpe/ >>$USUARIO/log.txt 2>&1 ;
                  echo -ne "#######################   (100%)\r";
                  echo -ne "####### completo ######   (100%)\r";
                  echo "O log está no arquivo $USUARIO/log.txt ou /tmp/install.log"
      ;;
      "--update")

      
      ;;
      "--backup")
            if [ -e /sbin/mcpe-server ] ; then
                  echo "Para fazer o backup coloque sim (yes) e de [enter], caso não queira, não (no) e de [enter]"
                  read -rp "Vai querer fazer o backup?  " -e -i "sim" BC
                  case $BC in
                  [simyes]* )cp backup.txt $PATH_TO_INSTALL ;;
                  [naono]* ) exit;;
                  * ) echo "por favor qual, sim ou não "
                  esac
            else
                echo "não podemos cria agora, por favor execute primeiro o --iniciar"
                  

            fi
      ;;
      "--fundo")
            rm start.sh
            rm -rf /tmp/level.txt
            rm -rf /sbin/mcpe
            cat $PATH_TO_INSTALL//mcpe/server.properties | grep "level-name=" > /tmp/level.txt ; sed -i "s|level-name=||g" "/tmp/level.txt"
            MAPA_DO_SERVIDOR=$(cat /tmp/level.txt)


            echo " #!/bin/bash " >> start.sh
            echo " if [[ -e $PATH_TO_INSTALL/backup.txt ]]; then " >> start.sh
            echo "     echo 'Com Backup, já já iniciamos seu servidor' " >> start.sh
            echo "     cd $PATH_TO_INSTALL/mcpe/ " >> start.sh
            echo "     LD_LIBRARY_PATH=. ./bedrock_server " >> start.sh
            echo "     cd $PATH_TO_INSTALL/mcpe/ " >> start.sh
            echo "     echo 'Fazendo backup do mapa'" >> start.sh
            echo '     GDRIVE_FOLDE=ID-DA-PASTA-NO-GOOGLE-DRIVE' >> start.sh
            echo "     cd worlds/ ; zip '$MAPA_DO_SERVIDOR'.zip -r '$MAPA_DO_SERVIDOR' "  >> start.sh 
            echo "     gdrive upload --parent $GDRIVE_FOLDE $MAPA_DO_SERVIDOR.zip " >> start.sh
            echo "     rm $MAPA_DO_SERVIDOR.zip" >> start.sh
            echo " else " >> start.shecho "     echo 'Sem backup, já já iniciamos seu servidor' " >> start.sh
            echo "     cd $PATH_TO_INSTALL/mcpe/ " >> start.sh
            echo "     LD_LIBRARY_PATH=. ./bedrock_server " >> start.sh
            echo 'fi ' >> start.sh
            echo ' exit 1' >> start.sh
            sudo mv start.sh /sbin/mcpe-server ; sudo chmod a+x /sbin/mcpe-server ; 
            echo " "
            echo "Para deixar o servidor em segundo plano aperte CRTL + A + D. deixara em segundo plano para voltar basta executar o comando screen -r"
      ;;
      "--sistema")
      wget "https://drive.google.com/uc?export=download&id=1UlemfOSQUxbxTFDriAeDV7o1hRwXcS43" -O /usr/bin/gdrive >>$USUARIO/log.txt 2>&1 ;
      chmod a+x /usr/bin/gdrive
	if [[ -e /sbin/mcpe-server ]]; then
            echo "Percebi que já tem o $file pronto. Otimo!"
            echo "montando o arquivos para que tudo nos ajude"
            sudo cp start-on-system.sh /etc/init.d/mcpe-server;
            echo "copiando o arquivo";
            sudo chmod a+x /etc/init.d/mcpe-server;
            update-rc.d mcpe-server enable
            echo "pronto ele inicia junto com sistema(Beta), o comando abaixo pode ajudar"
            echo " "
            echo 'sudo service mcpe-server start | stop | restart'
            echo " "
	else
            #Config File
            echo "percebir que não executou $file, sem problema vamos fazer isso agora!"
            echo "montando o arquivo necessario espere"
            rm -rf /tmp/level.txt
            rm -rf /sbin/mcpe
            cat $FILE2 > "$file"
            cat $PATH_TO_INSTALL//mcpe/server.properties | grep "level-name=" > /tmp/level.txt ; sed -i "s|level-name=||g" "/tmp/level.txt"
            sed -i "s|DIRE|$PATH_TO_INSTALL|g" "$file";
            sed -i "s|MAPASS|$(cat /tmp/level.txt)|g" "$file"
            sed -i "s|PATH_TO_INSTALL|$PATH_TO_INSTALL|g" "$file"
            sudo mv "$file" /sbin/$file ; sudo chmod a+x /sbin/$file ;
            echo "arquivo pronto"
            echo "agora o outro arquivo"
            #pos
            sudo rm -rf /etc/init.d/mcpe
            sudo rm -rf /etc/init.d/mcpe-server
            sudo cp start-on-system.sh /etc/init.d/mcpe-server;
            echo "copiando o arquivo";
            sudo chmod a+x /etc/init.d/mcpe-server;
            update-rc.d mcpe-server enable
            echo "pronto ele inicia junto com sistema(Beta) o comando abaixo pode ajudar"
            echo 'sudo service mcpe start | stop | restart'
            echo " "
	fi
      ;;
      "--ip")

      #Comando --ip variaveis
            IP_V4=$(ip addr | grep 'inet' | grep -v inet6 | grep -vE '127\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}' | grep -oE '[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}' | head -1)
            SEARCH_IPV6=$(ip -6 route ls | grep default | grep -Po '(?<=dev )(\S+)' | head -1)
            IP_V6=$(ifconfig $SEARCH_IPV6 | grep "inet6" | awk -F' ' '{print $2}' | awk '{print $1}') 
            IP_PUBLICO=$(wget -qO- http://ipecho.net/plain)
            #Echo's
                  echo "Seu IPv4 é $IP_V4 para Jogar localmente , e o Seu IPv6 é $(echo -ne $IP_V6)"
                  echo " "
                  echo "Caso Queira Jogar Remotamento com alguém Abra as Portas 19132 e 19133 no seu Roteador ou seu Firewall, seu IPv4 Publico é $IP_PUBLICO"
                  echo "Também verifique se sua operadora ou provedor libera as portas do servidor. contate-os"
            echo " ";
      ;;
      "--unistall") sudo rm -rf $REMOVE
      ;;
      *) cat help.txt ; echo " ";
      exit 1
      ;;
esac

echo " "
echo "--------------"
echo " "
echo "qualquer erro no script me comunique no https://github.com/Sirherobrine23/Minecraft-Bedrock-auto-install/issues"
echo "Terminamos as $(TZ=UTC+3 date +"%H:%M:%S")"
sudo rm -rf mcpe.zip
