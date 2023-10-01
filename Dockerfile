FROM php:7.4-apache
RUN apt-get update
WORKDIR /var/www/html
COPY . /var/www/html
EXPOSE 80
CMD ["apache2-foreground"]