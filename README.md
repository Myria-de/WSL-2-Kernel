# WSL 2 optimieren und ausreizen
Das Windows Subsystem für Linux (WSL) ermöglicht den Start eines Linux-Systems und den Einsatz von Linux-Anwendungen unter Windows. Mit einem neuen Kernel lässt sich die Leistung verbessern.
## WSL installieren und Version prüfen
Im Windows-Terminal lassen sich Powershell, Eingabeaufforderung und WSL bequem nutzen. Unter Windows 11 ist es standardmäßig vorhanden, Windows-10-Nutzer installieren es über den Microsoft Store.

In der Powershell installieren Sie WSL mit
```
wsl --install -d Ubuntu-24.04
```
Die verfügbaren Distributionen lassen sich mit
```
wsl --list --online
```
abrufen. Danach starten Sie Windows neu. Nach der Anmeldung öffnet sich ein Linux-Terminal, in dem die Installation komplettiert wird. Sie werden aufgefordert, Benutzernamen und Passwort für das Linux-Konto festzulegen. Danach bringt man das Ubuntu-System mit
```
sudo apt update && sudo apt upgrade
```
auf den neusten Stand.

Im Windows-Terminal starten Sie Linux über das Menü, das nach einem Klick auf die Pfeil-Schaltfläche neben den Registerkarten zu sehen ist.
In der Powershell ermitteln Sie die WSL-Version mit
```
wsl -l -v
```
Sollte bei einer älteren Installation in der Spalte „Version“ eine „1“ erscheinen, aktualisieren Sie die Version mit diesen beiden Zeilen:
```
wsl --set-default-version 2
wsl --set-default [Distribution]
```
Den Platzhalter „[Distribution]“ ersetzen Sie durch die Bezeichnung der Distribution.
![302_00_WSL](https://github.com/user-attachments/assets/eeaa8b03-772c-4e25-9b69-2c9e125d43e0)
## Neuen Kernel für WSL 2 erstellen
Starten Sie Linux in WSL und installieren Sie einige Entwicklerpakete:
```
sudo apt install build-essential flex bison dwarves libssl-dev libelf-dev libncurses-dev git
```
**Schritt 1:** Erstellen Sie ein Arbeitsverzeichnis und laden Sie den Quellcode herunter (vier Zeilen):
```
mkdir kernel
cd kernel
git clone https://github.com/microsoft/WSL2-Linux-Kernel.git --depth=1 -b linux-msft-wsl-6.6.y
cd WSL2-Linux-Kernel
```
Die Kernel-Version passen Sie bei Bedarf an (siehe https://github.com/microsoft/WSL2-Linux-Kernel).

**Schritt 2:** Mit der Zeile
```
scripts/config --file Microsoft/config-wsl --set-str LOCALVERSION "-custom-microsoft-standard-WSL2"
```
geben Sie dem Kernel eine eigene Bezeichnung. Wer möchte, kann mit
```
make menuconfig KCONFIG_CONFIG=Microsoft/config-wsl
```
den Konfigurationseditor aufrufen und eigene Anpassungen vornehmen.

**Schritt 3:** Erstellen Sie den Kernel mit
```
echo 'yes' | make -j $(nproc) KCONFIG_CONFIG=Microsoft/config-wsl
```
und installieren Sie danach die Module mit
```
sudo make KCONFIG_CONFIG=Microsoft/config-wsl modules_install
```
**Schritt 4:** Rufen Sie im Windows-Explorer die Linux-Umgebung über den Eintrag unterhalb von „Linux“ im Navigationsbereich auf. Kopieren Sie die Datei „vmlinux“ aus Ihrem Homeverzeichnis beispielsweise in das Windows-Benutzerprofil in den Ordner „WSL“ („C:\Benutzer\[Benutzername]\WSL“).

**Schritt 5:** Unter Windows erstellen Sie die Datei „.wslconfig“ in Ihrem Profilordner. Tragen Sie die zwei Zeilen
```
[wsl2]
kernel=C:\\Users\\[Benutzername]\\WSL\\vmlinux
```
ein. Den Platzhalter „[Benutzername]“ ersetzen Sie durch Ihren Benutzernamen.
**Schritt 6:** In einer Powershell beenden Sie alle laufenden WSL-Instanzen mit
```
wsl --shutdown
```
Wenn Sie Linux im Windows-Subsystem für Linux starten, zeigt der Befehl
```
uname -a
```
die Version des neuen Kernels.
## Linux-Anwendung unter WSL ausprobieren
Unser Tool Win-Deploy ermöglicht ein schnelles Windows-Setup in einer Virtualbox-VM – und zwar unter Linux und WSL. 

Die Installation erfolgt in eine VHD-Datei, aus der sich das System auch über den Windows-Bootmanager starten lässt (VHD native boot). Die Arbeit erledigen einige Bash-Scripts und das Python-Tool 
„setup_win10“ (Original siehe https://m6u.de/PYDEP ). Win-Deploy ist ein grafisches Front-End für die Anpassung der Scripts. Virtualbox (www.virtualbox.org) sollte unter Windows im Standardordner installiert sein, andernfalls müssen Sie die Scripts anpassen.

Zur Installation entpacken Sie Win-Deploy (deploy-windows.tar.gz auf dieser Seite unter "Relleases") in das Linux-Home-Verzeichnis. Starten Sie im Terminal das Script „install-deps.sh“ aus dem Ordner „install“. Es richtet die nötigen Pakete ein.

Die VHD-Datei wird mit Hilfe von quemu-nbd über das Gerät „/dev/nbd[X]“ erstellt. Grafische Anwendungen werden mit erhöhten Rechten unter Linux in der Regel über das Tool pkexec gestartet, was in WSL zur Zeit nicht funktioniert. Daher starten Sie das Programm so:
```
sudo -E ./win_deploy
```
Sie benötigen die ISO-Datei des Windows-Installationsmediums, die Sie hinter „ISO-Datei“ wählen. Tragen Sie einen Namen für die VHD-Datei und eine Bezeichnung für die virtuelle Maschine ein. Hinter OS-Typ stellen Sie die gewünschte Windows-Version ein (Windows 7 bis 11). Der „Image-Index“ bestimmt die Edition. Den Wert können Sie per Klick auf „Index aus Install.wim ermitteln“ herausfinden. Für die automatische Installation per Antwortdatei klicken Sie auf „Antwortdatei erstellen“ und füllen das Formular aus. Damit ist auch eine Windows-11-Installation ohne Prüfung der Hardwarevoraussetzungen möglich. Mit einem Klick auf „VM erstellen“ wird die virtuelle Maschine angelegt und konfiguriert. Die Scripts starten dafür Vboxmanage aus dem Virtualbox-Installationsordner.

**Hinweise:** Die Funktionen von Win-Deploy ließen sich auch ausschließlich mit Windows-Tools realisieren. Der Aufwand wäre aber deutlich höher. Zudem zeigt unser Beispiel, wie sich selbst systemnahe Aufgaben mit ein und demselben Tool unter Linux und Windows erledigen lassen. Win-Deploy profitiert bei einigen Dateioperationen von einem optimierten WSL-Kernel (siehe „Ein neuer Kernel für WSL2“ weiter oben), so etwa beim Extrahieren der Windows-Installationsdateien in die VHD-Datei.
![302_02_Win-Deploy](https://github.com/user-attachments/assets/39226b45-b4b9-4741-965b-25911b059681)
