#!/bin/bash

main_function() {
USER='opc'
apt-get update -y
apt-get install wget git python3 python3-pip python3-venv unzip ffmpeg jq -y

APP='smart-video-analizer'
APP_DIR="/home/$USER/$APP"

cat <<EOT > /etc/systemd/system/$APP.service
[Unit]
Description=Instance to serve $APP
After=network.target
[Service]
User=$USER
Group=www-data
WorkingDirectory=$APP_DIR
ExecStart=/bin/bash $APP_DIR/start.sh
[Install]
WantedBy=multi-user.target
EOT

su -c "mkdir -p $APP_DIR" $USER
su -c "wget -O $APP_DIR/app.py https://raw.githubusercontent.com/carlgira/oci-whisper-video-analyzer/main/app/app.py" $USER
su -c "wget -O $APP_DIR/requirements.txt https://raw.githubusercontent.com/carlgira/oci-whisper-video-analyzer/main/app/requirements.txt" $USER
su -c "wget -O /home/$USER/setup-app.sh https://raw.githubusercontent.com/carlgira/oci-whisper-video-analyzer/main/setup-app.sh" $USER
su -c "source /home/$USER/setup-app.sh" $USER

systemctl daemon-reload
systemctl enable $APP
systemctl start $APP
}

main_function 2>&1 >> /var/log/startup.log
