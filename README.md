本镜像来源于GZCTF的challenge-base，用于PCTF比赛的基础镜像

## PHP 8.5.11（不含 SQLite 扩展）

`base/php7/Dockerfile.7.4` 和 `base/php7/Dockerfile` 基于固定版本的 PHP 官方镜像构建文件重新编译 PHP，使用 `--without-pdo-sqlite --without-sqlite3`。PHP 仍为 8.5.11，PDO 核心扩展仍可用于其他数据库驱动。

在仓库根目录构建：

```sh
docker build -f base/php7/Dockerfile.7.4 -t pctf-php:8.5.11-apache-no-sqlite base/php7
docker build -f base/php7/Dockerfile -t pctf-php:8.5.11-fpm-alpine-no-sqlite base/php7
```

验证 Apache 镜像（FPM 镜像替换镜像名即可）：

```sh
docker run --rm --entrypoint php pctf-php:8.5.11-apache-no-sqlite -n -r 'var_dump(PHP_VERSION, extension_loaded("PDO"), extension_loaded("pdo_sqlite"), extension_loaded("sqlite3"));'
```

预期依次为 `8.5.11`、`true`、`false`、`false`。
