FROM php:8.0.3-apache-buster

RUN apt-get update && \
    apt-get install -y \
        git \
        libonig-dev \
        libpng-dev \
        libzip-dev \
        supervisor \
        vim \
        zlib1g-dev

RUN docker-php-ext-install mbstring zip gd bcmath mysqli pdo pdo_mysql

RUN echo 'memory_limit = 512M' >> /usr/local/etc/php/conf.d/docker-php-memlimit.ini \
    && echo "upload_max_filesize = 1000M;" >> /usr/local/etc/php/conf.d/uploads.ini \
    && echo "post_max_size = 1000M;" >> /usr/local/etc/php/conf.d/max_size.ini

RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/bin/ --filename=composer --version=2.1.3

WORKDIR /var/www/html

COPY docker-deployment/apache.conf /etc/apache2/sites-available/000-default.conf

COPY . /var/www/html

RUN chmod -R 777 /var/www/html

RUN composer install

#supervisor config
COPY docker-deployment/supervisor.conf /etc/supervisor/supervisord.conf
COPY docker-deployment/supervisor.conf /etc/supervisord.conf

RUN echo "ServerName localhost" >> /etc/apache2/apache2.conf

COPY docker-deployment/entrypoint.sh /usr/bin/entrypoint.sh
RUN chmod +x /usr/bin/entrypoint.sh
ENTRYPOINT ["entrypoint.sh"]

CMD ["/usr/bin/supervisord", "-c", "/etc/supervisord.conf"]
