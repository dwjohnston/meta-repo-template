# Task 2: Admin Mode and Required Environment Values

Extend `./tests/run.sh config` with two cases:

- `apply.sh --admin` succeeds and mounts the temporary meta-repo at `/workspace/<repo-name>`.
- A declared environment key without a value fails with the expected message and does not write `compose.local.yaml`.

Unset host variables referenced as `$VAR` remain warning-only and are not part of this task.

