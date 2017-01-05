Xpreso Developer Environment
============================

What is included?
-----------------

* Ubuntu 14.04
* Nginx
* PHP-FPM 7.0

Who can use it?
-----------------

Anyone who needs to develop on PHP 7 using Nginx

How to use it?
-----------------

        git clone https://github.com/XpresoTeam/docker_dev_php
        cd docker_dev_php
        sudo docker build ./ --tag xpreso_dev:0.1 

Buildtime takes aprox. 2m30s.

Now, to run the container the first time, you need to inform the local path for the Nginx folder
(/var/www/html), thhe APP_HOST_NAME, and APP_HOST_PORT you will use. map the same port inside
to the outside. You will be able to access your server using the URL:

http://{APP_HOST_NAME}:{APP_HOST_PORT}

        sudo docker run \
            --name projectname\
            -v ~/Projects/projectname:/var/www/html \
            -e APP_HOST_NAME='dockertest' \
            -e APP_HOST_PORT='8000' \
            -p 8000:8000 \
            -e USERID=`id -u $USER` \
            -e USERNAME=$USER \
            -d xpreso_dev:0.1

REMEMBER: You need to add the hostnames to your /etc/hosts file on your operating system


Disclaimer
-----------------

INTENDED FOR DEVELOPMENT USE ONLY! DO NOT USE IT IN PRODUCTION!

DON'T RUN THIS AS ROOT! RUN WITH SUDO! IT USES THE CURRENT LOGGED USER FOR FIX HOST DISK ACCESS PERMISSIONS 

USE BASH AS YOUR SHELL TO RUN THE COMMAND!

SERVER PORT - you need to choose a free unused port for each hostname!

