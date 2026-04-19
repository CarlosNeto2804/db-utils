#!/usr/bin/env bash
set -euo pipefail

# Uso no container:
#   /scripts/mysql-dump-on-start.sh              — dump (se DUMP_MYSQL_HOST) + mantém o container ativo
#   DUMP_RUN_IN_BACKGROUND=1 ... mesmo comando  — dump em background; shell/container segue em primeiro plano
#   docker exec ... /scripts/mysql-dump-on-start.sh manual — só o dump (útil para rodar sob demanda)

run_mysqldump() {
  : "${DUMP_MYSQL_USER:?DUMP_MYSQL_USER obrigatório para o dump automático}"
  : "${DUMP_MYSQL_PASSWORD:?DUMP_MYSQL_PASSWORD obrigatório para o dump automático}"
  DUMP_MYSQL_PORT="${DUMP_MYSQL_PORT:-3306}"

  local out="${DUMP_MYSQL_OUTPUT:-/backup/all-databases.sql}"
  local wait_max="${DUMP_WAIT_MAX_SECONDS:-120}"

  export MYSQL_PWD="$DUMP_MYSQL_PASSWORD"

  echo "Aguardando MySQL em ${DUMP_MYSQL_HOST}:${DUMP_MYSQL_PORT}..."
  local i
  for ((i = 0; i < wait_max; i += 2)); do
    if mysqladmin ping -h"$DUMP_MYSQL_HOST" -P"$DUMP_MYSQL_PORT" -u"$DUMP_MYSQL_USER" --silent 2>/dev/null; then
      break
    fi
    if ((i + 2 >= wait_max)); then
      echo "Timeout após ${wait_max}s aguardando ${DUMP_MYSQL_HOST}:${DUMP_MYSQL_PORT}" >&2
      unset MYSQL_PWD
      return 1
    fi
    sleep 2
  done

  echo "Gerando dump em ${out}..."
  mysqldump \
    --host="$DUMP_MYSQL_HOST" \
    --port="$DUMP_MYSQL_PORT" \
    --user="$DUMP_MYSQL_USER" \
    -p \
    --all-databases \
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
    --verbose >"$out"

  echo "Dump concluído."
  unset MYSQL_PWD
}

maybe_run_dump() {
  if [[ -z "${DUMP_MYSQL_HOST:-}" ]]; then
    echo "DUMP_MYSQL_HOST vazio: pulando mysqldump automático."
    return 0
  fi

  if [[ "${DUMP_RUN_IN_BACKGROUND:-0}" == "1" ]]; then
    run_mysqldump &
    echo "mysqldump em background (PID $!). Logs no stdout/stderr do container."
    return 0
  fi

  run_mysqldump
}

exec_remainder_or_hold() {
  if [[ $# -gt 0 ]]; then
    exec /bin/bash "$@"
  fi
  # Sem CMD/args, bash não interativo sai na hora; mantém o container útil para exec / background jobs.
  exec /bin/bash -c "sleep infinity"
}

case "${1:-}" in
  manual)
    shift || true
    if [[ -z "${DUMP_MYSQL_HOST:-}" ]]; then
      echo "DUMP_MYSQL_HOST vazio: defina o host remoto para mysqldump." >&2
      exit 1
    fi
    run_mysqldump
    exit $?
    ;;
esac

maybe_run_dump
exec_remainder_or_hold "$@"
