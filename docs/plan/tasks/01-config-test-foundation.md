# Task 1: Config Test Foundation

Create `./tests/run.sh config` that:

- Creates a temporary copy of the template and minimal fixture repositories.
- Runs `apply.sh` inside that fixture.
- Validates the output with `docker compose config`.
- Checks the project name, Git identity, agent-state volumes, repository mount, and a custom persistent volume.
- Cleans up automatically without touching active containers or existing volumes.

Acceptance: the command passes quickly, reports useful failures, and leaves no persistent changes.

## Caveats

- **Replace `meta-repo.yaml` in the copy, don't reuse it.** The committed file lists folders that won't exist under the fixture root, so `apply.sh` fails. Write a minimal fixture config instead, with no `ports`.
- **Copy selectively.** Leave out `.git`, `meta-repo.local.yaml`, `.devcontainer/compose.local.yaml` and `.devcontainer/AGENTS.generated.md`. Never run `apply.sh` in the real checkout: it overwrites the last two.
- **Pin `metarepo_suffix` in the fixture.** Unset, the suffix is a hash of the temporary path and changes every run. Add one separate case that leaves it unset and checks the name matches `<id>-<6 hex chars>`.
- **Give the copy a fixed directory name**, for example `<tmp>/meta-repo-under-test`. Task 2's admin mount target is that name.
- **Resolve the temporary path physically** (`pwd -P`). On macOS `mktemp -d` returns a symlinked path, while `apply.sh` and Compose report the real one.
- **Set `HOME` to a temporary directory and scrub the environment.** `apply.sh` expands `~`, resolves dotfiles against `$HOME`, and warns about unset `$VAR` references.
- **Assert on resolved output.** `compose.local.yaml` holds relative bind sources. Compare against `docker compose config --format json`, which makes them absolute and merges both files.
- **`apply.sh` only warns when Compose rejects the output.** The test has to run `docker compose config` itself and fail on a non-zero exit.
- **Make the Docker step optional locally.** Check structure with `yq` first, and skip Compose validation with a visible notice when Docker is absent. CI must not skip it.
- **Check prerequisites up front.** `apply.sh` needs mikefarah `yq` v4 and rejects the Python wrapper of the same name.
- **Name the five agent-state volumes explicitly:** `copilot`, `vscode-agent-sessions`, `vscode-global-storage`, `claude` and `dsh`. Deriving the list from `compose.yaml` would let an accidental deletion pass.
- **"Leaves no persistent changes" is easy here.** Nothing in this suite creates Docker resources; cleanup is removing one temporary directory in an `EXIT` trap.
- **Stay within bash 3.2 and BSD tools**, as `apply.sh` does.

Recommended model: Claude Opus 5.5.
