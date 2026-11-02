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

## `8.5.12` 分支的 CTF 专用补丁

这个分支名用于区分构建，**实际 PHP 版本仍是 8.5.11**。PHP 官方 8.5.12
修复了题目预期使用的跨请求上传进度漏洞，不能直接升级。这里仅将
`concat_uaf.patch` 应用到 Zend 的 `concat_function()`：写入拼接结果后再析构旧值，
阻断 TimeAfterFree 利用的 `array .= 'x'` 析构重入路径。Apache 和 FPM 构建均应用补丁。

在仓库根目录构建镜像：

```sh
docker build -f base/php7/Dockerfile.7.4 -t pctf-php:8.5.11-concatfix-apache base/php7
docker build -f base/php7/Dockerfile -t pctf-php:8.5.11-concatfix-fpm-alpine base/php7
```

原题的 `index.php` 可以保持不变；部署时需把题目 Dockerfile 的 `FROM`
改为 `ghcr.io/lzz0403/pctf2025basement/php88:8.5.11-concatfix-apache`。

镜像标签保留真实 PHP 版本。补丁只验证了这条 TimeAfterFree 利用链；
`zend_execute.c` 中其他析构重入路径等内存安全问题仍需单独评估。
重新编译会改变 `libphp.so` 中的函数偏移；针对未打补丁官方镜像的
硬编码偏移不能直接用于本构建。
本地 Apache 构建中 `zval_ptr_dtor` 从 `0x7a38e0` 移到 `0x7a39e0`，
`zif_system` 仍为 `0x588820`。这些是本次二进制的值，重新构建后应以
`nm /usr/lib/apache2/modules/libphp.so` 核对。

## PHP 7.4.33 concat 防护构建

`7.4.33-concatfix` 分支使用官方 `php:7.4.33-apache` 源码重新编译。
`concat81705_guard.patch` 在 `concat_function()` 隐式转换数组、对象或资源之前
抛出 `Error`，阻断 bug #81705 及 `php-concat-bypass` 使用的错误处理器重入路径。
标量拼接保持可用。这个 CTF 专用限制会改变 PHP 对非标量拼接的行为。

```sh
docker build -f base/php7/Dockerfile.7.4.33 \
  -t pctf-php:7.4.33-concatfix-apache base/php7
```

镜像保留 `php.ini`、站点目录权限和 flag 初始化逻辑，且不编译 SQLite 驱动。
GitHub Actions 将构建结果发布为
`ghcr.io/lzz0403/pctf2025basement/php88:7.4.33-concatfix-apache`。

本补丁只针对 `concat_function()` 的重入利用入口；它不宣称消除 PHP 7.4.33
的所有内存安全问题。题目的预期利用脚本含 PHP 8.5.11 的硬编码偏移，切换题目
镜像前需要另行校准并完整验证 7.4.33 的预期解。
