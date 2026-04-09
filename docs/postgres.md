# PostgreSQL

- lenguage: English

## Get Database Size

```sql
SELECT
    table_schema AS 'Database',
    ROUND(SUM(data_length + index_length) / 1024 / 1024, 2) AS 'Size (MB)'
FROM information_schema.tables
GROUP BY table_schema
ORDER BY 'Size (MB)' DESC;
```

## Check processes

```sql
SELECT * FROM pg_stat_activity;
```

## Blocked processes

```sql
SELECT * FROM pg_stat_activity WHERE state = 'idle in transaction' AND query NOT ILIKE '%pg_stat_activity%';
```

## Kill a process

```sql
SELECT pg_terminate_backend(<process_id>);
```
