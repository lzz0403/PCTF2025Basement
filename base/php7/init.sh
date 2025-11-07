#!/bin/sh
echo $GZCTF_FLAG > /flag

unset GZCTF_FLAG

php-fpm -D
apache2-foreground
