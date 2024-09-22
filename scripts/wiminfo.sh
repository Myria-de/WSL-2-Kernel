#!/usr/bin/env bash
# check WSL
SYS=$(uname -a | grep -qi wsl && echo WSL)
if [ "$SYS" == "WSL" ]
then
 if test -z "$SUDO_USER"
 then
   echo Fehler: Das Script muss mit sudo -E $0 gestartet werden.  
   exit 1
 fi
else
SYS="Linux"
fi

# wimlib installiert?
if [ -z $(which  wiminfo ) ]
then
echo -e "Fehler: wiminfo nicht gefunden. Bitte installieren Sie das Paket wimtools. Abbruch."
exit 1
fi

if [ "$SYS" == "Linux" ]
then
 gnome-disk-image-mounter $1
else
 if [ ! -d "/mnt/iso" ]
  then
   sudo -E mkdir /mnt/iso
  fi
  sudo -E mount -o loop -t udf $1 /mnt/iso
fi 
sleep 2
echo Mount: $1

if [ "$SYS" == "Linux" ]
then
MOUNTDIR=$(mount | grep $1 | awk '{print $3}')
echo "$MOUNTDIR"
else 
MOUNTDIR="/mnt/iso"
fi

if [ -e "$MOUNTDIR/sources/install.wim" ]
then
wiminfo $MOUNTDIR/sources/install.wim | grep -A1 Index
else
echo "$MOUNTDIR/sources/install.wim ist nicht vorhanden."
fi
sudo -E umount $1
