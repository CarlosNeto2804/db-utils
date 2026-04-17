# mysqldump

- lenguage: English

## Dump a database

```bash
mysqldump \
    --host="$DUMP_MYSQL_HOST" \
    --port="$DUMP_MYSQL_PORT" \
    --user="$DUMP_MYSQL_USER" \
    -p \
    --databases <db-name> \
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
    --verbose > database_name.sql
```

## Dump a database
