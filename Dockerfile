FROM alpine:edge

LABEL MAINTAINER Ian-FR <iiaan.fr@gmail.com>

ARG PACKAGES="\
              nginx \
              postgresql \
              composer \
              php7-bcmath \
              php7-curl \
              php7-dom \
              php7-fileinfo \
              php7-fpm \
              php7-gd \
              php7-pdo \
              php7-pdo_pgsql \
              php7-pgsql \
              php7-session \
              php7-simplexml \
              php7-soap \
              php7-tokenizer \
              php7-xdebug \
              php7-xml \
              php7-xmlwriter \
              php7-zip "

RUN apk update && \
    apk add --no-cache $PACKAGES && \
    mv /etc/php7/conf.d/xdebug.ini /etc/php7/conf.d/00_xdebug.ini && \
    sed -i "s/;zend/zend/" /etc/php7/conf.d/00_xdebug.ini && \
    sed -i "s/user = nobody/;user = nobody/" /etc/php7/php-fpm.d/www.conf && \
    sed -i "s/group = nobody/;group = nobody/" /etc/php7/php-fpm.d/www.conf && \
    sed -i "s/127.0.0.1:9000/\/run\/php7\/php-fpm.sock/" /etc/php7/php-fpm.d/www.conf && \
    rm /etc/nginx/conf.d/default.conf && \
    rm -rf /var/cache/apk/* && \
    mkdir -p /run/nginx && \
    mkdir -p /run/php7 && \
    mkdir -p /run/postgresql && \
    mkdir -p /var/lib/postgresql/data && \
    mkdir -p /var/projects

COPY ./config/start /bin/start-server
COPY ./config/nginx.conf /etc/nginx/nginx.conf
COPY ./config/php.ini /etc/php7/conf.d/custom_php.ini
COPY ./config/xdebug.ini /etc/php7/conf.d/custom_xdebug.ini

RUN addgroup -S -g 1000 www && \
    adduser -S -u 1000 -G www -D www && \
    chmod +x /bin/start-server && \
    chown -R www:www /bin/start-server && \
    chown -R www:www /etc/nginx && \
    chown -R www:www /etc/php7 && \
    chown -R www:www /var/projects && \
    chown -R www:www /var/lib/nginx && \
    chown -R www:www /var/lib/php7 && \
    chown -R www:www /var/lib/postgresql && \
    chown -R www:www /var/log && \
    chown -R www:www /run/nginx && \
    chown -R www:www /run/php7 && \
    chown -R www:www /run/postgresql

ADD --chown=www:www ./src/*.php /var/projects/api/public/
ADD --chown=www:www ./src/*.html /var/projects/app/
ADD --chown=www:www ./src/*.php /var/projects/phpinfo/

WORKDIR /var/projects/api

USER www

VOLUME [ "/var/lib/postgresql/data" ]

ENTRYPOINT [ "start-server" ]