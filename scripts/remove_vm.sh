#!/usr/bin/env bash

VMNAME=$1
if test -z "$VMNAME"
then
echo Fehler: Der Name der VM muss angegeben werden.
exit 1
fi
# check WSL
SYS=$(uname -a | grep -qi wsl && echo WSL)
if [ "$SYS" == "WSL" ]
then
 VBOXPATH="/mnt/c/Program Files/Oracle/VirtualBox/VBoxManage.exe"
else
 SYS="Linux"
 VBOXPATH=$(which VBoxManage)
fi

echo -e Lösche VM: $VMNAME
"$VBOXPATH" unregistervm $VMNAME --delete-all
echo Löschen beendet
