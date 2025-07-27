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

# to renew, use: 
# ( you can add --force-renewal )
# sudo certbot certonly -n --nginx --agree-tos -d "${DOMAIN}" -m "${MAIL}" --redirect

# to read the expiration-date, use:
# sudo certbot certificates
# or use
# sudo openssl x509 -dates -noout -in /etc/letsencrypt/live/my.domain.com-000x/fullchain.pem
```

## Configure cron

If needed you can list current cron jobs with :
```bash
sudo crontab -l
```

We have crons for PHPList, 
and we can have a cron for certbot renewal, running everyday at 00:00
( though renewal will not happen everyday, but only when the cert is due for renewal )

```bash
0 0 * * * certbot certonly -n --nginx --agree-tos -d "${DOMAIN}" -m "${MAIL}" --redirect
```

### Note

if you see an error in `/var/log/letsencrypt/letsencrypt.log`

```
The nginx plugin is not working; there may be problems with your existing configuration.
The error was: NoInstallationError("Could not find a usable 'nginx' binary. 
Ensure nginx exists, the binary is executable, and your PATH is set correctly.")
```
fix it using [certbot documentation](https://eff-certbot.readthedocs.io/en/stable/using.html#certbot-command-line-options)
and this [stackoverflow post](https://stackoverflow.com/questions/67049573/could-not-find-a-usable-nginx-binary-ensure-nginx-exists-the-binary-is-execu)  

The cron command would then be :

```bash
0 0 * * * certbot certonly -n --nginx --nginx-ctl /usr/sbin/nginx --nginx-server-root /etc/nginx --agree-tos -d "${DOMAIN}" -m "${MAIL}" --redirect
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

#### Recaptcha Monitoring

[https://www.google.com/recaptcha/admin](https://www.google.com/recaptcha/admin)

#### Last steps

You might want to customize phplist (e.g subscribe pages) ?

See post_config_resources folder.

If needed, disable credits text :

in ``/admin/sendemaillib.php`` you should set ``$html[‘signature’] = "";``
