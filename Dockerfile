# source file  at: https://github.com/jjonline/docker-php-runtime
# docker image at: https://hub.docker.com/r/jjonline/docker-php-runtime
ARG PHP_VERSION=7.2
FROM php:$PHP_VERSION-fpm-alpine

LABEL Maintainer="JeaYang<jjonline@jjonline.cn>" \
      Description="Nginx & PHP & FPM & Supervisor & Composer based on Alpine Linux support multi PHP version."

# Basic workdir
WORKDIR /srv

# Install php extension supervisor and nginx
RUN apk update && \
	apk add libpng libpng-dev gmp gmp-dev zlib zlib-dev oniguruma oniguruma-dev libjpeg-turbo-dev libpng-dev freetype-dev libzip libzip-dev libxslt libxslt-dev supervisor nginx bash && \
	docker-php-ext-configure gd && \
	yes "" | pecl install redis && \
	yes "" | pecl install xlswriter && \
	docker-php-ext-install -j5 bcmath gd gmp mbstring mysqli pdo pdo_mysql opcache sockets xsl zip exif && \
	docker-php-ext-enable redis xlswriter && \
	rm -rf /var/cache/apk/* && \
	rm -rf /etc/nginx/sites-enabled/* && \
	curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer
