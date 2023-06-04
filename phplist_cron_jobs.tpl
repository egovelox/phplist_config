*/1 * * * * echo "=== $(date)" >> /var/log/phplist_cron/${SITE_NAME} && phplist -pprocessqueue >> /var/log/phplist_cron/${SITE_NAME}_queue_process 2>&1

0 3 * * * echo "=== $(date)" >> /var/log/phplist_cron/${SITE_NAME} && phplist -pprocessbounces >> /var/log/phplist_cron/${SITE_NAME}_bounces 2>&1

0 0 * * * rm /var/log/phplist_cron/${SITE_NAME}_queue_process
0 0 1,15 * * rm /var/log/phplist_cron/${SITE_NAME}_bounces
