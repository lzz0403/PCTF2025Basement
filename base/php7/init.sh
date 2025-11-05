#!/bin/sh
echo $GZCTF_FLAG > "/$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | head -c 16)"

unset GZCTF_FLAG

php-fpm -D
apache2-foreground
