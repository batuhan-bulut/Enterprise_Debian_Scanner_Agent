#!/bin/bash

#### FOR CHECKING SUDO USER

if (( $EUID != 0 )); then
    echo "Please run as root."
    exit
fi

YOUR_USER=$1
AGENT_NAME=$2
API_TOKEN=$3
WORK_DIR="$PWD"

sudo apt update && sudo apt upgrade -y

echo STEP 1 ... SUCCESS

sudo apt-get install p7zip-full -y
sudo apt install -y wget gss-ntlmssp nano mono-complete apt-transport-https
echo STEP 2 ... SUCCESS

wget https://packages.microsoft.com/config/debian/10/packages-microsoft-prod.deb -O packages-microsoft-prod.deb
sudo dpkg -i packages-microsoft-prod.deb && sudo apt update
sudo apt install -y dotnet-sdk-3.1
echo STEP 3 ... SUCCESS

echo "deb http://security.ubuntu.com/ubuntu impish-security main" | sudo tee /etc/apt/sources.list.d/impish-security.list
sudo apt-get update
sudo apt-get install libssl1.1 -y


sudo mkdir -p /home/"$YOUR_USER"/.local/share/Netsparker_Ltd
sudo chown -R "$YOUR_USER" /home/"$YOUR_USER"/.local/share/Netsparker_Ltd
echo STEP 4 ... SUCCESS


sudo apt install -y gconf-service libasound2 libatk1.0-0 libatk-bridge2.0-0 libc6 libcairo2 libcups2 libdbus-1-3 libexpat1 libfontconfig1 libgcc1 libgconf-2-4 libgdk-pixbuf2.0-0 libglib2.0-0 libgtk-3-0 libnspr4 libpango-1.0-0 libpangocairo-1.0-0 libstdc++6 libx11-6 libx11-xcb1 libxcb1 libxcomposite1 libxcursor1 libxdamage1 libxext6 libxfixes3 libxi6 libxrandr2 libxrender1 libxss1 libxtst6 ca-certificates fonts-liberation libappindicator1 libnss3 lsb-release xdg-utils libgdiplus
echo STEP 5 ... SUCCESS


tar xf Invicti_Enterprise_Verifier_Agent.tar
chmod +x .local-chromium/Linux-*/chrome-linux/chrome
echo STEP 6 ... SUCCESS
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