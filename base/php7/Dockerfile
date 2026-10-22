FROM php:8.5.11-fpm-alpine

RUN apk add --no-cache shadow nginx && \
    usermod -u 1000 www-data && \
    groupmod -g 1000 www-data && \
    chown root:root /var/www/html && chmod 0757 /var/www/html && \
    sed -i 's/worker_processes auto;/worker_processes 1;/' /etc/nginx/nginx.conf && \
    ln -sf /dev/stdout /var/log/nginx/access.log && \
    ln -sf /dev/stderr /var/log/nginx/error.log

COPY php.ini /usr/local/etc/php/conf.d/php.ini
COPY nginx.conf /etc/nginx/http.d/default.conf
COPY --chown=root:root index.php /var/www/html
COPY --chmod=500 init.sh /init.sh

CMD ["/init.sh"]
