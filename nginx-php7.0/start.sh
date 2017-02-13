#!/bin/bash
# SETUP PHP-FPM AND NGINX - Required to correct permissions
echo 'security.limit_extensions = ' | tee --append /etc/php/7.0/fpm/pool.d/www.conf 
sed -i -e "s/listen.owner = www-data/listen.owner = $USERNAME/g" /etc/php/7.0/fpm/pool.d/www.conf 
sed -i -e "s/listen.group = www-data/listen.group = $USERNAME/g" /etc/php/7.0/fpm/pool.d/www.conf 
sed -i -e "s/user = www-data/user = $USERNAME/g" /etc/php/7.0/fpm/pool.d/www.conf 
sed -i -e "s/group = www-data/group = $USERNAME/g" /etc/php/7.0/fpm/pool.d/www.conf 
sed -i -e "s/user www-data/user $USERNAME/g" /etc/nginx/nginx.conf 
rm -f /etc/nginx/sites-enabled/* 
cp /etc/nginx/sites-available/default /etc/nginx/sites-enabled/$APP_HOST_NAME 
sed -i -e "s/\$APP_HOST_PORT/$APP_HOST_PORT/g" /etc/nginx/sites-enabled/$APP_HOST_NAME 
sed -i -e "s/\$APP_HOST_NAME/$APP_HOST_NAME/g" /etc/nginx/sites-enabled/$APP_HOST_NAME 
# ADD USER 
id -u $USERNAME &>/dev/null || useradd -u $USERID $USERNAME  

set -e

/usr/sbin/php-fpm7.0 
/usr/sbin/nginx 

tail -f /dev/null