#!/bin/sh
FLAGFILE=$(mktemp)
printf '%s\n' "$GZCTF_FLAG" > "$FLAGFILE"
chmod 0644 "$FLAGFILE"

unset GZCTF_FLAG

if command -v apache2-foreground >/dev/null 2>&1; then
    exec apache2-foreground
fi

php-fpm -D
exec nginx -g 'daemon off;'
