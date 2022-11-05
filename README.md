# docker-php-runtime

* User: `www-data`
* php
* nginx
* supervisor
* php-fpm

# ENV

* `php -m`

````

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
