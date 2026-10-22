#!/bin/sh
printf '%s\n' "$GZCTF_FLAG" > /love1145141919810
chmod 0644 /love1145141919810

unset GZCTF_FLAG

if command -v apache2-foreground >/dev/null 2>&1; then
    exec apache2-foreground
fi

php-fpm -D
exec nginx -g 'daemon off;'
