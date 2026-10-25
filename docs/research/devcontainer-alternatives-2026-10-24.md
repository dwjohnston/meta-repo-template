# Existing setups for an agent-ready, multi-repository devcontainer

Researched 24 October 2026. This compares existing projects with the nine requirements in the request, including requirements this repository does not yet implement.

## Finding

**Several projects already implement substantial parts of this design. I did not verify a ready-to-use setup that satisfies all nine requirements together.** The strongest comparisons are:

| Candidate | Why examine it | Main remaining differences |
|---|---|---|
| [Hansehart/o3s][o3s] | Closest overall workspace architecture: multiple repositories, persistent Claude/Codex state, rootless nested Docker, environment configuration | No agent OTel collection configured; Node is an optional feature; VS Code credential forwarding needs verification |
| [qte77/polyforge-orchestrator][polyforge] | Closest explicit polyrepo workflow: repository list, cloning, generated multi-root workspace, per-repository setup, Node and DinD | Persistence has documented limitations and Codespaces assumptions; credential isolation and OTel need additions |
| [centminmod/claude-code-devcontainers][centminmod] | Closest agent persistence plus telemetry template: several agents, persistent state and optional Claude OTel configuration | No DinD feature; multi-repo requires adaptation; OTel collector is external; no verified host credential opt-out |
| [kevinveenbirkenbach/agentbox][agentbox] | Useful reusable provisioning tool: configuration layering, persistent home, additional repository mounts, optional DinD | DinD is explicitly optional despite the README introduction; no OTel wiring; very small adoption |
| [Trail of Bits’ claude-code-devcontainer][trailofbits] | Established agent-specific template with an explicit shared multi-repo workspace pattern | No DinD or OTel; Claude-focused persistence; SSH forwarding remains relevant |
| [Project Containers Manager][pcm-market] | Closest Marketplace product: creates devcontainers and preserves the complete agent home across rebuilds | Default model is separate containers; no bundled DinD or agent OTel; IDE credential forwarding not disabled in generated config |

**My recommendation:** retain this repository if its selective mounts and shared/local YAML configuration are valuable. Borrow individual components from these projects. Evaluate o3s first if replacing the workspace architecture is acceptable, and Polyforge if repository onboarding and per-repository lifecycle automation are the larger problem. These are judgments from the comparisons below, not runtime benchmarks.

## Scope and evidence

I read this repository’s `AGENTS.md`, `DECISIONS.md`, `README.md`, generator, Dockerfile, Compose definition, devcontainer configuration and entrypoint. I searched GitHub, VS Code Marketplace, the Dev Container Features catalogue, and vendor documentation. I downloaded 15 public repositories for source inspection, including two supporting feature/extension repositories, and checked additional products through their primary documentation.

The evidence includes configuration files, volume definitions, installation scripts and generated-config code. **I did not build or launch the candidate environments, sign in, or perform destructive rebuild tests.** “Present” below means visible in inspected source or explicitly documented, with limitations stated. “Not found” means no implementation was identified in the inspected setup; it is not a claim that the platform cannot support it.

Definitions used throughout:

- **Multi-repo** means distinct Git repositories accessible inside the same development container. Multiple containers or several worktrees of one repository do not automatically qualify.
- **Persistence** means storage outside the disposable container layer. Stop/start persistence alone does not establish rebuild/recreation persistence.
- **Host credential isolation** includes HTTPS helpers, Git/IDE askpass bridges, SSH-agent sockets and explicitly mounted credential files. Keeping private key files on the host alone does not satisfy the requirement.
- **DinD** means a separate nested Docker daemon. Mounting the host Docker socket is identified separately.
- **Agent OTel** means exporting coding-agent activity to a user-selected OTLP receiver. Container CPU metrics, vendor product analytics and transcript dashboards are separate capabilities.
- **Install tools** distinguishes user-owned installations from unrestricted system package installation. Runtime installs only survive rebuilds if their storage is persisted or their installation is reproduced.

## What the current repository already provides

This is a static observation, not a completed acceptance test.

| Requirement | Evidence in this repository |
|---|---|
| Devcontainer | `.devcontainer/devcontainer.json` selects the Compose `dev` service. |
| Several separate repositories | `apply.sh` generates a bind mount for each configured folder under `/workspace`. |
| Sessions survive rebuilds | Named volumes cover Claude, Copilot and selected VS Code paths; the entrypoint handles ownership and `.claude.json`. Codex is installed, but no dedicated `.codex` state volume appears in the static Compose definition. Completeness for every VS Code chat type remains unverified. |
| Environment injection | Shared/local configuration merging and Compose variable resolution are implemented. |
| Host Git credentials not automatically inherited | `copyGitConfig: false` and `gitCredentialHelperConfigLocation: "none"` are configured. This does not demonstrate that SSH forwarding or every IDE authentication bridge is disabled. |
| Docker-in-Docker | The official `docker-in-docker:2` feature is declared. |
| Initial tools | Dockerfile installs Node through nvm, Bun, GitHub CLI, Claude Code and Codex. |
| Agent can add tools | Writable user tool locations and an admin workflow for permanent image changes exist. Runtime additions outside persisted storage are disposable. |
| Agent OTel collection | No collector service or exporter configuration was found in the inspected committed environment files. |

The session-storage and credential details matter for alternatives too. Microsoft documents automatic credential-helper reuse and SSH-agent forwarding in Dev Containers. VS Code issue reports also show that classic chat transcripts can live in `workspaceStorage`, alongside newer agent-session storage mechanisms. This repository does not explicitly persist `User/workspaceStorage`; whether that affects its actual client/server arrangement needs a runtime check. [Microsoft credential documentation][vscode-git], [VS Code chat-storage issue][vscode-chat-storage].

## Comparison against all nine requirements

The tables split infrastructure from agent behavior to keep the comparison readable. **Add** means feasible through ordinary customization but not provided by the inspected default. **Partial** identifies a material limitation. **Unverified** is deliberately not a pass.

### Container and workspace requirements

| Setup | Devcontainer | Several repos in one container | Environment variables | Separate Docker daemon | Initial development tools |
|---|---|---|---|---|---|
| [o3s][o3s-config] | Present | Present; project volume and multi-root workspace | Present; Compose `.env` | Present; rootless feature | Agents and base tools; Node feature commented out |
| [Polyforge][polyforge-config] | Present | Present; repository manifest and generated workspace | Present; `containerEnv` and secrets | Present; official DinD feature | Node, gh, Claude and shared tools |
| [Centminmod][centminmod-config] | Present | Add parent-workspace layout or mounts | Present; env file and configuration | Not found | Node 22 base, Bun, Python and several agents |
| [Trail of Bits][trailofbits-config] | Present | Documented shared parent workspace | Present; forwarded agent-auth variables | Not found | Node, Python/uv, gh, Claude, build utilities |
| [Kevin’s agentbox][agentbox-base] | Present; standard CLI plus SSH editor connection | Present through `agentbox mount` | Present; merged `containerEnv` | Optional; declare DinD feature | Node plus configurable agent packages |
| [CodeForge][codeforge-config] | Present | Add repositories under mounted workspace | Present; remote env and explicit secrets | **Host socket**, through docker-outside-of-docker | Python, Node, Bun, uv, gh, Claude, Codex and utilities |
| [Matt Olson’s Agent Sandbox][mattolson-config] | Present | Add mounts through user Compose override | Present; Compose/user overrides | Not found in generated agent stack | Agent-specific images and common tools |
| [Anthropic reference][anthropic-config] | Present | Add parent-workspace layout | Present; standard container env | Not found | Node-based image, Claude and utilities |

### Agent behavior requirements

| Setup | Sessions across rebuilds | Host Git auth not automatically available | Agent can install tools | Agent telemetry through OTel |
|---|---|---|---|---|
| o3s | Claude/Codex state in persistent feature volume; Copilot/VS Code state not configured | Unverified under Dev Containers; explicit proxy secrets do not disable IDE forwarding | User-owned tools; additional image features; general sudo not supplied by inspected base | Not found |
| Polyforge | Partial: Claude directory linked into `/workspaces`; `.claude.json` gap documented; depends on persisted workspace layout | No explicit local IDE opt-out found | User tools and customizable devcontainer | Not found |
| Centminmod | Named volumes for Claude, Codex, Gemini, OpenCode and several tool/config paths; no explicit VS Code chat-storage volumes | No explicit opt-out found | User-level package managers; sudo restricted to setup scripts | Optional Claude exporter config; external collector/network required |
| Trail of Bits | Named Claude state volume with `CLAUDE_CONFIG_DIR`; gh and shell history also persisted | Host Git config is mounted; helper config adjusted, but SSH forwarding remains available | User tools; Microsoft base includes sudo | Not found |
| Kevin’s agentbox | Entire `/home/dev` on a named volume; covers agent state and user-installed tools | Designed without host-home mounts; uses SSH editor connection; ambient SSH forwarding configuration still needs checking | User tools; common-utils user setup | Not found |
| CodeForge | Separate named Claude/Codex volumes; no explicit Copilot session-storage setup | Explicit token setup exists, but generated config does not establish a general IDE forwarding opt-out | Present through package managers and customizable Features | Not found; usage tools are not an OTLP pipeline |
| Matt Olson’s Agent Sandbox | Per-agent state volumes; switching preserves history/config | Proxy keeps supplied secrets out of agent container; attached IDE forwarding not independently ruled out | User-level installs subject to allowlist; no general sudo | Not found in inspected agent stack |
| Anthropic reference | Named Claude state volume and `CLAUDE_CONFIG_DIR` | No explicit IDE forwarding opt-out | User installs; setup has restricted privileged operations | Add native Claude exporter configuration and a receiver |

## Closest projects in detail

### o3s: closest overall workspace design

o3s explicitly puts multiple repositories and worktrees into one VS Code workspace. Its Compose stack separates the working container from an egress gateway and a credential-injection proxy. Projects and feature state use named volumes. The devcontainer declares Claude and Codex state directories inside the persisted feature volume, plus a rootless DinD feature. This is a strong structural match. [Workspace design][o3s-readme], [Compose storage/networking][o3s-compose], [agent configuration][o3s-config].

The inspected default comments out the Node feature and does not configure coding-agent OTel export or a collector. It also does not persist general VS Code/Copilot state. Keeping proxy-managed API tokens outside the container does not establish that VS Code has stopped forwarding host Git authentication. The base is plain Ubuntu with custom AppArmor/seccomp/network assumptions, so platform compatibility deserves testing before adoption. [Base image][o3s-base], [configuration][o3s-config].

Adopting it would change this repo’s model from selectively mounting existing host checkouts to keeping projects in a container-managed volume, unless you adapt its mounts. Its MIT license and recent default-branch activity make it a reasonable evaluation candidate, but its small community means it should be assessed as a maintained personal/team project rather than established infrastructure.

### Polyforge: closest repository orchestration

Polyforge reads `config/repos.conf`, clones repositories, produces a multi-root workspace, and replays sibling repositories’ `onCreateCommand` and `postCreateCommand` hooks inside the shared container. Its devcontainer already includes Node, gh and official DinD. This goes beyond mounting folders and helps when each repository has its own dependency setup. [Project workflow][polyforge], [container definition][polyforge-config].

Its persistence documentation is unusually explicit: a script recreates the link from `~/.claude` into `/workspaces/.claude-files`, while `~/.claude.json` is not covered. The documented workflow relies heavily on Codespaces persistence. Local use needs a deliberate persistent mount for the link target. OTel and host-auth isolation remain additions. [Persistence limitations][polyforge-persistence], [linking script][polyforge-link].

This is the best source to study if improving repository onboarding, dependency initialization and multi-root IDE generation. It is more opinionated about parallel agent workflows than the current meta-repo needs.

### Centminmod: closest persistence and OTel combination

This template installs several agent CLIs and uses named volumes for their state, plus npm globals, Bun, Cargo and user-local tools. Its Claude configuration uses `CLAUDE_CONFIG_DIR`. It provides commented OTel exporter settings and expects an external collector on a specifically named Docker network. **The exporter settings are optional, and the collector is not supplied as part of the devcontainer.** [Volume/exporter definitions][centminmod-config], [integration documentation][centminmod].

Its inspected feature list does not include DinD. It does not provide a repository manifest like this repo’s YAML, and no explicit general host-auth opt-out was identified. Agent installs are writable at user level; sudo is limited to named setup scripts. It also configures prompt-content capture in its example telemetry settings, a choice that should remain explicit. [Dockerfile and privilege setup][centminmod-dockerfile].

The downloaded default branch last changed on 1 January 2026. GitHub did not identify a license, and no root license file was present in that snapshot. It is useful reference material, but I would clarify licensing before copying substantial portions.

### Trail of Bits: reusable shared-workspace template

This project documents both per-project containers and a shared parent directory containing several repositories. It persists Claude state, gh state and shell history, uses `CLAUDE_CONFIG_DIR`, and installs Node, Python/uv and common inspection/build tools. It has substantially more public adoption than the small templates above. [Usage patterns][trailofbits], [configuration][trailofbits-config], [installed tools][trailofbits-dockerfile].

It does not provide DinD or OTel collection. Its read-only host `.gitconfig` mount is not a “no host authentication” mechanism, and its helper/SSH behavior must be assessed separately. It is a good minimal agent template to extend, especially for a parent-directory multi-repo arrangement, but is not a replacement for the current configuration generator.

### Kevin’s agentbox: configuration layering and persistent home

This is a CLI built around the standard Dev Containers CLI, with base, project and gitignored local configuration layers. `agentbox mount ../other-repo` makes another repository available in the same container and updates the workspace. Its named home volume covers sessions, logins and user tools. [Commands and architecture][agentbox], [default configuration][agentbox-base].

The README introduction describes a private Docker daemon, but later documentation explicitly says DinD is **not part of the default configuration**; the actual base file confirms that. You add the feature yourself. Sysbox can provide an alternative runtime when available. No OTel setup was found. [DinD caveat in README][agentbox-readme].

Its use of a remote SSH editor connection can avoid some Dev Containers extension behavior, but the generated SSH host block does not explicitly set `ForwardAgent no`. Host/Remote-SSH settings must still be checked. The repository had no stars in the metadata snapshot; treat it as promising implementation material with limited adoption, not a proven product.

### CodeForge and Matt Olson’s Agent Sandbox

[CodeForge][codeforge] supplies a large curated agent environment, Claude/Codex persistence and numerous development tools. Its Docker feature is **docker-outside-of-docker**, so it does not meet the nested-daemon requirement. Its bundled monitors and session dashboards do not establish OTel collection. It is also a significantly larger opinionated environment. The license file declares GPL-3.0-only with a separate commercial licensing option. [Configuration][codeforge-config], [license text][codeforge-license].

[Matt Olson’s Agent Sandbox][mattolson] offers Compose/devcontainer scaffolding, multiple supported agent images, persistent agent state, and a proxy that can inject explicitly supplied GitHub/model credentials. It is useful for its host-held secret pattern. General sudo is intentionally unavailable, package downloads depend on network policy, and the generated agent stack does not provide DinD or OTel. Extra repositories need user overrides. [Generated Compose base][mattolson-compose], [agent operating constraints][mattolson-constraints].

## VS Code Marketplace findings

| Extension | What it actually provides | Fit for this request |
|---|---|---|
| [Dev Containers][devcontainers-market] | Standard container lifecycle, editor attachment and extension execution | Foundation already used here; does not supply this complete agent policy |
| [Project Containers Manager][pcm-market] | Sidebar, generated Compose/devcontainers, per-environment source and home volumes, Node templates, optional firewall | Closest packaged extension; home persists through rebuild; default organization is containers per project |
| [Sandbox Console][sandbox-console] | VS Code UI over Docker Sandboxes; agent selection, explicit secrets, lifecycle hooks and custom environments | Useful alternative frontend; uses microVMs rather than `devcontainer.json`; stop/resume is not a rebuild guarantee |
| [Flotilla][flotilla] | Worktrees, Claude chat associations, backlog and agent status; works inside existing devcontainers | Workflow add-on; does not provision the requested environment |
| [DevContainer Template Manager][template-manager] | Saves and reapplies `.devcontainer` templates | Distribution convenience; no special persistence, auth or agent OTel implementation |

I checked Project Containers Manager’s source as well as the listing. Its generator mounts `home:/home/dev` and `src:/workspace`, while its default template supplies Node and passwordless sudo. The generated devcontainer has no explicit Git-helper/SSH-forwarding opt-out, no DinD feature and no OTel exporter configuration. “Host filesystem not visible” in a listing should not be read as evidence that editor authentication bridges are disabled. [Generator][pcm-generator], [default Dockerfile][pcm-dockerfile].

No inspected Marketplace listing established all nine requirements as a bundled setup.

## Larger platforms and adjacent alternatives

**Coder is the strongest platform option if you want centrally managed team infrastructure.** It supports standard Dev Containers through Docker/`@devcontainers/cli`, as well as Envbuilder. Its official Claude module has a `telemetry` configuration that enables OTel and attaches workspace identifiers. However, you still need a template that puts several repositories in one container and persists the right agent state. Coder’s documentation for multiple `coder_devcontainer` resources describes separate containers, which does not satisfy the same-container requirement by itself. [Dev Containers approaches][coder-devcontainers], [integration details][coder-integration], [Claude telemetry module][coder-claude].

**DevPod is an environment launcher, not an already-complete agent configuration.** It runs devcontainer definitions on local or remote infrastructure. It automatically injects Git credentials by default, and documents the opt-out `SSH_INJECT_GIT_CREDENTIALS=false`; Docker credential injection is separate. Supply a multi-repo devcontainer, agent volumes and OTel wiring yourself. The original repository’s reported last push was November 2025; the [skevetter fork][devpod-fork] had activity in October 2026. Evaluate the maintenance choice before standardizing. [Credential defaults/opt-out][devpod-credentials], [original project][devpod].

**Docker Sandboxes is the strongest adjacent local runtime if the Dev Container specification is negotiable.** Its microVM has a private Docker Engine, sudo/package installation and configurable multiple workspace mounts. `sbxenv.yaml` can declare repositories, environment and secrets. Persistent VM state survives stop/start; removing/recreating the VM deletes in-VM state, so it does not directly promise this request’s rebuild behavior. Agent OTel still needs explicit configuration. [Multi-workspace configuration][docker-env], [package/Docker capabilities][docker-development], [lifecycle][docker-usage].

Docker’s HTTP credential proxy keeps configured secret values on the host, but its isolation documentation says SSH-agent forwarding is enabled by default. That is another reason not to count “keys stay outside” as meeting the requested default. [Credential isolation and SSH forwarding][docker-isolation].

**ContainAI** provides persistent or ephemeral Sysbox-based environments and unprivileged nested Docker. It is relevant if that runtime architecture is attractive, but the inspected upstream uses its own CLI/configuration rather than a standard devcontainer template, and no agent OTel integration was identified. [Project][containai].

**Clawker** is particularly relevant to the telemetry requirement: its container runtime persists agent config and history and can start an OTel Collector/OpenSearch/Prometheus monitoring stack. It also offers credential forwarding and custom images. It is presented as a devcontainer alternative, and its project/worktree model does not establish the requested shared polyrepo devcontainer. It is worth studying for OTel integration rather than assuming it is a direct replacement. [Inspected README][clawker-readme].

**Dagger Container Use** gives agents separate containerized branches through an MCP server. It addresses independent agent tasks rather than a shared multi-repo IDE environment with persisted CLI sessions. [Project and architecture][container-use].

**The archived Codespaces multi-repo example** demonstrates a bootstrap repo and repository list. It is useful prior art for the meta-repo idea, but supplies no complete modern agent lifecycle/telemetry policy and has been archived since 2024. [Archived example][codespaces-multirepo].

## Reuse the telemetry layer independently

The environment and observability backend do not need to come from the same project.

- [KB1SLN-Labs/agent-observability][agent-observability] supplies an OTel Collector, Prometheus, Loki, Tempo and Grafana with agent-oriented dashboards and Compose/Kubernetes/Helm deployment options. It is a collector/backend add-on, not a devcontainer replacement. No explicit license was identified in the downloaded snapshot.
- [Grafana docker-otel-lgtm][grafana-lgtm] is another reusable development observability backend. It would need agent-specific configuration and dashboards.
- [DevContainer Toolbox][toolbox] has an OTel receiver and lifecycle/system monitoring configuration, plus many installable tools. Its default Docker feature uses the host socket. The inspected OTel configuration focuses on environment monitoring; I did not find equivalent preconfigured Claude/Copilot activity export. [User template][toolbox-template], [collector configuration][toolbox-otel].

For a reusable Git authentication pattern, [gatezh/devcontainers][gatezh-readme] configures command-scope Git settings that clear the forwarded GitHub HTTPS helper and use the container's own `gh` authentication. Its Claude volume and user tool manager are also useful references. This does not, by itself, disable a forwarded SSH-agent socket, and it does not supply the entire requested environment. [Sandbox template][gatezh-config].

Claude Code natively exports metrics and events, with optional tracing. Copilot Chat also now supports OTel export to a selected backend, so Copilot telemetry need not require a custom extension. Each agent still needs its own enablement and endpoint configuration. A collector receiving container-health data alone does not meet the agent telemetry requirement. [Claude monitoring][claude-monitoring], [VS Code agent monitoring][copilot-monitoring].

For this repo, a concrete composition would be its existing shared workspace plus a collector/backend service on a reachable Compose network, agent-specific exporter configuration, and persistent backend storage. Ensure the exporter endpoint is reachable from the process actually running each agent; host-side and container-side `localhost` are different destinations. This is a proposed integration, not something tested in this research.

## Decision

| Priority | Best route from the evidence |
|---|---|
| Keep existing host repositories and selective mounts | Continue this meta-repo; reuse standard Features and a standalone OTel backend |
| Replace the environment with a comparable all-project workspace | Trial o3s, including platform support, Node enablement, session behavior and credential handling |
| Automate setup across many repositories | Study/adapt Polyforge’s manifest and lifecycle handling |
| Start from a small agent-specific template | Trail of Bits, then add DinD, the remaining state volumes and OTel |
| Prefer a Marketplace UI | Trial Project Containers Manager; expect to add multi-repo conventions, DinD, auth policy and OTel |
| Central administration for a team | Coder with a deliberately designed workspace template and its agent telemetry modules |
| Prefer stronger local VM isolation over devcontainer compatibility | Docker Sandboxes, with explicit state migration and SSH-forwarding choices |

The individual building blocks are widely available. The less common combination is **one shared polyrepo container, selective host exposure, independent agent identity, demonstrably complete rebuild persistence, and one configured agent-observability pipeline**. That remains a meaningful purpose for this repo. The next useful validation would be an acceptance trial of o3s and one minimal template against those exact behaviors, rather than replacing the current implementation solely from README claims.

## Source snapshots

These are default-branch commits downloaded for source inspection. Dates are commit dates, not claims about support, release cadence or activity on other branches. Supporting repositories and metadata are included so the findings are reproducible.

| Repository | Commit | Commit date | License identification |
|---|---|---|---|
| [AnExiledDev/CodeForge](https://github.com/AnExiledDev/CodeForge/tree/fd4c66ca6e3e099a4ad3734aabea530255ea484c) | `fd4c66ca6e3e` | 2026-04-16 | GPL-3.0-only / commercial option (LICENSE.txt) |
| [Hansehart/devcontainer-features](https://github.com/Hansehart/devcontainer-features/tree/dc7981b0a1464ca4791e86be15eb333b668ec2ff) | `dc7981b0a146` | 2026-10-22 | MIT |
| [Hansehart/o3s](https://github.com/Hansehart/o3s/tree/221f933fbd5640609a28ebcc132e81a0d2480ada) | `221f933fbd56` | 2026-10-21 | MIT |
| [KB1SLN-Labs/agent-observability](https://github.com/KB1SLN-Labs/agent-observability/tree/2c279dbde1b45845d1b52df19203e9081d6d7bfb) | `2c279dbde1b4` | 2026-06-24 | Not identified |
| [anthropics/claude-code](https://github.com/anthropics/claude-code/tree/318b7e6ac4e726e88a4ad326214866a93c373b1b) | `318b7e6ac4e7` | 2026-10-24 | Not identified |
| [centminmod/claude-code-devcontainers](https://github.com/centminmod/claude-code-devcontainers/tree/bc67b148e0371eb5616b7dea7bb644c2079fabee) | `bc67b148e037` | 2026-01-01 | Not identified |
| [gatezh/devcontainers](https://github.com/gatezh/devcontainers/tree/f84ccbd8e3d426ca9e6c3c19085a4859d0e52b86) | `f84ccbd8e3d4` | 2026-10-24 | Not identified |
| [helpers-no/devcontainer-toolbox](https://github.com/helpers-no/devcontainer-toolbox/tree/994beac5244e551cfad89eb85e7446546f6e9cfe) | `994beac5244e` | 2026-09-25 | MIT |
| [jkudo/project-containers-manager](https://github.com/jkudo/project-containers-manager/tree/81722a37dfbb469c627e0b077e3357a75e43f927) | `81722a37dfbb` | 2026-06-19 | MIT |
| [kevinveenbirkenbach/agentbox](https://github.com/kevinveenbirkenbach/agentbox/tree/4e25cccee98b9e2693edadb4349ed2b9d72bf29c) | `4e25cccee98b` | 2026-08-31 | MIT |
| [mattolson/agent-sandbox](https://github.com/mattolson/agent-sandbox/tree/ea9d9ed82a197d07d98c6d1163bdb427243997f1) | `ea9d9ed82a19` | 2026-10-20 | MIT |
| [novotnyllc/ContainAI](https://github.com/novotnyllc/ContainAI/tree/0a4e8add4d7804ef96586e69d94cc780fa13e410) | `0a4e8add4d78` | 2026-02-06 | MIT |
| [qte77/polyforge-orchestrator](https://github.com/qte77/polyforge-orchestrator/tree/319820adf3e940e711d4f6d710c68094d2946fa9) | `319820adf3e9` | 2026-09-23 | Apache-2.0 |
| [schmitthub/clawker](https://github.com/schmitthub/clawker/tree/9713e400639e960c674fdbe05e258166f2b2aebf) | `9713e400639e` | 2026-10-22 | MIT |
| [trailofbits/claude-code-devcontainer](https://github.com/trailofbits/claude-code-devcontainer/tree/feea113719e50c8820ce5d0f11f2b0abb01d32a4) | `feea113719e5` | 2026-08-28 | Apache-2.0 |

[o3s]: https://github.com/Hansehart/o3s
[o3s-readme]: https://github.com/Hansehart/o3s/blob/221f933fbd5640609a28ebcc132e81a0d2480ada/README.md
[o3s-config]: https://github.com/Hansehart/o3s/blob/221f933fbd5640609a28ebcc132e81a0d2480ada/.devcontainer/devcontainer.json
[o3s-compose]: https://github.com/Hansehart/o3s/blob/221f933fbd5640609a28ebcc132e81a0d2480ada/.devcontainer/compose.yaml
[o3s-base]: https://github.com/Hansehart/o3s/blob/221f933fbd5640609a28ebcc132e81a0d2480ada/images/base/Dockerfile
[polyforge]: https://github.com/qte77/polyforge-orchestrator
[polyforge-config]: https://github.com/qte77/polyforge-orchestrator/blob/319820adf3e940e711d4f6d710c68094d2946fa9/.devcontainer/devcontainer.json
[polyforge-persistence]: https://github.com/qte77/polyforge-orchestrator/blob/319820adf3e940e711d4f6d710c68094d2946fa9/docs/codespaces.md
[polyforge-link]: https://github.com/qte77/polyforge-orchestrator/blob/319820adf3e940e711d4f6d710c68094d2946fa9/scripts/link-claude-home.sh
[centminmod]: https://github.com/centminmod/claude-code-devcontainers
[centminmod-config]: https://github.com/centminmod/claude-code-devcontainers/blob/bc67b148e0371eb5616b7dea7bb644c2079fabee/.devcontainer/devcontainer.json
[centminmod-dockerfile]: https://github.com/centminmod/claude-code-devcontainers/blob/bc67b148e0371eb5616b7dea7bb644c2079fabee/.devcontainer/Dockerfile
[trailofbits]: https://github.com/trailofbits/claude-code-devcontainer
[trailofbits-config]: https://github.com/trailofbits/claude-code-devcontainer/blob/feea113719e50c8820ce5d0f11f2b0abb01d32a4/devcontainer.json
[trailofbits-dockerfile]: https://github.com/trailofbits/claude-code-devcontainer/blob/feea113719e50c8820ce5d0f11f2b0abb01d32a4/Dockerfile
[agentbox]: https://github.com/kevinveenbirkenbach/agentbox
[agentbox-readme]: https://github.com/kevinveenbirkenbach/agentbox/blob/4e25cccee98b9e2693edadb4349ed2b9d72bf29c/README.md
[agentbox-base]: https://github.com/kevinveenbirkenbach/agentbox/blob/4e25cccee98b9e2693edadb4349ed2b9d72bf29c/src/agentbox/share/devcontainer.base.json
[codeforge]: https://github.com/AnExiledDev/CodeForge
[codeforge-config]: https://github.com/AnExiledDev/CodeForge/blob/fd4c66ca6e3e099a4ad3734aabea530255ea484c/container/.devcontainer/devcontainer.json
[codeforge-license]: https://github.com/AnExiledDev/CodeForge/blob/fd4c66ca6e3e099a4ad3734aabea530255ea484c/LICENSE.txt
[mattolson]: https://github.com/mattolson/agent-sandbox
[mattolson-config]: https://github.com/mattolson/agent-sandbox/blob/ea9d9ed82a197d07d98c6d1163bdb427243997f1/internal/embeddata/templates/claude/devcontainer/devcontainer.json
[mattolson-compose]: https://github.com/mattolson/agent-sandbox/blob/ea9d9ed82a197d07d98c6d1163bdb427243997f1/internal/embeddata/templates/compose/base.yml
[mattolson-constraints]: https://github.com/mattolson/agent-sandbox/blob/ea9d9ed82a197d07d98c6d1163bdb427243997f1/images/base/skills/operating-in-agent-sandbox/SKILL.md
[anthropic-config]: https://github.com/anthropics/claude-code/blob/318b7e6ac4e726e88a4ad326214866a93c373b1b/.devcontainer/devcontainer.json
[pcm-market]: https://marketplace.visualstudio.com/items?itemName=jkudo.project-containers-manager
[pcm-generator]: https://github.com/jkudo/project-containers-manager/blob/81722a37dfbb469c627e0b077e3357a75e43f927/extension.js#L1320
[pcm-dockerfile]: https://github.com/jkudo/project-containers-manager/blob/81722a37dfbb469c627e0b077e3357a75e43f927/media/template/Dockerfile
[devcontainers-market]: https://marketplace.visualstudio.com/items?itemName=ms-vscode-remote.remote-containers
[sandbox-console]: https://marketplace.visualstudio.com/items?itemName=ainova-systems.sandbox-console
[flotilla]: https://marketplace.visualstudio.com/items?itemName=Archipelagic.flotilla
[template-manager]: https://marketplace.visualstudio.com/items?itemName=AndrewMitchell.devcontainer-template-manager
[coder-devcontainers]: https://coder.com/docs/admin/integrations/devcontainers
[coder-integration]: https://coder.com/docs/admin/integrations/devcontainers/integration
[coder-claude]: https://registry.coder.com/modules/coder/claude-code?tab=variables
[devpod]: https://github.com/loft-sh/devpod
[devpod-fork]: https://github.com/skevetter/devpod
[devpod-credentials]: https://devpod.sh/docs/developing-in-workspaces/credentials
[docker-env]: https://docs.docker.com/ai/sandboxes/configuration/environment-files
[docker-development]: https://docs.docker.com/ai/sandboxes/workflows/development/
[docker-usage]: https://docs.docker.com/ai/sandboxes/usage/
[docker-isolation]: https://docs.docker.com/ai/sandboxes/security/isolation/
[containai]: https://github.com/novotnyllc/ContainAI
[clawker-readme]: https://github.com/schmitthub/clawker/blob/9713e400639e960c674fdbe05e258166f2b2aebf/README.md
[container-use]: https://github.com/dagger/container-use
[codespaces-multirepo]: https://github.com/codespaces-contrib/codespaces-multi-repo
[agent-observability]: https://github.com/KB1SLN-Labs/agent-observability
[grafana-lgtm]: https://github.com/grafana/docker-otel-lgtm
[toolbox]: https://github.com/helpers-no/devcontainer-toolbox
[toolbox-template]: https://github.com/helpers-no/devcontainer-toolbox/blob/994beac5244e551cfad89eb85e7446546f6e9cfe/devcontainer-user-template.json
[toolbox-otel]: https://github.com/helpers-no/devcontainer-toolbox/blob/994beac5244e551cfad89eb85e7446546f6e9cfe/.devcontainer/additions/otel/otelcol-lifecycle-config.yaml
[gatezh-readme]: https://github.com/gatezh/devcontainers/blob/f84ccbd8e3d426ca9e6c3c19085a4859d0e52b86/claude-code/README.md
[gatezh-config]: https://github.com/gatezh/devcontainers/blob/f84ccbd8e3d426ca9e6c3c19085a4859d0e52b86/claude-code/.devcontainer/claude-sandbox/devcontainer.json
[claude-monitoring]: https://code.claude.com/docs/en/monitoring-usage
[copilot-monitoring]: https://code.visualstudio.com/docs/agents/guides/monitoring-agents
[vscode-git]: https://code.visualstudio.com/remote/advancedcontainers/sharing-git-credentials
[vscode-chat-storage]: https://github.com/microsoft/vscode/issues/334228
