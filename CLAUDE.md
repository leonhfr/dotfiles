# CLAUDE.md

This repository holds chezmoi-managed dotfiles for macOS.

## Layout

- `.chezmoiroot` is `home`, so the chezmoi **source directory is `home/`**. Only files under `home/` are deployed to `~`.
- Everything at the repo root is tooling and is **not** deployed: `README.md`, `mise.toml`, `hk.pkl`, `bin/`, `docs/`, `.claude/`, `.vscode/`, `.zed/`, `.gitattributes`.
- Two machine types drive all differences: `personal` and `work`. The current type is the `.machine` template variable.

## Applying changes

- Never edit files under `~` directly. Edit the source under `home/`, then apply.
- Preview: `chezmoi diff` (alias `cmd`). Apply: `chezmoi apply` (alias `cma`). Apply one target: `chezmoi apply ~/.zshrc`.
- Pull an on-disk change back into the source: `chezmoi add ~/path`.
- Test template logic: `chezmoi execute-template '{{ .machine }}'`.
- The apply is gated by two hooks defined in `home/.chezmoi.toml.tmpl`:
  - `read-source-state.pre` runs `bin/install-prerequisites.sh` (Xcode CLT, Homebrew, 1Password CLI, transcrypt).
  - `apply.pre` runs `bin/check-claude-settings.sh` (see Claude settings).

## Source naming conventions

chezmoi encodes file attributes in the source name. Common prefixes and suffixes in this repo:

- `dot_foo` -> `~/.foo`
- `private_foo` -> mode `0600`
- `executable_foo` -> mode `+x`
- `encrypted_foo` -> encrypted in git (see Encryption)
- `foo.tmpl` -> rendered as a Go template with access to config data
- `run_onchange_before_NN_*.sh.tmpl` / `run_onchange_after_NN_*.sh.tmpl` -> scripts (see Scripts)
- `.chezmoi*` names are chezmoi control files, not deployed targets.

Prefixes stack, for example `home/encrypted_dot_zshrc_work.zsh.tmpl` -> `~/.zshrc_work.zsh`, encrypted, templated.

## Templating and machine differences

Template data comes from `home/.chezmoi.toml.tmpl` (`[data]`, prompted once on init) and every file under `home/.chezmoidata/`.

- `.machine`, `.personal.*`, `.work.*`, `.work_github_org`, and 1Password references live in the config.
- The standard scope-merge idiom, used across scripts and templates:
  ```
  concat (.X.common | default (list)) (index .X .machine | default (list)) | sortAlpha | uniq
  ```
- `home/.chezmoiignore` is itself a template. It excludes files per OS (`.chezmoiscripts/darwin/**` off darwin), per machine (work-only files off personal), and per package (navi cheats and skill dirs for brews not installed on this machine). It also lists runtime noise to never manage.
- `home/.chezmoiremove` lists target paths chezmoi must delete. Add a path here to remove a previously deployed file on the next apply. A pre-commit check (`bin/check-chezmoiremove.sh`) warns when a source file is deleted or renamed but its old target is not listed here.
- `home/.chezmoiexternal.toml.tmpl` declares content chezmoi fetches into the target but does not store in source. Each entry is keyed by target path relative to `~` and sets a `type` (`git-repo`, `file`, `archive`, ...). Add a `refreshPeriod` (for example `"168h"`) to limit how often chezmoi re-fetches.

## Encryption

Encryption is done by transcrypt, a git filter, combined with chezmoi's `encryption = "transparent"` mode.

How it works:

- `.gitattributes` maps `encrypted_* filter=crypt diff=crypt merge=crypt`. transcrypt encrypts matching files with AES-256-CBC in git blobs. `bin/configure-transcrypt.sh` sets up the filter from a 1Password passphrase on a fresh machine.
- The **working tree is always plaintext**. transcrypt decrypts on checkout (smudge) and encrypts on commit (clean). Committed git blobs are ciphertext.

Use the `encrypted_` prefix for content that is work-specific or private and must not leak in git history.

### Working with encrypted files

- Read and edit `encrypted_*` files directly. They are plaintext in the working tree. No decrypt step is needed. transcrypt re-encrypts on commit.
- To add a new secret, name the source file with the `encrypted_` prefix so `.gitattributes` matches. It is encrypted in git on the next commit.
- Verify what is encrypted at rest: `git ls-crypt` lists all encrypted files. `git show HEAD:home/path/encrypted_file` shows the ciphertext blob.
- Never copy a decrypted secret value into a non-`encrypted_` file, a commit message, or a PR description. The pre-commit check `bin/check-plaintext-keywords.sh` blocks the keywords `qonto`, `qontoctl`, and `leon.hollender` in any non-`encrypted_` staged file.

## Secrets from 1Password

Two secret mechanisms exist. transcrypt (above) stores encrypted content in git. 1Password stores nothing in the repo: templates fetch the value live on each apply.

- Templates read secrets with `onepasswordRead <ref> <account>` through the 1Password CLI (`op`). The reference form is `op://<vault>/<item>/<field>`.
- References live in the config under `.personal.op.*` and `.work.op.*` (`ssh_public_key`, `ssh_private_key`, `chezmoi_token`). The account shorthand is `my` for personal and prompted for work.
- Uses: SSH private and public keys, the git `signingkey`, the chezmoi GitHub token, and the transcrypt passphrase (`bin/configure-transcrypt.sh` reads `op://Personal/Dotfiles Transcrypt Passphrase/password`).
- Sign in to `op` before apply. If `op` cannot read a reference, that file fails to render.

## SSH keys and git identity

SSH source is `home/private_dot_ssh/` -> `~/.ssh` (`private_` sets mode `0600`). Keys come from 1Password. `config.tmpl` points `github.com` at the personal key; on work it adds a `github-work` host alias that uses the work key. `run_onchange_after_00_ssh_agent.sh.tmpl` loads the keys into the agent and keychain.

Git identity depends on the repo's directory.

- `home/private_dot_config/git/config.tmpl` -> `~/.config/git/config` sets the personal identity by default (name, email, SSH `signingkey` from 1Password).
- On work it adds `includeIf "gitdir:~/work/"` -> `~/work/.gitconfig` (from `home/work/dot_gitconfig.tmpl`, ignored on personal). So a repo under `~/work/` uses the work identity; a repo anywhere else uses the personal one.
- On work, git rewrites `git@github.com:<org>` remotes to the `github-work` SSH host (`insteadOf`), so work repos authenticate with the work key. ghq clones work org and user repos under `~/work`, everything else under `~/src`.

## Data-driven config (`home/.chezmoidata/`)

- `packages.yaml`: `brews`, `casks`, `gobin`, `cargo`, `vscode`, each scoped `common` / `personal` / `work`. Commented lines are disabled. A `#skill` tag means a matching `home/dot_claude/skills/<name>/SKILL.md` must exist (enforced by `bin/check-skill-tags.sh`); `#skill:` and `#skill?` are notes, not requirements.
- `dock.yml`: Dock apps per machine. `mode: replace` rebuilds the whole Dock; `mode: manage` adds and removes named apps only.
- `encrypted_claude.yaml`: `claude_marketplaces` and `claude_plugins` per machine, plus `claude_tools` (brew name -> the note injected into the generated CLAUDE.md Tools section).
- `encrypted_repos.yaml`: git repos to clone per machine.

Change these files, then apply, to add or remove packages, plugins, Dock apps, or repos.

## Scripts and the rerun-trigger pattern

Scripts live in `home/.chezmoiscripts/darwin/`, named `run_onchange_{before,after}_NN_name.sh.tmpl`. `before` runs before files are applied, `after` runs after. `NN` sets order.

`run_onchange_` scripts rerun only when their **rendered content changes**. chezmoi stores a hash of the rendered script. To force a rerun on a schedule or when data changes, the script embeds a comment whose rendered value changes:

- `# weekly: {{ now | date "2006-W01" }}` reruns when the ISO week changes (weekly cadence).
- `# monthly: {{ now | date "2006-01" }}` reruns monthly.
- `# {{ list .brews .casks .gobin .cargo | toJson | sha256sum }}` reruns when that data changes.
- `# MacOS build version: {{ output "sw_vers" "--buildVersion" }}` reruns after a macOS update.
- Auto-generated per-file `shasum` checksums (launch agents in `after_60`, bat themes in `after_90`) rerun the script when a referenced source file changes.

When you edit a script, keep or add the correct trigger comment. Without it the script may not rerun when you expect. All `darwin/**` scripts are ignored on non-darwin machines.

## Claude settings management

- `~/.claude/settings.json` is built by `home/dot_claude/settings.json.tmpl`. It reads the base `home/.chezmoitemplates/claude_settings.json`, deep-merges a per-machine fragment (`claude_settings_personal.json` or `encrypted_claude_settings_work.json`) via `claude_settings_deepmerge.tmpl` (lists concat and dedupe, maps recurse, scalars overwrite).
- `~/.claude/CLAUDE.md` is built by `home/dot_claude/CLAUDE.md.tmpl`. Its Tools section is generated from `claude_tools` for brews installed on this machine. On work it appends `@CLAUDE_WORK.md`.
- Claude edits `settings.json` at runtime, so the on-disk file drifts from the source. Two tools reconcile the drift:
  - `bin/check-claude-settings.sh` (the `apply.pre` hook) blocks apply when the on-disk file has real drift, and offers to overwrite it with the rendered version.
  - `chezmoi claude diff` shows a normalized diff. `chezmoi claude sync` writes on-disk values back into the source fragments, routing each key to the base or machine file and re-encrypting the work fragment.
- After changing settings in the Claude UI, run `chezmoi claude sync` to persist them to source.

## Custom scripts (`home/dot_local/bin/`)

Deployed to `~/.local/bin`. `executable_` prefix makes them runnable.

- A script named `chezmoi-<name>` becomes a `chezmoi <name>` subcommand, because chezmoi runs any `chezmoi-*` on `PATH`. Examples: `chezmoi claude`, `chezmoi brews`.
- Usage text convention: lines starting with `### ` are the help text, printed by `sed -rn 's/^### ?//p' "$0"`. `-h` shows it.
- `.tmpl` scripts (for example `executable_repo.tmpl`) are templated with the work org and user.
- The script template is `home/dot_local/bin/.template`.

Key scripts:

- `repo add|create|remove`: clone, create, or delete a ghq repo and track it in `encrypted_repos.yaml`.
- `repos check|pull|switch|clean|skills|claude-local`: maintenance across all ghq repos, parallel by default (`-s` for sequential).
- `chezmoi-brews`: list active brews and casks with descriptions; `-n` shows disabled, `-a` shows all machines.
- `bru`: apply the Homebrew and package scripts only.

## Pre-commit hooks

`hk.pkl` defines the pre-commit hook (run via `mise`, `hk install --mise`). `fail_fast = false`, so all checks run:

- `gitleaks` (secret scan)
- `check-plaintext-keywords.sh` (work keywords outside `encrypted_` files)
- `check-chezmoiremove.sh` (deleted or renamed source with no `.chezmoiremove` entry)
- `check-skill-tags.sh` (`#skill`-tagged brew without a skill directory)
- `check-repos-sync.sh` (`ghq list` clones diverge from `encrypted_repos.yaml` for this machine, in either direction; worktrees skipped)

`check-plaintext-keywords.sh`, `check-chezmoiremove.sh`, and `check-skill-tags.sh` are `allow_failure = true`: they warn but do not block. `gitleaks` and `check-repos-sync.sh` block the commit.

## Cron

`home/private_Library/LaunchAgents/*.plist.tmpl` are launchd user agents in the `fr.leonh` namespace (repos pull and clean). The `after_60` script syncs loaded agents to match the plists on disk.
