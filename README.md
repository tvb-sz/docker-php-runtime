# docker-php-runtime

* source file at: [https://github.com/tvb-sz/docker-php-runtime](https://github.com/tvb-sz/docker-php-runtime)
* docker image at: [https://hub.docker.com/r/nmgsz/docker-php-runtime](https://hub.docker.com/r/nmgsz/docker-php-runtime)

Support multi arch and some mainstream version for php, added nginx and supervisor and preset installed composer2.

* User: `www-data`
* php: 5.6/7.2/7.4/8.0/8.1/8.2
* nginx
* supervisor
* php-fpm

## Image Info

All image base on official PHP Image with tag as `php:x.y.z-fpm-alpine`「[link](https://hub.docker.com/_/php/tags?page=1&name=-alpine)」,
That is, official PHP base on the latest alpine system when this php is released,
and the full version number of php is the latest repair version of the current subversion.

You can see our [Dockerfile](./Dockerfile) get more detail

| Image Tag                | PHP Version   | Alpine version | Remark               |
|--------------------------|---------------|----------------|----------------------|
| php5.6-fpm-alpine        | Latest PHP5.6 | 3.8            | recommended to use   |
| php5.6-fpm-alpine-vx.y.z | Latest PHP5.6 | 3.8            | with git release tag |
| php7.2-fpm-alpine        | Latest PHP7.2 | 3.12           | recommended to use   |
| php7.2-fpm-alpine-vx.y.z | Latest PHP7.2 | 3.12           | with git release tag |
| php7.4-fpm-alpine        | Latest PHP7.4 | 3.16           | recommended to use   |
| php7.4-fpm-alpine-vx.y.z | Latest PHP7.4 | 3.16           | with git release tag |
| php8.0-fpm-alpine        | Latest PHP8.0 | 3.16           | recommended to use   |
| php8.0-fpm-alpine-vx.y.z | Latest PHP8.0 | 3.16           | with git release tag |
| php8.1-fpm-alpine        | Latest PHP8.1 | 3.17           | recommended to use   |
| php8.1-fpm-alpine-vx.y.z | Latest PHP8.1 | 3.17           | with git release tag |
| php8.2-fpm-alpine        | Latest PHP8.2 | 3.17           | recommended to use   |
| php8.2-fpm-alpine-vx.y.z | Latest PHP8.2 | 3.17           | with git release tag |

## Guidance

For your Dockerfile

### nginx

You should copy and fill your nginx config file to `/etc/nginx/nginx.conf`

Configuration file separation can be achieved using nginx `include` directive. Such as `include /etc/nginx/conf.d/*.conf;`

**Recommend start nginx command is:**
````
nginx -g 'daemon off;' -c /etc/nginx/nginx.conf
````
you can use shell script or preset supervisor manage it.

**Special reminder: users running nginx please use the preset user `www-data`**

In nginx config is that:
````
user www-data;
````

### PHP

No default `php.ini` config file support,
but example file can find at:

* `/usr/local/etc/php/php.ini-development`
* `/usr/local/etc/php/php.ini-production`

### PHP-FPM

You can copy and fill your php-fpm config file to `/usr/local/etc/php-fpm.conf`, or you can use this default php-fpm config file simply start it.

About default php-fpm config file
* contain include dir `/usr/local/etc/php-fpm.d/`
* contain `/usr/local/etc/php-fpm.d/docker.conf`
* contain `/usr/local/etc/php-fpm.d/www.conf`

**Special reminder: if you copy and file your customer php-fpm config file, please attention that users running php-fpm should be used the preset user `www-data`**

In php-fpm config is that:
````
# file at /usr/local/etc/php-fpm.d/www.conf
user = www-data
group = www-data
````

**Recommend start php-fpm command is:**
````
php-fpm -F -O --fpm-config=/usr/local/etc/php-fpm.conf
````
you can use shell script or preset supervisor manage it.

### Supervisord

None default supervisord config file are supported.

You can write your supervisord config file then copy and fill any path you like.

**Recommend start Supervisord command is:**
````
supervisord -n -c "/__YOUR__CONFIG_PATH__/__YOUR__CONFIG__.conf"
````
you can use shell script manage it.

## Practical advice

* use supervisord manage your daemon or process
* use `/bin/bash` or `/bin/sh` write your shell manager script
* use Dockerfile `ENTRYPOINT` directive, it can start and run different process

Example for a Laravel application

File `docker/Dockerfile`
````
FROM nmgsz/docker-php-runtime:7.2-fpm-alpine

# Basic workdir
WORKDIR /srv/www

# Configure CONF
COPY docker/config/nginx.conf /etc/nginx/nginx.conf
COPY docker/config/php.ini /usr/local/etc/php/php.ini

# Confiure Supervisor
COPY docker/supervisord/ /opt/supervisord
RUN dos2unix /opt/supervisord/start.sh && chmod 755 /opt/supervisord/start.sh

# Copy PHP project files, composer install, artisan init
COPY ./ /srv/www
#RUN composer update --no-dev && \
#    composer clearcache && \
#    php artisan config:cache && \
#    php artisan route:cache && \
#    php artisan view:cache && \
#    rm -rf .env && \
#    chown -R www-data:www-data /srv/www
RUN chown -R www-data:www-data /srv/www

# Expose the port nginx is reachable on
EXPOSE 8080

ENTRYPOINT ["/opt/supervisord/start.sh"]
````

File `docker/supervisord/start.sh`
````
#!/bin/sh

# use docker run args specify your supervisord endpoint config file
# you can start and run different process
SERVICE_NAME=$1

# ----------------------------------------------------------------------
# Start supervisord
# ----------------------------------------------------------------------
echo "Starting $SERVICE_NAME"
/usr/bin/supervisord -n -c "/opt/supervisord/$SERVICE_NAME.conf"
````

File `docker/supervisord/www.conf`
````
[supervisord]
nodaemon=true
logfile=/dev/stdout
logfile_maxbytes=0
pidfile=/tmp/supervisord.pid
stdout_logfile=/dev/stdout
stdout_logfile_maxbytes=0
user=root

[rpcinterface:supervisor]
supervisor.rpcinterface_factory=supervisor.rpcinterface:make_main_rpcinterface

[supervisorctl]
serverurl=unix:///tmp/supervisor.sock ; use a unix:// URL  for a unix socket

# [inet_http_server]
# port = :8080
# username = user
# password = web-manage-supervisord-pwd

[program:php-fpm]
command=php-fpm -F -O --fpm-config=/usr/local/etc/php-fpm.conf
stdout_logfile=/dev/stdout
stdout_logfile_maxbytes=0
stderr_logfile=/dev/stderr
stderr_logfile_maxbytes=0
autorestart=false
startretries=0

[program:nginx]
command=nginx -g 'daemon off;' -c /etc/nginx/nginx.conf
stdout_logfile=/dev/stdout
stdout_logfile_maxbytes=0
stderr_logfile=/dev/stderr
stderr_logfile_maxbytes=0
autorestart=false
startretries=0
````

File `docker/supervisord/queue.conf`
````
[supervisord]
nodaemon=true
logfile=/dev/stdout
logfile_maxbytes=0
pidfile=/tmp/supervisord.pid
stdout_logfile=/dev/stdout
stdout_logfile_maxbytes=0
user=root

[rpcinterface:supervisor]
supervisor.rpcinterface_factory=supervisor.rpcinterface:make_main_rpcinterface

[supervisorctl]
serverurl=unix:///tmp/supervisor.sock ; use a unix:// URL  for a unix socket

# [inet_http_server]
# port = :8080
# username = user
# password = web-manage-supervisord-pwd

# Alert note HERE
# replace --your-laravel-queue-daemon-- to your laraval queue name
[program:--your-laravel-queue-daemon--]
process_name=%(program_name)s_%(process_num)02d
command=php /srv/www/artisan queue:work --queue=--your-laravel-queue-daemon-- --timeout=120 --tries=3
directory=/srv/www
autorestart=true
startsecs=3
startretries=3
redirect_stderr=false
stdout_logfile=NONE
stderr_logfile=NONE
user=www-data
priority=999
numprocs=1

# HERE can add more laravel Queue process
# ...
````

File `docker/supervisord/scheduler.conf`
````
[supervisord]
nodaemon=true
logfile=/dev/stdout
logfile_maxbytes=0
pidfile=/tmp/supervisord.pid
stdout_logfile=/dev/stdout
stdout_logfile_maxbytes=0
user=root

[rpcinterface:supervisor]
supervisor.rpcinterface_factory=supervisor.rpcinterface:make_main_rpcinterface

[supervisorctl]
serverurl=unix:///tmp/supervisor.sock ; use a unix:// URL  for a unix socket

# [inet_http_server]
# port = :8080
# username = user
# password = web-manage-supervisord-pwd

# scheduler service for time tick execute laravel crontab task
[program:laravel-scheduler]
process_name=%(program_name)s_%(process_num)02d
command=/bin/sh -c "while [ true ]; do (php /srv/www/artisan schedule:run --verbose --no-interaction &); sleep 60; done"
autostart=true
autorestart=true
numprocs=1
user=www-data
redirect_stderr=true
````

> You should complete your nginx config for `docker/config/nginx.conf` and php config for `docker/config/php.ini`, this example ignored.

Then build your docker image like:
````
docker build -t xxxImage -f docker/Dockerfile .
````

Start just http serve like:
````
docker run -v xxx:xxx -p xxx:8080 xxxImage www
````

Start just queue serve like:
````
docker run -v xxx:xxx xxxImage queue
````

Start just scheduler serve like:
````
docker run -v xxx:xxx xxxImage scheduler
````

> **Be aware that replace placeholder for path port or name to your real value.**

## ENV

* `php -m`

````
[PHP Modules]
bcmath
Core
ctype
curl
date
dom
exif
fileinfo
filter
ftp
gd
gmp
hash
iconv
json
libxml
mbstring
mysqli
mysqlnd
openssl
pcntl
pcre
PDO
pdo_mysql
pdo_sqlite
Phar
posix
readline
redis
Reflection
session
SimpleXML
sockets
sodium
SPL
sqlite3
standard
tokenizer
xml
xmlreader
xmlwriter
xsl
Zend OPcache
zip
zlib

[Zend Modules]
Zend OPcache
````

* `php --ini`

````
Configuration File (php.ini) Path: /usr/local/etc/php
Loaded Configuration File:         (none)
Scan for additional .ini files in: /usr/local/etc/php/conf.d
Additional .ini files parsed:
/usr/local/etc/php/conf.d/docker-php-ext-gd.ini,
/usr/local/etc/php/conf.d/docker-php-ext-mysqli.ini,
/usr/local/etc/php/conf.d/docker-php-ext-opcache.ini,
/usr/local/etc/php/conf.d/docker-php-ext-pdo_mysql.ini,
/usr/local/etc/php/conf.d/docker-php-ext-redis.ini,
/usr/local/etc/php/conf.d/docker-php-ext-sockets.ini,
/usr/local/etc/php/conf.d/docker-php-ext-sodium.ini,
/usr/local/etc/php/conf.d/docker-php-ext-zip.ini
````

> none default `php.ini` file, you can copy your ini config at `/usr/local/etc/php/php.ini`

* php-fpm config

```
/usr/local/etc/
/usr/local/etc/php-fpm.conf
```

* `which nginx`

```
/usr/sbin/nginx
```

* nginx config
````
/etc/nginx
/etc/nginx/nginx.conf
````

## composer

preset composer2 at
````
/usr/local/bin/composer
````

you can run composer command without prefix `/usr/local/bin/`, such as `composer update --no-dev`
