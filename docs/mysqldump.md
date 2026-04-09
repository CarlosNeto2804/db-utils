# mysqldump

- lenguage: English

## Dump a database

```bash
mysqldump \
  --host="$DUMP_MYSQL_HOST" \
  --port="$DUMP_MYSQL_PORT" \
  --user="$DUMP_MYSQL_USER" \
  --password="$DUMP_MYSQL_PASSWORD" \
  --databases <database_name> \
  --single-transaction \
  --verbose \
  --quick \
  --skip-lock-tables \
  --routines \
  --triggers \
  --events \
  --add-drop-table \
  --create-options \
  --set-gtid-purged=OFF \
  --default-character-set=utf8mb4 \
  --column-statistics > database_name.sql
```

## Dump a database
