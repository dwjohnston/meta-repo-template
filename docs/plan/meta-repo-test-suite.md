# Meta-Repo Test Suite

Build the tests in small layers:

- `./tests/run.sh config` tests `apply.sh` using isolated temporary fixtures.
- `./tests/run.sh smoke` builds a disposable Dev Container and checks its runtime contract.
- `./tests/run.sh lifecycle` rebuilds the container and verifies persistent state survives.
- `./tests/run.sh all` runs every suite; the default remains the fast `config` suite.

The tests must never touch the developer's active container or volumes. Fast config tests run on pull requests; full container tests run on relevant main-branch changes, on a schedule, and manually.

Conversation persistence is tested automatically with sentinel files and manually by resuming real Claude and Copilot conversations. Docker-in-Docker coverage is parked as Tasks 95 and 96.

