# Task 8: Remaining Config Validation

Added in review. Tasks 1 and 2 cover a small part of what `apply.sh` validates and generates.

Extend `./tests/run.sh config` with table-driven cases for:

- **Ports:** a single port and a range map to host port + 10000 on `127.0.0.1`; overlapping entries, out-of-range values and malformed entries fail.
- **Separate mounts:** each becomes a named volume at the right target, and its path appears in `META_REPO_VOLUME_PATHS`.
- **Ignore:** a matched file becomes a read-only `/dev/null` bind, a matched directory a tmpfs, and nothing inside `.git` or a separate mount is matched.
- **Folder merging:** the same `path` in both config files yields one mount with combined `separate_mounts` and `ignore`.
- **Name clashes:** duplicate folder names and reserved names (`.agents`, `.workspace`, `.claude`, entries of `.root/`) fail.
- **Identifiers:** invalid `metarepo_id` and `metarepo_suffix` fail; `git.name` without `git.email` fails.
- **Path safety:** absolute paths and `..` are rejected in folders, separate mounts, ignore patterns and dotfiles.
- **Dotfiles:** an existing one is mounted read-only and listed in `META_REPO_DOTFILES`; a missing one warns and is skipped.
- **Proxies:** build-time values become build args, runtime values become both upper- and lower-case environment variables.
- **Generated `AGENTS.md`:** the folder marker is replaced by the folder listing with descriptions.
- **Literal `$`:** a host path containing `$` reaches Compose unchanged.
- **Missing prerequisites:** no `meta-repo.local.yaml` fails with the copy-the-template hint.

Each failing case asserts a non-zero exit, a recognisable message and no `compose.local.yaml`.

## Caveats

- **One case, one fixture.** `apply.sh` collects errors and reports them together, so a shared fixture hides which rule fired.
- **These cases can be added a few at a time.** The task doesn't have to land as one change.
- **Unset `$VAR` references stay warning-only**, as Task 2 notes. Assert the warning, not a failure.
- **If `docs/plan/workspace-layout.md` is implemented**, several expected targets change. Keep them in one helper.

Recommended model: Claude Sonnet 5.5. Claude Haiku 5.5 is enough once Task 1's helpers exist.
