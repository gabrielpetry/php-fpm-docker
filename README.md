# PHP-FPM Docker

A multi-version php-fpm images listening on TCP port to easy integrate on webservers like nginx or httpd.

## Features
 - *Multi Version:* All supported PHP versions available
 - *Fast!* does not come with a builtin webserver, so less overhead and better response times! =D
 - *Up-to-Date:* Images auto-updated every week
 - *Secure:* Cron job auto installed into containers to apply security updates every night;
 - *Green light to send emails:* PHP mail() working like a charm;
 - *Schedule jobs:* cron command installed;

## Ready-to-go images
Check out on [Docker Hub](https://hub.docker.com/r/fbraz3/php-fpm/)

Source code on [GitHub](https://github.com/fbraz3/php-fpm-docker)

## Getting started

First of all, create a network called `dockernet` using range `192.168.0.0/24` to get emails working over ssmtp email proxy.
```
# docker network create --subnet=192.168.0.0/24 dockernet
```
edit `/etc/postfix/main.cf` and add 192.168.0.0/24 on `mynetworks` params.
```
mynetworks = 127.0.0.0/8 192.168.0.0/24 [::ffff:127.0.0.0]/104 [::1]/128
```
Restart postfix
```
systemctl restart postfix
```

## Using this image
Best using docker-compose to start this image.
```docker-compose
version: '3'
services:
    web:
        image: gabrielpetry/nginx
        restart: always
        env_file:
            - .env
        volumes:
            - ./Laravel:/var/www/html
        ports:
            - 80:80
        links:
            - php
        depends_on:
            - php
    php:
        image: gabrielpetry/php-fpm
        restart: always
        volumes:
            - ./Laravel:/app
        env_file:
            - .env
```

Create a .env file
```env
PHP_DISPLAY_ERRORS=On
NGINX_ROOT=\/public
```

**Note**: Dont forget to replace `/my/app/root/` to your real app root! 

## Configuring nginx
We need to set fastcgi server to `tcp port 1780` like below
```
location ~ \.php$ {
        include              fastcgi_params;
        fastcgi_pass         127.0.0.1:1780;
        fastcgi_index        index.php;
        fastcgi_param        DOCUMENT_ROOT    /app/public;
        fastcgi_param        SCRIPT_FILENAME  /app/public$fastcgi_script_name;
    }
```

## Cronjob

System reads `/cronfile` file and installs using `cron`.

To use it just add your commands to a single file and bind it to `/cronfile` as follows.

```
  [...]
     volumes:
        - /my/app/root/:/app
        - /my/cronfile:/cronfile
  [...]
```
