#!/bin/sh
echo $GZCTF_FLAG > /love1145141919810

unset GZCTF_FLAG

php-fpm -D
apache2-foreground
