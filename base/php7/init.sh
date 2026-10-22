#!/bin/sh
TMPFILE=$(mktemp /XXXX_flag_XXXXXXXXXXXXX)
printf '%s\n' "$GZCTF_FLAG" > "$TMPFILE"
chmod 0644 "$TMPFILE"

unset GZCTF_FLAG

if command -v apache2-foreground >/dev/null 2>&1; then
    exec apache2-foreground
fi

php-fpm -D
exec nginx -g 'daemon off;'
