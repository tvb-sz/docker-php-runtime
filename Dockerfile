# source file  at: https://github.com/tvb-sz/docker-php-runtime
# docker image at: https://hub.docker.com/r/nmgsz/docker-php-runtime

ARG PHP_VERSION=7.2
# define install Redis extension src
ARG EXTENSION_REDIS_SRC=redis
# define php extension GD build Option
ARG GD_OPT=''
# define install or not install php extension xlswriter
ARG INSTALL_MYSQL_EXTENSION='mysql'
# define install or not install php extension xlswriter
ARG INSTALL_XLSWRITER_CMD='yes "" | pecl install xlswriter'
# define enable php extension
ARG ENABLE_EXTENSION_LIST='redis xlswriter'

FROM php:$PHP_VERSION-fpm-alpine

LABEL Maintainer="team tvb sz<nmg-sz@tvb.com>" \
      Description="Nginx & PHP & FPM & Supervisor & Composer based on Alpine Linux support multi PHP version."

# Basic workdir
WORKDIR /srv

# Install php extension supervisor and nginx
RUN apk update && \
	apk add libpng libpng-dev \
    gmp gmp-dev \
    zlib zlib-dev  \
    oniguruma oniguruma-dev  \
    libjpeg-turbo-dev libpng-dev  \
    freetype-dev libzip libzip-dev  \
    libxslt libxslt-dev \
    libxpm libxpm-dev \
    libvpx libvpx-dev \
    libwebp libwebp-dev \
    supervisor nginx bash && \
	docker-php-ext-configure gd $GD_OPT && \
	yes "" | pecl install $EXTENSION_REDIS_SRC && \
	$INSTALL_XLSWRITER_CMD && \
	docker-php-ext-install -j5 pcntl bcmath gd gmp  \
    mbstring mysqli $INSTALL_MYSQL_EXTENSION  \
    pdo pdo_mysql opcache sockets xsl zip exif && \
	docker-php-ext-enable $ENABLE_EXTENSION_LIST && \
	rm -rf /var/cache/apk/* && \
	rm -rf /etc/nginx/sites-enabled/* && \
	curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer
