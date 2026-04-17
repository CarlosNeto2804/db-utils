#!/usr/bin/env bash
set -euo pipefail

# Roda mysqldump (docs/mysqldump.md) ao subir o container, se DUMP_MYSQL_HOST estiver definido.
if [[ -z "${DUMP_MYSQL_HOST:-}" || -z "${DUMP_MYSQL_DATABASE:-}" ]]; then
  echo "DUMP_MYSQL_HOST ou DUMP_MYSQL_DATABASE vazio: pulando mysqldump automático."
  exec /bin/bash "$@"
fi

: "${DUMP_MYSQL_USER:?DUMP_MYSQL_USER obrigatório para o dump automático}"
: "${DUMP_MYSQL_PASSWORD:?DUMP_MYSQL_PASSWORD obrigatório para o dump automático}"
DUMP_MYSQL_PORT="${DUMP_MYSQL_PORT:-3306}"

out="${DUMP_MYSQL_OUTPUT:-/backup/${DUMP_MYSQL_DATABASE}.sql}"
wait_max="${DUMP_WAIT_MAX_SECONDS:-120}"

export MYSQL_PWD="$DUMP_MYSQL_PASSWORD"

echo "Aguardando MySQL em ${DUMP_MYSQL_HOST}:${DUMP_MYSQL_PORT}..."
for ((i = 0; i < wait_max; i += 2)); do
  if mysqladmin ping -h"$DUMP_MYSQL_HOST" -P"$DUMP_MYSQL_PORT" -u"$DUMP_MYSQL_USER" --silent 2>/dev/null; then
    break
  fi
  if ((i + 2 >= wait_max)); then
    echo "Timeout após ${wait_max}s aguardando ${DUMP_MYSQL_HOST}:${DUMP_MYSQL_PORT}" >&2
    exit 1
  fi
  sleep 2
done

echo "Gerando dump em ${out}..."
mysqldump \
  --host="$DUMP_MYSQL_HOST" \
  --port="$DUMP_MYSQL_PORT" \
  --user="$DUMP_MYSQL_USER" \
  -p \
  --databases "$DUMP_MYSQL_DATABASE" \
  --single-transaction \
  --quick \
  --skip-lock-tables \
  --routines \
  --triggers \
  --events \
  --add-drop-table \
  --create-options \
  --set-gtid-purged=OFF \
  --default-character-set=utf8mb4 \
  --column-statistics=0 \
  --hex-blob \
  --extended-insert \
  --set-charset \
  --verbose >"/backup/${DUMP_MYSQL_HOST}.sql"

echo "Dump concluído."
unset MYSQL_PWD
exec /bin/bash "$@"
