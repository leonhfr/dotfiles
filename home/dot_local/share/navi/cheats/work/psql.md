# psql

## Session
- `\?` - backslash-command help
- `\h <stmt>` - SQL syntax help
- `\c <db>` - connect to db
- `\q` - quit

## Inspect schema
- `\l` - list databases
- `\dn` - list schemas
- `\dt` - list tables in current schema
- `\dt <schema>.*` - tables in a schema
- `\d <table>` - describe a table (columns, indexes, FKs)
- `\d+ <table>` - same plus storage info
- `\df <name>` - list functions
- `\du` - list roles

## Query I/O
- `\e` - edit current query in $EDITOR
- `\i <file>` - run sql from file
- `\copy <table> from '<file>' csv header` - client-side COPY, no superuser needed
- `\watch <s>` - rerun the previous query every s seconds

## Output
- `\timing on` - show query duration
- `\x` - toggle expanded output (one column per line)
