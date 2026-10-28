# Task 1: Config Test Foundation

Create `./tests/run.sh config` that:

- Creates a temporary copy of the template and minimal fixture repositories.
- Runs `apply.sh` inside that fixture.
- Validates the output with `docker compose config`.
- Checks the project name, Git identity, agent-state volumes, repository mount, and a custom persistent volume.
- Cleans up automatically without touching active containers or existing volumes.

Acceptance: the command passes quickly, reports useful failures, and leaves no persistent changes.

