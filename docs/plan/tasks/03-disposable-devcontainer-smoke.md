# Task 3: Disposable Dev Container Smoke Test

Add `./tests/run.sh smoke` that:

- Reuses the isolated fixture setup.
- Bootstraps a pinned standalone Dev Container CLI.
- Runs `devcontainer up --frozen-lockfile`.
- Confirms a container ID, the `vscode` remote user, `/workspace`, and the fixture repository mount.
- Cleans up only the test container and its uniquely named volumes.

Tool, Git, Docker-in-Docker, and persistence checks remain separate tasks.

