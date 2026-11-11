# Task 95: Docker-in-Docker Daemon Contract

Parked for later.

Extend `./tests/run.sh smoke` with a separate DinD check that:

- Runs `docker info` inside the Dev Container.
- Confirms the inner daemon is usable and distinct from the host daemon.
- Does not build images or start inner containers.

## Caveats

- **Wait for the daemon.** The feature starts `dockerd` in the background, so `docker info` can fail for the first few seconds. Poll with a timeout.
- **Define "distinct from the host daemon" concretely.** Compare the `ID` from `docker info` inside and outside. A check for the absence of a mounted `/var/run/docker.sock` is a useful second signal.
- **Confirm the repo's own entrypoint still ran.** The Dev Container CLI wraps the image entrypoint to start the feature. One assertion that an agent-state directory is owned by `vscode` shows both ran.
- **Run as `vscode`**, which proves the user is in the `docker` group.

Recommended model: Claude Sonnet 5.5.
