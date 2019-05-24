FROM php:7.3.5-apache-stretch
RUN docker-php-ext-install pdo_mysql mysqli
RUN docker-php-ext-enable pdo_mysql mysqli
RUN apt-get update && apt-get install -y --no-install-recommends apt-utils
RUN apt-get install -y git
RUN apt-get install -y openssh-client
RUN apt-get install -y wget
RUN apt-get install -y nano
RUN apt-get install -y libicu-dev
RUN apt-get install -y libfreetype6-dev libjpeg62-turbo-dev libpng-dev \
    && docker-php-ext-configure gd --with-freetype-dir=/usr/include/ --with-jpeg-dir=/usr/include/ \
    && docker-php-ext-install -j$(nproc) intl pdo_mysql bcmath mbstring exif gd
RUN a2enmod rewrite