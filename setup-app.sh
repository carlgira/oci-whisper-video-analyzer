USER='opc'
HOME_DIR=$(eval echo ~$USER)
APP='smart-video-analizer'
APP_DIR="/home/$USER/$APP"


setup_app(){

python3.9 -m venv $APP_DIR/.venv
source $APP_DIR/.venv/bin/activate
pip install --upgrade pip
pip install -r $APP_DIR/requirements.txt

cat <<EOT > $APP_DIR/start.sh
$VARS
export GRADIO_SERVER_PORT=8000
$APP_DIR/.venv/bin/python $APP_DIR/app.py
EOT

}

setup_app 2>&1 > /tmp/startup.log