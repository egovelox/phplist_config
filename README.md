# Phplist config

## Run script
```bash
# clone this repo
git clone https://github.com/egovelox/phplist_config.git

cd phplist_config
chmod +x run.sh

# edit the various variables, eg. $SITE_NAME
vim install_phplist.sh

# run the script that will setup nginx etc
./run.sh
```

## Config MySQL
```bash
# use the generated script init_database.sql
sudo mysql_secure_installation 
mysql -uroot -p < init_database.sql 

```
## Config php-fpm permissions, if needed
```bash
sudo vim /etc/php-fpm.d/www.conf
```

Modify the file with :
```
listen = ${VALUE FROM nginx.conf SOCKET PATH: /var/run/...}
listen.owner = nginx
listen.group = nginx
listen.mode = 0660
```

```bash
sudo systemctl restart php-fpm
sudo systemctl restart nginx
```

## Config Nginx SSL with Certbot

Only if needed (should already be done by script above)

```bash
sudo python3 -m venv /opt/certbot/
sudo /opt/certbot/bin/pip install --upgrade pip
sudo /opt/certbot/bin/pip install certbot certbot-nginx
sudo ln -s /opt/certbot/bin/certbot /usr/bin/certbot

sudo certbot run -n --nginx --agree-tos -d "${DOMAIN}" -m "${MAIL}" --redirect

```

## Install Recaptcha PHPList plugin :

#### Documentation 

The plugin requires CommonPlugin to be installed, see [this page](https://resources.phplist.com/plugin/common)
You should be able to install this plugin via the admin UI.

[https://resources.phplist.com/plugin/recaptcha](https://resources.phplist.com/plugin/recaptcha)
[https://github.com/bramley/phplist-plugin-recaptcha](https://github.com/bramley/phplist-plugin-recaptcha)

#### Installation

```bash
wget https://github.com/bramley/phplist-plugin-recaptcha/archive/master.zip
unzip master.zip 
cp -r phplist-plugin-recaptcha-master/plugins/* "${PHP_LIST_DIR}"/admin/plugins/
```

#### Monitoring

[https://www.google.com/recaptcha/admin](https://www.google.com/recaptcha/admin)
