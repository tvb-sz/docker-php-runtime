# source file  at: https://github.com/tvb-sz/docker-php-runtime
# docker image at: https://hub.docker.com/r/nmgsz/docker-php-runtime

# define php version args
# Be used to base Image need before FROM
# if args used after FROM, should repeat define
ARG phpVersion='7.2'

FROM php:${phpVersion}-fpm-alpine

# define install Redis extension src
ARG extRedisSrc='redis'
# define php extension GD build Option
ARG gdOpt=''
# define install or not install php extension xlswriter
ARG installExtMysql='mysql'

LABEL Maintainer="team tvb sz<nmg-sz@tvb.com>" \
      Description="Nginx & PHP & FPM & Supervisor & Composer based on Alpine Linux support multi PHP version."

# Basic workdir
WORKDIR /srv

    # ① install lib and software
RUN apk update && \
    apk add libpng libpng-dev \
    gmp gmp-dev \
    zlib zlib-dev \
    icu icu-dev \
    oniguruma oniguruma-dev \
    libjpeg-turbo-dev libpng-dev \
    freetype-dev libzip libzip-dev \
    libxslt libxslt-dev \
    libxpm libxpm-dev \
    libvpx libvpx-dev \
    libwebp libwebp-dev \
    linux-headers \
    supervisor nginx bash && \
    # ② configure and install pecl extension
    docker-php-ext-configure gd ${gdOpt} && \
    yes "" | pecl install ${extRedisSrc} && \
    # ③ install built-in extension and enable some ext extension
    docker-php-ext-install -j5 pcntl intl soap bcmath gd gmp mbstring ${installExtMysql} mysqli pdo pdo_mysql opcache sockets xsl zip exif && \
    docker-php-ext-enable redis && \
    # ④ install composer2
    curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer && \
    # ⑤ clean
    rm -rf /var/cache/apk/* && rm -rf /etc/nginx/sites-enabled/*
