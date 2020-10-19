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
    rm /etc/nginx/conf.d/default.conf && \
    rm -rf /var/cache/apk/* && \
    mkdir -p /var/app && \
    mkdir -p /run/nginx && \
    mkdir -p /run/postgresql && \
    mkdir -p /var/lib/postgresql/data

WORKDIR /var/app

COPY ./config/nginx.conf /etc/nginx/nginx.conf
COPY ./config/php.ini /etc/php7/conf.d/custom_php.ini
COPY ./config/xdebug.ini /etc/php7/conf.d/custom_xdebug.ini
COPY ./config/start /bin/start-server
COPY ./src /var/app

VOLUME [ "/var/lib/postgresql/data" ]

RUN chmod +x /bin/start-server && \
    chown -R nobody:nobody /var/app && \
    chown -R nobody:nobody /var/lib/nginx && \
    chown -R nobody:nobody /var/lib/php7 && \
    chown -R nobody:nobody /var/log && \
    chown -R nobody:nobody /etc/nginx && \
    chown -R nobody:nobody /bin/start-server && \
    chown -R nobody:nobody /run/nginx && \
    chown -R postgres:postgres /run/postgresql && \
    chown -R postgres:postgres /var/lib/postgresql/data

# USER nobody

EXPOSE 80 5432

ENTRYPOINT [ "start-server" ]