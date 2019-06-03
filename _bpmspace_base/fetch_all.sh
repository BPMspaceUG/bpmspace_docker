#!/bin/bash
cd /var/www/html && git fetch --all  && git reset --hard origin/master
chown -R www-data:www-data /var/www/
find /var/www/html -type f -exec chmod 660 {} \;
find /var/www/html -type d -exec chmod 770 {} \;

