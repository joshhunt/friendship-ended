# FROM php:8.0.2-fpm-alpine
# WORKDIR /var/www/html

# COPY . ./

# CMD ["php-fpm"]

# EXPOSE 9000


FROM trafex/php-nginx

USER root
RUN sed -i '/sendfile off;/aclient_max_body_size 100M;' /etc/nginx/conf.d/default.conf
RUN echo "" >> /etc/php82/conf.d/custom.ini
RUN echo "post_max_size=100M" >> /etc/php82/conf.d/custom.ini
RUN echo "upload_max_filesize=100M" >> /etc/php82/conf.d/custom.ini
RUN apk add font-terminus font-inconsolata font-dejavu font-noto font-noto-cjk font-awesome font-noto-extra

RUN apk add php8-pear --repository=https://dl-cdn.alpinelinux.org/alpine/edge/testing
RUN apk add php82-pecl-imagick --repository=https://dl-cdn.alpinelinux.org/alpine/edge/community
RUN apk --update add imagemagick imagemagick-dev ghostscript
RUN pecl8 enable imagick

RUN apk --update add fontconfig msttcorefonts-installer
RUN update-ms-fonts

RUN chmod -R o+w /usr/share/fonts && fc-cache --really-force --verbose
USER nobody

COPY --from=composer/composer:latest-bin /composer /usr/bin/composer

WORKDIR /var/www/html/

COPY . ./

RUN composer install

USER root
RUN chmod -R 0777 /var/www/html/tmp
USER nobody