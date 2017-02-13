
########################################################################
# INTENDED FOR DEVELOPER ONLY! DO NOT USE IN PRODUCTION!
# DON'T RUN THIS AS ROOT! RUN WITH SUDO! IT USES THE CURRENT LOGGED 
# SERVER PORT (you need to choose a free unused port for each server!)
########################################################################

FROM ubuntu:16.04
MAINTAINER Pablo Sanchez <psanchez@xpreso.com>

# UBUNTU BASIC SETUP
RUN echo 'debconf debconf/frontend select Noninteractive' | debconf-set-selections
RUN echo "#!/bin/sh\nexit 0" > /usr/sbin/policy-rc.d
RUN apt-get update -y --allow-unauthenticated
RUN apt-get upgrade -y --allow-unauthenticated
RUN apt-get install -y --allow-unauthenticated software-properties-common \
       python-software-properties supervisor build-essential git curl

# NOW, MY STUFF

# ADD PostgreSQL 9.5 with PostGis 2
RUN apt-get install -y --allow-unauthenticated \
        postgresql-9.5-postgis \
        postgresql-9.5-postgis-scripts \
        postgresql-contrib-9.5 \
        postgis

USER postgres

RUN    /etc/init.d/postgresql start && sleep 3 &&\
    psql --command "CREATE USER xpreso WITH SUPERUSER PASSWORD 'xpreso';" && \
    createdb -O xpreso xpreso && \
    psql --dbname="xpreso" --command " \
    CREATE EXTENSION IF NOT EXISTS postgis; \
    CREATE EXTENSION IF NOT EXISTS postgis_topology; \
    CREATE EXTENSION IF NOT EXISTS fuzzystrmatch; \
    CREATE EXTENSION IF NOT EXISTS postgis_tiger_geocoder;"

RUN echo "host all  all    0.0.0.0/0  md5" >> /etc/postgresql/9.5/main/pg_hba.conf
RUN echo "listen_addresses='*'" >> /etc/postgresql/9.5/main/postgresql.conf

USER root

# ADD PHP 7 TO UBUNTU - Repository needed for it on Ubuuntu 14.04
RUN add-apt-repository ppa:ondrej/php
RUN apt-get update
RUN apt-get install -y --allow-unauthenticated libgeos-dev libpcre3 libpcre3-dev \
        php7.0 php7.0-mcrypt php7.0-mbstring php7.0-dev php7.0-json \
        php7.0-bcmath php7.0-fpm php7.0-gd php7.0-geoip php7.0-intl \
        php7.0-xml php7.0-curl php7.0-pgsql php7.0-sqlite3 

# SETUP PHP 7 BASICS - Minimum setups required
RUN touch /etc/php/7.0/mods-available/mycfg.ini
RUN echo 'date.timezone = Europe/London' >> /etc/php/7.0/mods-available/mycfg.ini
RUN echo 'always_populate_raw_post_data = -1' >> /etc/php/7.0/mods-available/mycfg.ini
RUN ln -s /etc/php/7.0/mods-available/mycfg.ini /etc/php/7.0/cli/conf.d/20-mycfg.ini
RUN ln -s /etc/php/7.0/mods-available/mycfg.ini /etc/php/7.0/fpm/conf.d/20-mycfg.ini
RUN sed -i -e 's/\;cgi.fix_pathinfo=1/cgi.fix_pathinfo=0/g'  /etc/php/7.0/fpm/php.ini 

# ADD PHP-GEO
RUN git clone https://git.osgeo.org/gogs/geos/php-geos.git
RUN cd php-geos && ./autogen.sh && ./configure && make install
RUN echo 'extension=geos.so' > /etc/php/7.0/mods-available/geos.ini
RUN ln -s /etc/php/7.0/mods-available/geos.ini /etc/php/7.0/cli/conf.d/
RUN ln -s /etc/php/7.0/mods-available/geos.ini /etc/php/7.0/fpm/conf.d/

# ADD TIMEZONEDB - Fix the outdated timezone db without forcing PHP to be upgraded
RUN pecl install timezonedb
RUN echo 'extension=timezonedb.so' > /etc/php/7.0/mods-available/timezonedb.ini
RUN ln -s /etc/php/7.0/mods-available/timezonedb.ini /etc/php/7.0/cli/conf.d/
RUN ln -s /etc/php/7.0/mods-available/timezonedb.ini /etc/php/7.0/fpm/conf.d/

# ADD XDEBUG TO THE CONTAINER - Allow developers to debug the container remotely
RUN apt-get install -y --allow-unauthenticated php7.0-xdebug
RUN echo 'xdebug.remote_enable=1' >> /etc/php/7.0/cli/conf.d/20-xdebug.ini
RUN echo 'xdebug.remote_handler=dbgp' >> /etc/php/7.0/cli/conf.d/20-xdebug.ini
RUN echo 'xdebug.remote_mode=req' >> /etc/php/7.0/cli/conf.d/20-xdebug.ini
RUN echo 'xdebug.remote_host=127.0.0.1' >> /etc/php/7.0/cli/conf.d/20-xdebug.ini
RUN echo 'xdebug.remote_port=9000' >> /etc/php/7.0/cli/conf.d/20-xdebug.ini

# ADD COMPOSER TO THE CONTAINER - just in case you need it...
RUN curl https://getcomposer.org/installer | php
RUN mv composer.phar /usr/bin/composer

# ADD NGINX
RUN apt-get update
RUN apt-get install -y --allow-unauthenticated nginx

# SETUP NGINX
RUN echo "env APP_HOST_NAME;\n$(cat /etc/nginx/nginx.conf)" > /etc/nginx/nginx.conf

RUN echo 'server {\n\
    server_name $APP_HOST_NAME;\n\
    listen $APP_HOST_PORT default_server;\n\
    listen [::]:$APP_HOST_PORT default_server;\n\
    root /var/www/html/public;\n\
    proxy_buffering off;\n\
\n\
    index index.php index.html index.htm index.nginx-debian.html;\n\
\n\
    location / {\n\
        try_files $uri $uri/ /index.php?$args;\n\
    }\n\
\n\
    location ~ \.php$ {\n\
    try_files $uri $uri/ =404;\n\
    fastcgi_split_path_info ^(.+\.php)(/.+)$;\n\
    fastcgi_pass unix:/run/php/php7.0-fpm.sock;\n\
    fastcgi_index index.php;\n\
    fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name;\n\
    include fastcgi_params;\n\
  }\n\
}' > /etc/nginx/sites-available/default

# CLEAN
RUN apt-get clean

# CREATE START SCRIPT
COPY ./start.sh /start.sh
RUN chmod 777 /start.sh

ENTRYPOINT /start.sh
