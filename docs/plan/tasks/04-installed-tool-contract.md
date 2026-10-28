# Task 4: Installed-Tool Contract

Extend `./tests/run.sh smoke` with a separate container-side tool check covering:

- `git`, `gh`, `node`, `npm`, `nvm`, `bun`, `claude`, and `codex`;
- `dsh`, `pnpm`, and `python3`;
- the Docker client and Docker Compose.

Each tool must resolve and run a lightweight version command. Do not require authentication, network access, or exact versions. Functional Docker-in-Docker remains separate.

