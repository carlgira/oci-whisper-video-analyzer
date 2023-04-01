#!/bin/bash

main_function() {
USER='opc'
sudo dnf -y install wget git python3 python3-pip python3-venv unzip ffmpeg jq

# Resize root partition
printf "fix\n" | parted ---pretend-input-tty /dev/sda print
VALUE=$(printf "unit s\nprint\n" | parted ---pretend-input-tty /dev/sda |  grep lvm | awk '{print $2}' | rev | cut -c2- | rev)
printf "rm 3\nIgnore\n" | parted ---pretend-input-tty /dev/sda
printf "unit s\nmkpart\n/dev/sda3\n\n$VALUE\n100%%\n" | parted ---pretend-input-tty /dev/sda
pvresize /dev/sda3
pvs
vgs
lvextend -l +100%FREE /dev/mapper/ocivolume-root
xfs_growfs -d /

dnf install wget git python3.9 python39-devel.x86_64 libsndfile -y

# Install ffmpeg
dnf -y install https://download.fedoraproject.org/pub/epel/epel-release-latest-8.noarch.rpm
dnf install -y https://download1.rpmfusion.org/free/el/rpmfusion-free-release-8.noarch.rpm
dnf install -y https://download1.rpmfusion.org/nonfree/el/rpmfusion-nonfree-release-8.noarch.rpm
dnf config-manager --set-enabled ol8_codeready_builder
dnf -y install ffmpeg


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
