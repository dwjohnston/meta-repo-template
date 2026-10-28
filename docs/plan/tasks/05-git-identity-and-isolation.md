# Task 5: Git Identity and Credential Isolation

Extend `./tests/run.sh smoke` with an offline Git contract:

- Assert the configured test name and email.
- Create a temporary repository and verify a commit uses that identity.
- Confirm host Git identity and credential-helper settings were not copied in.
- Confirm `SSH_AUTH_SOCK`, `GIT_ASKPASS`, and `SSH_ASKPASS` are unset.

GitHub login, URL rewriting, credential helpers, and remote access remain separate tasks.

