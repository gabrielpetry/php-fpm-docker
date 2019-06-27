#!/bin/bash
# helpers functions
changeTemplateToConst() {
    if $(command -v sed) -i "s/${1}/${2}/g" "${3}"; then
        return 0
    fi
    # Error occurred
    return 1
}

# CLEAR TMP FILES
/root/autoclean.sh

# ADD CRON
CRONFILE="/cronfile"
/usr/bin/crontab "${CRONFILE}"

# DECLARE/SET VARIABLES
PHP_VERSION=$(cat /PHP_VERSION 2>/dev/null)
if [[ -z "${PHP_VERSION}" ]]; then
    echo "Something wen't wrong"
    return 2
fi
if [[ -z "${PHP_MEMORY_LIMIT}" ]]; then
    PHP_MEMORY_LIMIT="128M"
fi
if [[ -z "${PHP_DISPLAY_ERRORS}" ]]; then
    PHP_DISPLAY_ERRORS="Off"
fi
if [[ -z "${SMTP_SERVER}" ]]; then
    SMTP_SERVER="mail"
fi
if [[ -z "${SMTP_HOSTNAME}" ]]; then
    SMTP_HOSTNAME="$(/bin/hostname)"
fi

# PUPULATE TEMPLATES
changeTemplateToConst "%SMTP_SERVER%" "${SMTP_SERVER}" "/etc/ssmtp/ssmtp.conf"
changeTemplateToConst "%SMTP_HOSTNAME%" "${SMTP_HOSTNAME}" "/etc/ssmtp/ssmtp.conf"
changeTemplateToConst "%SMTP_USER%" "${SMTP_USER}" "/etc/ssmtp/ssmtp.conf"
changeTemplateToConst "%SMTP_PASS%" "${SMTP_PASS}" "/etc/ssmtp/ssmtp.conf"

changeTemplateToConst "%PHP_VERSION%" "${PHP_VERSION}" "/etc/php/${PHP_VERSION}/fpm/php-fpm.conf"
changeTemplateToConst "%PHP_VERSION%" "${PHP_VERSION}" "/etc/php/${PHP_VERSION}/fpm/pool.d/www.conf"
changeTemplateToConst "%PHP_DISPLAY_ERRORS%" "${PHP_DISPLAY_ERRORS}" "/etc/php/${PHP_VERSION}/fpm/pool.d/www.conf"
changeTemplateToConst "%PHP_MEMORY_LIMIT%"   "${PHP_MEMORY_LIMIT}"   "/etc/php/${PHP_VERSION}/fpm/pool.d/www.conf"

# START SERVICES
/usr/sbin/service cron restart
/usr/sbin/service "php${PHP_VERSION}-fpm" restart

# KEEP CONTAINER ALIVE
/usr/bin/tail -f "/var/log/php${PHP_VERSION}-fpm.log"
