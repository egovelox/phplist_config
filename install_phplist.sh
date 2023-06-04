#!/bin/bash

set -e
set -x

CLONED_DIR="${HOME}/phplist_config"
INSTALL_DIR="${HOME}/fisdn/PROG"

export SITE_NAME=""
export SMTP_USER=""
export SMTP_PASSWORD=""
export DATABASE_PASSWORD=""
export SMTP_MAILER_HOST=""
export POP_MAILER_HOST=""

## php was installed, so /var/www should exist
export SOURCE_DIR="/var/www/${SITE_NAME}"
export NGINX_DIR="/etc/nginx"

## Download and extract phplist
mkdir -p $INSTALL_DIR
cd $INSTALL_DIR

VER="3.6.12"
wget https://sourceforge.net/projects/phplist/files/phplist/${VER}/phplist-${VER}.tgz

tar -xvf "phplist-${VER}.tgz"

## move phplist in $SOURCE_DIR
sudo mkdir "$SOURCE_DIR"

sudo cp -r "${INSTALL_DIR}/phplist-${VER}/public_html/lists/"* $SOURCE_DIR

## Setup and replace the config.php file
envsubst '${SMTP_USER},${SMTP_PASSWORD},${DATABASE_PASSWORD},${SMTP_MAILER_HOST},${POP_MAILER_HOST}' < "${CLONED_DIR}/config.php.tpl" > "${CLONED_DIR}/config.php"
sudo cp "${CLONED_DIR}/config.php" "${SOURCE_DIR}/config/config.php"
# Setup correct rights for nginx
sudo chown -R $USER:nginx $SOURCE_DIR

(
cat <<EOF
CREATE DATABASE phplist;
GRANT ALL PRIVILEGES ON phplist.* to 'phplist'@'localhost' IDENTIFIED BY '$DATABASE_PASSWORD';
FLUSH PRIVILEGES;
EOF
) > "${CLONED_DIR}/init_database.sql"

## Setup and replace the nginx.conf file
envsubst '${SITE_NAME}' < "${CLONED_DIR}/nginx.conf.tpl" > "${CLONED_DIR}/nginx.conf"
sudo cp "${CLONED_DIR}/nginx.conf" "${NGINX_DIR}/nginx.conf"
sudo nginx -t

## use certbot to create a certificate and reference it to nginx.conf
sudo certbot run -n --nginx --agree-tos -d $SITE_NAME -m $SMTP_USER --redirect

echo "Done with nginx.conf"
echo "Restarting nginx..."
sudo systemctl restart nginx

## prepare a shell script to be used in cron tasks

envsubst '${SITE_NAME}' < "${CLONED_DIR}/phplist.tpl" > "${CLONED_DIR}/phplist"
sudo cp "${CLONED_DIR}/phplist" /usr/local/bin/phplist
chmod 755 /usr/local/bin/phplist

# prepare a folder for the phplist cron jobs to write their logs
#
sudo mkdir /var/log/phplist_cron

envsubst '${SITE_NAME}' < "${CLONED_DIR}/phplist_cron_jobs.tpl" > "${CLONED_DIR}/phplist_cron_jobs"
crontab -l > "${CLONED_DIR}/current_cron"
cat "${CLONED_DIR}/phplist_cron_jobs" >> "${CLONED_DIR}/current_cron"
sudo crontab "${CLONED_DIR}/current_cron"

echo "All done ! PHPlist was successfully installed."
echo "You can check https://${SITE_NAME} before you configure DB"
echo "You can check crontab -l before you configure DB"

