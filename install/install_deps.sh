#!/usr/bin/env bash
WORKDIR=`pwd`
GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m'

# check WSL
if [ ! -z $WSL_DISTRO_NAME ]
then
SYS="WSL"
PATH="/mnt/c/Program Files/Oracle/VirtualBox":$PATH
VBOXPATH="/mnt/c/Program Files/Oracle/VirtualBox/"
else
SYS="Linux"
fi

echo -e "- ${GREEN}Prüfe Voraussetzungen...${NC}"
pkgs='qemu-utils wimtools libparted-dev dosfstools ntfs-3g'
ToInstall=
# Virtualbox ist installiert?
if [ "$SYS" == "WSL" ]
then
 if [ ! -e "$VBOXPATH"/VBoxManage.exe ]
  then
   echo -e "${RED}Fehler: Bitte installieren Sie zuerst Virtualbox. Abbruch.${NC}"
  fi
else
 if [ -z $(which VBoxManage) ]
 then
 echo -e "${RED}Fehler: Bitte installieren Sie zuerst Virtualbox. Abbruch.${NC}"
 exit 1
 fi
fi
 
for pkg in $pkgs; do
  echo Prüfe $pkg
  status="$(dpkg-query -W --showformat='${db:Status-Status}' "$pkg" 2>&1)"
  if [ ! $? = 0 ] || [ ! "$status" = installed ]; then
    install=true
    ToInstall="$ToInstall $pkg"
    echo "$pkg nicht gefunden"
    #break
  fi
done

if [ -z "$ToInstall" ]
then
echo -e "- ${GREEN}Alle Basis-Voraussetzungen sind erfüllt.${NC}"
else
echo -e "- ${GREEN}Installiere $ToInstall${NC}"
sudo apt -y install $pkgs
fi

# ms-sys ist installiert?
if [ -z $(which ms-sys) ]
then
echo -e "${RED}Das Tool ms-sys fehlt. Installiere das Paket.${NC}"
cd $WORKDIR
wget -O ms-sys_2.8.0-1_amd64.deb "https://www.myria.de/?sdm_process_download=1&download_id=324518"
sudo apt install ./ms-sys_2.8.0-1_amd64.deb
fi
