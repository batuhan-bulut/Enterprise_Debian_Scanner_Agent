#!/bin/bash
if (( $EUID != 0 )); then
    echo "Please run as root."
    exit
fi
YOUR_USER=$1
AGENT_NAME=$2
API_TOKEN=$3
WORK_DIR="$PWD"


sudo yum install -y epel-release
sudo yum update -y
sudo yum install -y p7zip p7zip-plugins
sudo yum install -y nano tar gssntlmssp mono-complete libgdiplus
sudo yum install -y dotnet-sdk-3.1

echo "INSTALL DONE..."

sudo mkdir -p /home/"$YOUR_USER"/.local/share/Netsparker_Ltd
sudo chown -R "$YOUR_USER" /home/"$YOUR_USER"/.local/share/Netsparker_Ltd

sudo yum install -y pango.x86_64 libXcomposite.x86_64 libXcursor.x86_64 libXdamage.x86_64 libXext.x86_64 libXi.x86_64 libXtst.x86_64 cups-libs.x86_64 libXScrnSaver.x86_64 libXrandr.x86_64 GConf2.x86_64 alsa-lib.x86_64 atk.x86_64 gtk3.x86_64 xorg-x11-fonts-100dpi xorg-x11-fonts-75dpi xorg-x11-utils xorg-x11-fonts-cyrillic libX11-xcb.so.1 libnss3.so xorg-x11-fonts-Type1 xorg-x11-fonts-misc

echo "DONE..."


tar xf Invicti_Enterprise_Scanner_Agent.tar
chmod +x .local-chromium/Linux-*/chrome-linux/chrome
sleep 0.1
sed -i 's|    "AgentName": "",|    "AgentName": "'$AGENT_NAME'",|g' appsettings.json
echo step 7
sed -i 's|    "ApiToken": "",|    "ApiToken": "'$API_TOKEN'",|g' appsettings.json
echo step8
echo FINISH
echo SETTING AGENT as a Linux Service
sleep 2

cd /etc/systemd/system
sudo touch "$AGENT_NAME".service
echo [Unit] >> "$AGENT_NAME".service
echo Description=netsparker.service description >> "$AGENT_NAME".service
echo [Service] >> "$AGENT_NAME".service
echo Type=notify >> "$AGENT_NAME".service
echo KillMode=process >> "$AGENT_NAME".service
echo Restart=always >> "$AGENT_NAME".service
echo RestartSec=30 >> "$AGENT_NAME".service
echo SyslogIdentifier=$YOUR_USER >> "$AGENT_NAME".service
echo KillSignal=SIGINT >> "$AGENT_NAME".service
echo User=$YOUR_USER >> "$AGENT_NAME".service
echo WorkingDirectory= "$WORK_DIR" >> "$AGENT_NAME".service
echo ExecStart=/usr/bin/dotnet "$WORK_DIR"/Netsparker.Cloud.Agent.dll >> "$AGENT_NAME".service
echo ExecStop=/usr/bin/pkill -f ""$WORK_DIR"/Nhs/NetsparkerHelperService.exe" >> "$AGENT_NAME".service
echo [Install] >> "$AGENT_NAME".service
echo WantedBy=multi-user.target >> "$AGENT_NAME".service
sleep 0.5
echo Configure sudoers
sleep 0.5
cd /etc/sudoers.d
echo $PWD
sudo touch "$AGENT_NAME"-systemctl

echo "$YOUR_USER" ALL=\(ALL:ALL\) NOPASSWD: \/usr\/bin\/systemctl start "$AGENT_NAME".service >> "$AGENT_NAME"-systemctl
echo "$YOUR_USER" ALL=\(ALL:ALL\) NOPASSWD: \/usr\/bin\/systemctl stop "$AGENT_NAME".service >> "$AGENT_NAME"-systemctl
sudo systemctl daemon-reload
sudo systemctl start "$AGENT_NAME".service
echo DONE ...
