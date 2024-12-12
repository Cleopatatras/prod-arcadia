FROM php:8.2-apache

# Mise à jour et installation des dépendances
RUN apt-get update \
    && apt-get install -y build-essential curl zlib1g-dev g++ git libicu-dev zip libzip-dev \
    libpng-dev libjpeg-dev libwebp-dev libfreetype6-dev libssl-dev pkg-config \
    && docker-php-ext-install intl opcache pdo pdo_mysql exif \
    && pecl install apcu mongodb \
    && docker-php-ext-enable apcu mongodb \
    && docker-php-ext-configure zip \
    && docker-php-ext-install zip \
    && docker-php-ext-configure gd --with-freetype --with-webp --with-jpeg \
    && docker-php-ext-install gd \
    && a2enmod rewrite ssl socache_shmcb \
    && apt-get clean && rm -rf /var/lib/apt/lists/*
# Définir le répertoire de travail
WORKDIR /var/www

RUN chown -R www-data:www-data /var/www
COPY . .

# Installation de Composer
RUN curl -sS https://getcomposer.org/download/2.8.3/composer.phar -o /usr/local/bin/composer && \
    chmod +x /usr/local/bin/composer


RUN rm -rf vendor composer.lock
RUN composer clear-cache
RUN composer install --no-scripts --optimize-autoloader
RUN composer require symfony/runtime --no-scripts

RUN composer dump-autoload
RUN mkdir -p var/cache/prod \
    && mkdir -p var/log
RUN chmod 777 ./var/cache/prod
RUN chmod 777 ./var/log

#exposer le port 80 pour heroku
EXPOSE 80
EXPOSE 443