#!/bin/sh
# renomeia o arquivo atual para um backup e da reload no syslog

RETENTION_DAYS=30
RETENTION_UNCOMPRESSED=3
LOG_DIR=/logs
HAPROXY_LOG=haproxy.log
HAPROXY_ADMIN_LOG=haproxy_admin.log
ROTATE_SUFFIX=$(env TZ=MET+3 date +%d%m%Y_%H%M%S_%s)

#rotate no log
cd ${LOG_DIR} || exit 2
mv ${HAPROXY_LOG} ${HAPROXY_LOG}.${ROTATE_SUFFIX}
mv ${HAPROXY_ADMIN_LOG} ${HAPROXY_ADMIN_LOG}.${ROTATE_SUFFIX}

#reload rsyslog
kill -1 1

#limpeza
## compress
find . -type f -iname "${HAPROXY_LOG}.*[0-9]" -mtime +${RETENTION_UNCOMPRESSED} -exec gzip {} \;
find . -type f -iname "${HAPROXY_ADMIN_LOG}.*[0-9]" -mtime +${RETENTION_UNCOMPRESSED} -exec gzip {} \;

## remove
find . -type f -iname "${HAPROXY_LOG}.*.gz" -mtime +${RETENTION_DAYS} -exec rm -f {} \;
find . -type f -iname "${HAPROXY_ADMIN_LOG}.*.gz" -mtime +${RETENTION_DAYS} -exec rm -f {} \;