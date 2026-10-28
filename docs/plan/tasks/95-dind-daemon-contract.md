# Task 95: Docker-in-Docker Daemon Contract

Parked for later.

Extend `./tests/run.sh smoke` with a separate DinD check that:

- Runs `docker info` inside the Dev Container.
- Confirms the inner daemon is usable and distinct from the host daemon.
- Does not build images or start inner containers.

