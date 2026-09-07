---
name: yq
description: Read, write, and transform YAML, JSON, XML, TOML, CSV, and properties files using yq. Use when working with structured config or data files: extracting values, editing in place, or converting between formats.
---

# yq

`yq` processes structured data files with jq-like path expressions. It auto-detects format from file extension and defaults to YAML for stdin.

## Read and query

```sh
yq '.key' file.yaml                        # read a value
yq '.array[0]' file.yaml                   # first array element
yq '.a.b.c' file.yaml                      # nested path
yq 'keys' file.yaml                        # list keys
yq '.[] | .name' file.yaml                 # iterate array, extract field
```

## Edit in place

```sh
yq -i '.key = "value"' file.yaml           # set a value
yq -i '.array += ["item"]' file.yaml       # append to array
yq -i 'del(.key)' file.yaml               # delete a key
yq -i '.key |= upcase' file.yaml          # transform a value
```

## Format conversion

Input (`-p`) and output (`-o`) accept: `yaml`/`y`, `json`/`j`, `xml`/`x`, `toml`, `csv`/`c`, `tsv`/`t`, `props`/`p`.

```sh
yq -o json file.yaml                       # YAML → JSON
yq -p xml -o yaml file.xml                 # XML → YAML
yq -p json -o toml file.json               # JSON → TOML
cat file.xml | yq -p xml '.root.item'      # query XML from stdin
yq -P file.json                            # pretty-print JSON as YAML
```

## Multiple documents and files

```sh
yq eval-all '. as $x | ...' a.yaml b.yaml  # load all files into one context
yq '... | select(.kind == "Service")' *.yaml  # filter across files
```

## Useful flags

- `-i` / `--inplace`: edit file in place
- `-P` / `--prettyPrint`: normalise style
- `-o <fmt>`: output format
- `-p <fmt>`: input format (override auto-detect)
- `-n` / `--null-input`: no input, build doc from scratch
- `-e` / `--exit-status`: non-zero exit if result is null/false

## Common patterns

```sh
# Extract a value and use in shell
VERSION=$(yq '.version' Chart.yaml)

# Merge two files (second wins on conflict)
yq eval-all 'select(fileIndex == 0) * select(fileIndex == 1)' base.yaml override.yaml

# Bulk update all matching keys
yq -i '(.spec.containers[].image) |= sub("v1\.", "v2.")' deploy.yaml
```
