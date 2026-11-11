# Task 2: Admin Mode and Required Environment Values

Extend `./tests/run.sh config` with two cases:

- `apply.sh --admin` succeeds and mounts the temporary meta-repo at `/workspace/<repo-name>`.
- A declared environment key without a value fails with the expected message and does not write `compose.local.yaml`.

Unset host variables referenced as `$VAR` remain warning-only and are not part of this task.

## Caveats

- **The admin mount target is the copy's directory name**, not a repository name. `apply.sh` takes it from `basename` of its own directory, which is why Task 1 fixes that name.
- **Start the failure case with no `compose.local.yaml`.** A file left by an earlier case would hide a regression. Also assert the exit status is non-zero.
- **Match the message loosely.** Look for the key name and "declared but has no value", not the whole line with its `✗` prefix.
- **Admin mode also reserves the name.** A folder with the same name as the copy is rejected only under `--admin`. Worth one extra case here or in Task 8.
- **Check the generated header.** It records `Mode: admin` or `Mode: standard`, a cheap assertion that the flag was read.

Recommended model: Claude Sonnet 5.5.
