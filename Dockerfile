FROM php:7.4-apache

COPY ./php.ini /usr/local/etc/php/conf.d/php.ini
COPY ./vhost.conf /etc/apache2/conf-enabled/vhost.conf
COPY ./ssmtp.conf /etc/ssmtp/ssmtp.conf
ARG TZ=Asia/Tokyo

RUN apt-get update \
  && apt-get install -y libzip-dev \
  && apt-get install -y libonig-dev \
  && apt-get install -y zlib1g-dev \
  && apt-get install -y zip unzip

RUN docker-php-ext-install pdo_mysql mysqli mbstring \
  && docker-php-ext-enable mysqli \
  && a2enmod rewrite

# install GD & exif
RUN apt-get update && apt-get install -y \
        libfreetype6-dev \
        libjpeg62-turbo-dev \
        libmcrypt-dev \
        libpng-dev \
    && docker-php-ext-configure gd --with-freetype --with-jpeg \
    && docker-php-ext-install -j$(nproc) gd exif

RUN curl -sS https://getcomposer.org/installer | php \
  && mv composer.phar /usr/local/bin/composer \
  && chmod +x /usr/local/bin/composer

ENV COMPOSER_ALLOW_SUPERUSER 1
ENV COMPOSER_HOME /composer
ENV PATH $PATH:/composer/vendor/bin

WORKDIR /var/www/html
