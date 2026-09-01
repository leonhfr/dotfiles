# pgcli

## Key bindings
- `F2` - toggle smart completion (table/column-aware)
- `F3` - toggle multi-line mode
- `F4` - toggle vi keybindings

## Completion
- `\refresh` - reload completion metadata after a schema change

## Favorites (named queries)
- `\fs <name> <query>` - save a named query
- `\f <name>` - run a saved favorite
- `\fd <name>` - delete a favorite

## Query I/O
- `\i <file>` - run sql from file
- `\copy ... csv header` - client-side COPY, same as psql

## Output
- `\pset pager off` - disable the pager for long results
- `\timing` - toggle query timing
