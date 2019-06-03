FROM php:7.3.5-apache-stretch
RUN apt-get update
RUN apt-get install -y wget
RUN apt-get install -y nano
copy class-auth.php /var/www/html/
copy index.php /var/www/html/
