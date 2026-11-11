# Task 7: CI Workflows

Added in review. The overview says when each suite runs, and no task set that up.

Add GitHub Actions workflows that:

- Run `./tests/run.sh config` on every pull request and push to main, on Linux and macOS.
- Run `smoke` and `lifecycle` on pushes to main that touch `.devcontainer/`, `apply.sh` or `tests/`, on a weekly schedule, and on manual dispatch.
- Cache the pinned Dev Container CLI.
- Upload the build log when a container suite fails.

Acceptance: a pull request that breaks `apply.sh` fails within a couple of minutes, and a broken image is reported within a week without anyone pushing.

## Caveats

- **macOS runners have no Docker.** The config suite's Compose validation has to skip there, as Task 1 allows. The Linux job must fail if it would skip.
- **The macOS job is what tests bash 3.2 and BSD tools.** That is its whole purpose, so don't install a newer bash on it.
- **Pin `yq`.** Linux runners ship mikefarah `yq`, but the version drifts. macOS runners need it installed.
- **Repos made from this template inherit the workflows.** A scheduled smoke run would then spend minutes in every one. Gate the scheduled job on the repository name, or document how to turn it off.
- **GitHub disables scheduled workflows after 60 days without repository activity.** On a quiet template the weekly run will silently stop.
- **Smoke failures can come from upstream**, since the image installs latest versions. Keep smoke off the required checks for pull requests.
- **Give the container jobs a timeout** of around 30 minutes, and no secrets. They don't need any, and a token would change the entrypoint's behaviour.
- **Path filters on main can miss indirect causes**, such as a change to `meta-repo.yaml` handling. The schedule is the backstop.

Recommended model: Claude Sonnet 5.5.
