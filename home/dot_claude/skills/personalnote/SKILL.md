---
name: personalnote
description: Write a research note or document to the personal notes directory (~/notes/agents). Creates the topic directory if needed, writes a date-prefixed markdown file, and keeps the topic index.md up to date. Never reads or writes anywhere in ~/notes outside ~/notes/agents.
allowed-tools: Write, Read, Glob
---

# Personal Notes Writer

## Today's date

!`date +%Y-%m-%d`

## Arguments

$ARGUMENTS

The first token is the topic directory name (optional). Everything after it is the content description or instruction — for example `/personalnote homelab summarize the network segmentation plan`.

## Existing topic directories

!`ls ~/notes/agents/ 2>/dev/null || echo "(none yet)"`

## Existing files in the topic directory (if known from arguments)

!`[ -n "$ARGUMENTS" ] && ls "~/notes/agents/$ARGUMENTS/" 2>/dev/null || true`

## Boundary

`~/notes` is the user's personal notes repository. Only `~/notes/agents/` is
in scope for this skill. Never read or write anything else under `~/notes`.

## Workflow

### 1. Determine the topic directory

Parse `$ARGUMENTS`: the first whitespace-delimited token is the topic name; the remainder (if any) is the content description. Then use the first source that applies:

- The topic name parsed from `$ARGUMENTS` if non-empty
- The topic directory already used in this session (if a previous personal note was written)
- Otherwise: show the existing topic directories above and use AskUserQuestion to ask which to use or whether to create a new one

### 2. Determine the content

The content comes from (in order of priority): the content description parsed from `$ARGUMENTS`, the user's most recent message describing what to record, or a synthesis of the relevant parts of the current session. Do not ask for clarification — use what is available.

### 3. Write the document

Filename: `<date>-<slug>.md` where the date is today's date and the slug is a short kebab-case summary of the content topic.

Write the file to `~/notes/agents/<topic>/<filename>.md`. Structure it as clean markdown with a `#` title heading.

### 4. Update index.md

Read `~/notes/agents/<topic>/index.md` if it exists. Then write a new version with:

```markdown
# <topic>

- [filename](filename) — one-line headline
```

Rules:

- One entry per `.md` file in the directory, excluding `index.md` itself
- Sort entries by filename (alphabetical, which is also chronological given the date prefix)
- For the file just written: generate the headline from its content
- For files already in the index: keep their existing headline
- For files present on disk but missing from the index: use the first `#` heading of that file as the headline
