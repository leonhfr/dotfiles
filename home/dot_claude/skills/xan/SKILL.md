---
name: xan
description: Process, analyze, and transform CSV/TSV files from the command line using xan. Use when working with delimited data files: filtering rows, computing stats, joining files, or inspecting structure.
---

# xan

`xan` is a fast CSV processor. It reads from a file or stdin and writes to stdout.

Common flags available on most subcommands:
- `-n` / `--no-headers`: input has no header row
- `-d <char>` / `--delimiter <char>`: field separator (default `,`)

## Explore

```sh
xan headers file.csv              # list column names and indices
xan count file.csv                # row count
xan view file.csv                 # paginated table preview
xan stats file.csv                # min, max, mean, stddev per column
xan frequency col file.csv        # value frequency table for a column
```

## Filter and slice

```sh
xan filter 'col > 42' file.csv            # keep rows where expression is true
xan search -s col 'pattern' file.csv      # regex search in a column
xan head -n 100 file.csv                  # first N rows
xan tail -n 100 file.csv                  # last N rows
xan slice -s 10 -e 20 file.csv            # rows 10–19
xan top -n 5 -s col file.csv              # top 5 rows by column value
xan sample -n 1000 file.csv               # random sample
```

## Transform columns

```sh
xan select col1,col2 file.csv             # keep named columns
xan drop col1,col2 file.csv               # drop named columns
xan map 'col * 2' new_col file.csv        # add computed column
xan transform 'trim(col)' col file.csv    # modify column in place
```

## Aggregate

```sh
xan groupby key 'sum(val)' file.csv       # group and aggregate
xan agg 'sum(col), mean(col)' file.csv    # whole-file aggregation
xan bins -c col file.csv                  # histogram bins
```

## Combine files

```sh
xan cat rows a.csv b.csv                  # stack files vertically
xan cat cols a.csv b.csv                  # align files horizontally
xan join --left key a.csv key b.csv       # SQL-style join
```

## Expression language

Expressions use column names directly. Common functions: `trim`, `len`, `lower`, `upper`, `split`, `coalesce`, `if`, arithmetic operators, comparison operators. Run `xan help` for full reference.

```sh
xan filter 'status == "active" && age >= 18' users.csv
xan map 'lower(trim(email))' email_normalized users.csv
```
