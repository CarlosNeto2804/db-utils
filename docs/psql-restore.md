# psql-restore

- lenguage: English

## Restore a database

```bash
psql --host="$RESTORE_POSTGRES_HOST" \
  --port="$RESTORE_POSTGRES_PORT" \
  --user="$RESTORE_POSTGRES_USER" \
  --password="$RESTORE_POSTGRES_PASSWORD" \
  --dbname="$RESTORE_POSTGRES_DATABASE" \
  < <database_name>.sql
```
