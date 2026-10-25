# How the devcontainer alternatives were discovered and checked

This document records the research conducted on 24 October 2026 for [the comparison report](devcontainer-alternatives-2026-10-24.md). The companion [source snapshot file](devcontainer-source-snapshots-2026-10-24.json) identifies the downloaded repository commits and GitHub metadata.

It was written retrospectively from the tool calls and returned results in this conversation. The search terms below are the actual submitted strings. The account records the observable research actions and the evidence used to select follow-ups; it is not a verbatim internal reasoning transcript.

## Tools actually used

| Tool or interface | How it was used | What it did not establish |
|---|---|---|
| `web__run`, called through `functions.exec` | Public web searches using `search_query`; direct reading of GitHub, raw source, Marketplace and official documentation using `open` | The search provider did not identify its underlying engine. This was not an exhaustive GitHub or Marketplace catalogue search. |
| `exec_command` | Ran local file discovery, reads, Git commands and Python scripts | Commands inspected files and downloaded sources; they did not build or run the candidate environments. |
| `rg` / `rg --files` | Located this repo's configuration, then searched downloaded candidates for persistence, credentials, Docker and telemetry implementations | A missing search match is weaker evidence than a runtime test or a complete code audit. |
| `cat`, `sed`, `head` and Python file reads | Read complete short configuration files and selected sections of longer files | Some large outputs were truncated, prompting narrower searches and reads. Not every file in every repository was read. |
| `git clone --depth=1` | Downloaded 15 public repository snapshots into `/private/tmp/metarepo-research-20261024/` | Shallow clones provided the checked-out default branch, not a complete history or audit of all branches. |
| `git log`, `git rev-parse`, `git remote get-url` | Recorded commit IDs, commit dates and repository origins | A default-branch commit date is not the same as the latest push, release date or support status. |
| Python `urllib.request` against GitHub's public REST API | Read repository metadata: stars, forks, archive state, default branch, license detection and last push | GitHub's automatic license identification was checked against license files where needed. |
| `apply_patch` and Python | Wrote the report, source manifest, and this process document; checked references and source paths | These were documentation operations, not implementation changes to the devcontainer. |

`functions.exec` was the orchestration interface. Some independent tool calls were batched with `Promise.allSettled`; no research subagents were spawned.

I did **not** use browser UI automation, GitHub's native code-search API, a GitHub connector, the VS Code extension's search UI, or the Marketplace catalogue API. “Scanned GitHub and Marketplace” means public web discovery, reading their pages, and inspecting selected repository clones. I discovered the available search-service tool in the tool inventory, but the searches themselves used `web__run`.

## Establishing what to compare

Before searching, I inspected this repository rather than relying only on the requested feature list.

The first command used `rg --files` to find `AGENTS.md`, `DECISIONS.md`, README files, YAML/JSON, Dockerfiles and shell scripts. A subsequent hidden-file inventory exposed `.devcontainer/`, `.root/` and `.agents/`.

I read these files or relevant excerpts:

- `AGENTS.md`, `DECISIONS.md` and `README.md` for the brief and design decisions.
- `.devcontainer/devcontainer.json`, `compose.yaml`, `Dockerfile` and `docker-entrypoint.sh` for the actual container, tools and volumes.
- `apply.sh`, particularly matches for mounts, agent state and configuration generation.
- `.root/` instructions and `.agents/skills/meta-repo-admin/SKILL.md` for the intended environment administration workflow.

The reads established the comparison baseline: selected sibling host repositories mounted into one container; named volumes for agent state; shared/local configuration; official DinD; and installed agent/development tools. They also showed why OTel and complete host-auth isolation had to remain separate requirements instead of being assumed from “is a devcontainer.”

## Search record

The following 17 search batches contain 53 query strings. They follow the order of the web search calls. Direct page opens, local source reads and cloning were interleaved with these searches and are described in the follow-up column or the later source-inspection sections.

Several queries were submitted in a single call. The returned results were combined, so I cannot reliably attribute every returned URL to one particular query within its batch. Results below therefore describe the batch, not a claimed per-query ranking. The search was adaptive rather than a predefined systematic review.

### 1. Broad discovery: devcontainers, agents and OTel

```text
devcontainer coding agents opentelemetry persistent sessions docker in docker template
github devcontainer claude code codex multi repo telemetry otel
```

**Returned leads:** Trail of Bits' Claude devcontainer; KB1SLN-Labs/agent-observability; context-labs/otel-interceptor; Microsoft agent-monitoring documentation; discussions of Claude telemetry.

**Next action:** Kept Trail of Bits as an environment candidate and the observability projects as possible add-ons. Continued searching for actual environment templates, because a telemetry backend alone does not provide the requested workspace.

### 2. Separate GitHub implementations from Marketplace products

```text
github devcontainer claude "telemetry" "docker"
github "devcontainer" "otel-collector"
site:marketplace.visualstudio.com devcontainer agent container
github devcontainer multi repository agent persistent credentials
```

**Returned leads:** DevContainer Toolbox's background-service monitoring, Docker Sandboxes isolation documentation, Claude devcontainer material and monitoring examples. The combined output was long and partly truncated.

**Next action:** Narrowed the next queries to exact combinations of OTel, multi-repo and agents. Toolbox and Docker Sandboxes remained leads to inspect, rather than verified matches.

### 3. Find explicit multi-repo and agent-OTel claims

```text
"devcontainer" "OpenTelemetry" "claude" -site:reddit.com -filetype:pdf
"devcontainer" "multi-repo" "agent" -site:reddit.com
site:marketplace.visualstudio.com "devcontainer" "agent"
```

**Returned leads:** Centminmod's devcontainer with an OTel integration section; Polyforge's explicit polyrepo orchestration; MadhavM-117/agent-devcontainer's shared-workspace pattern; Toolbox; Flotilla; an OpenSWE/DevPod multi-repo write-up; a Claude extension OTel issue.

**Next action:** Promoted Centminmod and Polyforge for source inspection. Flotilla became a Marketplace workflow add-on to evaluate. The OTel issue was evidence that CLI and IDE behavior might differ, not a basis for declaring a feature absent across all versions.

### 4. Look for persistence, credential handling and broader platforms

```text
site:github.com "devcontainer" "agent" "opentelemetry" "persistent"
site:github.com "devcontainer" "credential" "telemetry" "docker-in-docker"
site:marketplace.visualstudio.com "container" "Claude" "persistent"
devcontainer agent template "DevPod" "DevZero" "DevGuard"
```

**Returned leads:** Sandbox Console; Centminmod persistence and OTel material; other agent/container projects and documentation. Some hits were peripheral, such as an HPC-oriented extension and application-agent templates.

**Next action:** Opened the main GitHub pages for Trail of Bits, Centminmod and Polyforge, plus Toolbox's website. Then opened raw `devcontainer.json` and Dockerfile sources to compare claims with configuration.

### 5. Search specifically for DinD, persistence and a broader solution catalogue

```text
github "devcontainer" "persistent" "docker-in-docker" "claude"
github "devcontainer" "multi-repo" "telemetry"
"DevContainer Toolbox" "persistent" "git"
"agent sandbox" "devcontainer" "otel"
```

**Returned leads:** A community catalogue of Claude container approaches; BranchBox's development setup; Clawker; Toolbox's Docker socket investigation; ClaudeBox and other container wrappers through the catalogue.

**Next action:** Used the catalogue for discovery only. Followed up on projects through their own pages and source. Clawker was retained because it explicitly combined agent containers and OTLP monitoring. BranchBox remained adjacent background material rather than a shortlisted shared-workspace replacement.

### 6. Expand the template and credential-isolation search

```text
"devcontainer" "otel" "sandbox" -site:reddit.com -filetype:pdf -site:stackoverflow.com
"devcontainer" "telemetry" "multi" "template" agent -filetype:pdf -site:reddit.com
"agentbox" "devcontainer" github
"devcontainer" "persistent" "credentials" "agent" template github
```

**Returned leads:** Several unrelated projects named agentbox, including kevinveenbirkenbach/agentbox and auyer/agentbox; Matt Olson's Agent Sandbox; CodeForge; gatezh/devcontainers; ddev-agents.

**Next action:** Distinguished the agentbox projects by owner rather than treating the name as one product. Selected Kevin's version for its configuration layers, persistent home and additional repository mounting. Opened Matt Olson's project, CodeForge, Clawker and Toolbox. Read raw READMEs where GitHub's rendered navigation obscured useful content.

### 7. Check multi-repo prior art and template distribution

```text
"devcontainer" "multi-repo" template GitHub -site:reddit.com -filetype:pdf
"devcontainer" "opentelemetry" "template" -site:reddit.com -filetype:pdf
site:marketplace.visualstudio.com "devcontainer" "sandbox"
site:marketplace.visualstudio.com "DevPod"
```

**Returned leads:** ComposableSecurity's sandbox template; the archived Codespaces multi-repo example; a Red Hat multi-repo workflow article; Coder integration documentation; infrastructure-specific examples.

**Next action:** Retained the archived Codespaces example as historical prior art and Coder as a platform candidate. Did not count multiple containers per workspace as satisfying multiple repositories in one container. The ComposableSecurity and Madhav templates remained additional leads; they were not independently cloned and audited.

### 8. Verify credential forwarding and Copilot OTel against primary sources

```text
dev containers disable SSH agent forwarding enableAgentForwarding copyGitConfig gitCredentialHelperConfigLocation settings
VS Code Copilot OpenTelemetry agent telemetry configuration official
DevPod git credentials forwarding disable GIT_CREDENTIALS
site:marketplace.visualstudio.com devcontainer manager
```

**Returned leads:** Microsoft's credential-sharing documentation; VS Code's agent OTel guide; GitHub's OTel documentation; DevPod's credential-reuse page and documented opt-out.

**Next action:** Read the official pages and compared them with the candidate configurations. This supported two distinctions: VS Code can reuse host authentication automatically, and Copilot has native OTel support even when a template has not configured it.

### 9. Check DevPod maintenance and search again for management products

```text
"DevPod" "archived" 2026 github
site:marketplace.visualstudio.com "DevPod" extension
site:marketplace.visualstudio.com "Dev Container" "Manager"
"devcontainer" "OTEL" "persistent" "docker-in-docker"
```

**Returned leads:** Third-party maintenance comparisons; an archived agent-oriented DevPod starter; the original DevPod project; Toolbox networking material; some unrelated “DevPod” terminology.

**Next action:** Did not accept third-party maintenance claims as final. Later checked GitHub's repository metadata for the original project and skevetter's fork. Ran a single, more focused Marketplace query next because the combined results were dominated by other topics.

### 10. Focused Marketplace search for devcontainer managers

```text
site:marketplace.visualstudio.com/items "devcontainer" "manager"
```

**Returned leads:** Project Containers Manager; DevContainer Template Manager; Apple Container Manager; Nix DevContainer and other specialized extensions.

**Next action:** Selected Project Containers Manager because its listing explicitly addressed agent home/session persistence through rebuilds. Read the listing, extracted its GitHub source link, cloned the source, and inspected the generated configuration and default Dockerfile. Retained Template Manager as a distribution utility rather than a complete environment.

### 11. Focused Marketplace search for agent telemetry

```text
site:marketplace.visualstudio.com/items "devcontainer" "agent" "telemetry"
```

**Returned leads:** Flotilla, Git Graph Libre, Navy AI Coder, Copilot Cost Analyzer and several assistant extensions.

**Next action:** Classified these by function. Flotilla manages worktrees and chat associations within an existing environment; extension usage analytics and cost displays do not automatically provide the requested agent OTLP collection pipeline. These results did not reveal a verified all-nine bundle.

### 12. Broaden to agent runtimes with nested Docker

```text
github agent devcontainer template "OpenTelemetry" -opentelemetry-cpp -site:reddit.com -filetype:pdf
github "devcontainer" "agent" "DinD"
"ContainAI" devcontainer telemetry
"agentic" "devcontainer" template persistence
```

**Returned leads:** More agentbox material; an o3s author post describing multiple repositories and DinD; a ContainAI fork; agent-auth; agentic development configuration write-ups.

**Next action:** Followed the o3s lead rather than relying on the post's claims. The ContainAI name also produced an unrelated ethical-AI project, so repository identity mattered; I subsequently inspected upstream `novotnyllc/ContainAI` rather than assuming every name match was the same software.

### 13. Resolve o3s to its primary source

```text
o3s devcontainer github telemetry
site:github.com "devcontainer" "otel" "multi-repo"
site:github.com "devcontainer" "opentelemetry" "credentials" -opentelemetry-cpp
```

**Returned leads:** The o3s author post and related workflow discussions; Centminmod again; unrelated OpenTelemetry library content.

**Next action:** Opened [the author post](https://www.reddit.com/r/ClaudeCode/comments/1v7f8zk/ever_nervous_running_claude_code_on_your_machine/) and followed its explicit link to [Hansehart/o3s](https://github.com/Hansehart/o3s). Cloned o3s, read its README, devcontainer, Compose and base image, then cloned its separate feature repository to verify the persistence and rootless Docker implementation. This late-discovered project became the closest architectural comparison.

### 14. Test whether the Git settings cover SSH forwarding

```text
"dev.containers.enableAgentForwarding"
"dev.containers.copyGitConfig" "scope"
"dev.containers.gitCredentialHelperConfigLocation" "none"
```

**Returned leads:** Microsoft's issue #9897 about SSH remaining available despite credential-helper settings; a detailed isolation guide; examples of the settings; agentcage documentation.

**Next action:** Kept the Microsoft documentation and issue as the principal evidence. Checked candidate files for actual SSH/config behavior rather than inventing an `enableAgentForwarding` setting from the search term. Also inspected Kevin's generated SSH block and gatezh's Git command-scope overrides.

### 15. Compare platform OTel, persistence and Docker behavior

```text
site:coder.com/docs "OpenTelemetry" "Claude"
site:coder.com/docs "devcontainer" "persistent"
site:docs.docker.com/ai/sandboxes "multiple" "workspaces"
site:docs.docker.com/ai/sandboxes "Docker daemon"
```

**Returned leads:** Docker Sandboxes usage, environment-file, development, architecture, lifecycle, security-default and release documentation. The combined response was dominated by Docker pages.

**Next action:** Read Docker's primary documentation to distinguish private-engine support and multiple mounts from rebuild persistence. Ran a separate Coder-only query to avoid concluding that the lack of Coder results in this batch meant the feature did not exist.

### 16. Focused Coder OTel search

```text
site:coder.com "OpenTelemetry" "Claude"
```

**Returned leads:** Coder's official Claude Code Registry module, including its `telemetry` variable, and AI Gateway monitoring documentation.

**Next action:** Read the module's variable/source presentation and its telemetry configuration. Distinguished agent telemetry from gateway traces and from Coder's devcontainer provisioning. This made Coder a stronger platform option, without establishing a ready-made shared polyrepo template.

### 17. Verify VS Code session-storage assumptions

```text
site:github.com/microsoft/vscode "workspaceStorage" "chatSessions"
site:github.com/microsoft/vscode "agentSessionData"
site:github.com/microsoft/vscode-remote-release "SSH_AUTH_SOCK" "disable" forwarding
```

**Returned leads:** VS Code issues about workspace-scoped chat history, orphaned/missing transcripts and changes in workspace identity; agent-host storage documentation; credential-forwarding material.

**Next action:** Used these to qualify the persistence assessment. A named volume for one agent directory does not demonstrate that every chat UI's backing data is covered. I did not turn the issue reports into a claim that this repo definitely loses chats: its actual host/server arrangement was not tested.

## Direct page reading after discovery

Search results were used to find candidates; the next step was normally to open the project's own page or source. Significant direct reads included:

| Area | Pages or files opened | Purpose |
|---|---|---|
| Initial templates | GitHub pages for Trail of Bits, Centminmod and Polyforge; raw Trail of Bits `devcontainer.json`/Dockerfile; raw Centminmod config | Verify mounts, tools, env and Docker features beyond snippets |
| Additional environments | Toolbox website/GitHub; Matt Olson's, Clawker's and CodeForge's GitHub pages; raw READMEs where available | Decide which projects warranted cloning and detailed inspection |
| Marketplace | Dev Containers, Sandbox Console, Flotilla and Project Containers Manager listings; Template Manager through returned listing content | Establish what each extension actually manages and whether it provisions an environment |
| o3s discovery | Author post, then o3s GitHub and source | Resolve a social/discussion lead to inspectable implementation |
| Agent reference | [Anthropic devcontainer documentation](https://code.claude.com/docs/en/devcontainer) and [monitoring documentation](https://code.claude.com/docs/en/monitoring-usage) | Check reference persistence and native OTel configuration |
| Host auth | [Microsoft credential-sharing guide](https://code.visualstudio.com/remote/advancedcontainers/sharing-git-credentials) | Verify helper reuse and SSH-agent forwarding are separate from file mounts |
| Docker Sandboxes | Overview, usage, environment files, development, isolation, credential handling and related returned docs | Check multi-workspace support, private Docker, lifecycle and forwarding defaults |
| Coder | [Dev Containers overview](https://coder.com/docs/admin/integrations/devcontainers), integration page and [Claude module](https://registry.coder.com/modules/coder/claude-code?tab=variables) | Separate shared-container requirements from platform capabilities |
| Other options | DevPod original/fork, Dagger Container Use, archived Codespaces multi-repo example, Grafana docker-otel-lgtm, Dev Container Features catalogue | Check adjacent approaches and reusable components |

I did not open every page linked from each README. Some content was visible only as a search-result excerpt; the stronger conclusions came from primary documentation or the cloned sources listed next.

## Why the research switched to local source inspection

Rendered GitHub pages often returned large navigation sections, and some raw-source requests failed with a cache miss. Web results also reflected different crawl dates. I therefore downloaded candidate repositories and inspected a known commit locally.

An initial Python request to `raw.githubusercontent.com` failed because the restricted shell could not resolve the host. The same public-source request succeeded with network-enabled execution. Subsequent cloning and GitHub metadata reads used that execution mode. No candidate installation scripts were executed.

The downloads happened in three groups:

1. Trail of Bits, Centminmod, Polyforge, Toolbox, Matt Olson's Agent Sandbox, Kevin's agentbox, CodeForge, Clawker and Anthropic's reference repository.
2. o3s, upstream ContainAI, agent-observability and gatezh/devcontainers.
3. Hansehart/devcontainer-features and Project Containers Manager, to inspect the implementation behind promising configurations/listings.

The command shape was:

```sh
git clone --depth=1 https://github.com/OWNER/REPOSITORY.git \
  /private/tmp/metarepo-research-20261024/OWNER-REPOSITORY
```

Local searches included these actual patterns, combined in several `rg` calls:

```text
credential|otel|telemetry|sudo|mount|claude|copilot|agentSession|globalStorage
otel|opentelemetry|multi.repo|docker.in.docker|docker.sock|credential|forward.*agent|enableAgent|sudo|persistent|persist|volume|workspaceStorage
stateDir|CLAUDE_CONFIG_DIR|CODEX_HOME|sudo|credentialHelperConfigLocation|copyGitConfig|SSH_AUTH_SOCK|ForwardAgent|enableAgent|otel|opentelemetry|workspaceStorage|globalStorage|agentSessionData|docker.in.docker|docker.sock|envFile
```

Broad recursive searches sometimes returned excessive matches, particularly implementation plans and changelogs. I then narrowed searches to actual configuration, template generators, Dockerfiles, relevant README sections and selected scripts. The findings should therefore be read as targeted implementation review, not a complete audit of every downloaded project.

## What was inspected in each downloaded repository

“Inspected” here includes full short-file reads, selected line ranges and search matches. Commit links are recorded in the source snapshot file; this table describes which evidence mattered.

| Repository | Files or excerpts inspected | Effect on the comparison |
|---|---|---|
| [trailofbits/claude-code-devcontainer](https://github.com/trailofbits/claude-code-devcontainer/tree/feea113719e50c8820ce5d0f11f2b0abb01d32a4) | README shared-workspace and isolation sections; `devcontainer.json`; Dockerfile; `post_install.py`; matches in `install.sh` | Confirmed grouped repositories, Claude/gh volumes and installed tools; README explicitly acknowledged forwarded SSH authentication; no DinD or OTel in the config |
| [centminmod/claude-code-devcontainers](https://github.com/centminmod/claude-code-devcontainers/tree/bc67b148e0371eb5616b7dea7bb644c2079fabee) | README OTel/persistence material; `.devcontainer/devcontainer.json`; Dockerfile; telemetry template and initialization-script matches | Confirmed many persisted tool/agent directories and optional OTel variables; found no DinD feature; sudo restricted to setup commands |
| [qte77/polyforge-orchestrator](https://github.com/qte77/polyforge-orchestrator/tree/319820adf3e940e711d4f6d710c68094d2946fa9) | README; `.devcontainer/devcontainer.json`; `docs/codespaces.md`; cross-repo setup matches; `scripts/link-claude-home.sh` | Confirmed actual DinD and multi-repo setup; found documented persistence gaps and workspace-layout assumptions |
| [helpers-no/devcontainer-toolbox](https://github.com/helpers-no/devcontainer-toolbox/tree/994beac5244e551cfad89eb85e7446546f6e9cfe) | README; developer config; `devcontainer-user-template.json`; OTel lifecycle/metrics YAML and related script matches | Distinguished the user template from the project's own development config; confirmed host-socket Docker and environment/system monitoring |
| [mattolson/agent-sandbox](https://github.com/mattolson/agent-sandbox/tree/ea9d9ed82a197d07d98c6d1163bdb427243997f1) | README; generated Claude devcontainer; Compose base/mode templates; base image/entrypoint matches; Claude docs and operating-constraints skill | Confirmed proxy-held secrets and per-agent persistence; found limited sudo/network policy, with no nested daemon in the inspected stack |
| [kevinveenbirkenbach/agentbox](https://github.com/kevinveenbirkenbach/agentbox/tree/4e25cccee98b9e2693edadb4349ed2b9d72bf29c) | README; `src/agentbox/share/devcontainer.base.json`; `config.py` SSH/config generation; `cli.py` matches | Resolved the README's introductory private-Docker claim against its later optional-DinD caveat and the actual base; confirmed home volume and extra mounts |
| [AnExiledDev/CodeForge](https://github.com/AnExiledDev/CodeForge/tree/fd4c66ca6e3e099a4ad3734aabea530255ea484c) | Devcontainer definition; setup/auth script matches; tool/environment/change documentation excerpts; `LICENSE.txt` | Confirmed rich tools and Claude/Codex volumes; found docker-outside-of-docker; checked the actual license text when API detection was inconclusive |
| [schmitthub/clawker](https://github.com/schmitthub/clawker/tree/9713e400639e960c674fdbe05e258166f2b2aebf) | README, particularly monitoring, durable state and credential-forwarding sections | Retained as an OTel-capable adjacent runtime rather than a verified standard shared polyrepo devcontainer |
| [anthropics/claude-code](https://github.com/anthropics/claude-code/tree/318b7e6ac4e726e88a4ad326214866a93c373b1b) | `.devcontainer/devcontainer.json`; Dockerfile matches, supplemented by official devcontainer docs | Established the reference pattern for Claude persistence and restricted privileged setup; no bundled DinD or OTel receiver |
| [Hansehart/o3s](https://github.com/Hansehart/o3s/tree/221f933fbd5640609a28ebcc132e81a0d2480ada) | README; `.devcontainer/devcontainer.json`; Compose; base Dockerfile; lifecycle/cage script matches | Confirmed shared projects and feature volumes, rootless-Docker feature declaration, optional Node and absent configured OTel |
| [Hansehart/devcontainer-features](https://github.com/Hansehart/devcontainer-features/tree/dc7981b0a1464ca4791e86be15eb333b668ec2ff) | Claude/Codex install/init/state-dir files; Docker feature definition/install/init matches; Node feature matches | Verified that o3s state directories map to agent homes/config and that its Docker feature actually provisions a rootless daemon |
| [novotnyllc/ContainAI](https://github.com/novotnyllc/ContainAI/tree/0a4e8add4d7804ef96586e69d94cc780fa13e410) | README and source/config file inventory | Established persistent/ephemeral Sysbox runtime and nested Docker as adjacent architecture; did not perform a complete source audit |
| [KB1SLN-Labs/agent-observability](https://github.com/KB1SLN-Labs/agent-observability/tree/2c279dbde1b45845d1b52df19203e9081d6d7bfb) | README, configuration/deployment inventory and monitoring-related matches | Confirmed a reusable collector/backend/dashboard stack rather than an environment replacement |
| [gatezh/devcontainers](https://github.com/gatezh/devcontainers/tree/f84ccbd8e3d426ca9e6c3c19085a4859d0e52b86) | Root and Claude READMEs; sandbox `devcontainer.json` | Found explicit command-scope HTTPS Git helper overrides and separate state volumes; did not treat those overrides as disabling SSH-agent forwarding |
| [jkudo/project-containers-manager](https://github.com/jkudo/project-containers-manager/tree/81722a37dfbb469c627e0b077e3357a75e43f927) | README/listing; `extension.js` generator around `devcontainerJson` and `envComposeYaml`; default Dockerfile; file inventory | Verified the whole-home/source volumes, Node and passwordless sudo; found no explicit auth opt-out, DinD or OTel in generated defaults |

## Metadata and maintenance checks

I requested `https://api.github.com/repos/OWNER/REPOSITORY` using Python and a research User-Agent. The fields collected were:

```text
stargazers_count
forks_count
archived
default_branch
license.spdx_id
pushed_at
html_url
```

The metadata request covered the main candidates, DevPod and its fork, and the archived Codespaces example. The two supporting repositories cloned last did not receive the same metadata request; their snapshot entries therefore contain empty metadata objects. Anthropic's downloaded reference also has no metadata object from that batch. Empty metadata means “not captured,” not zero stars or no license.

For downloaded sources I separately ran:

```sh
git log -1 --format='%H %cs %s'
git rev-parse HEAD
git remote get-url origin
```

This separation mattered when a repository's last push was later than its checked-out default-branch commit. I also read CodeForge's actual license file rather than treating GitHub's `NOASSERTION` value as the license. For Centminmod and agent-observability, I reported that no explicit license was identified in the inspected snapshot, without inventing permission to reuse their code.

To locate Project Containers Manager's source, I fetched the public Marketplace listing and extracted its GitHub links. This was a page read, not use of the Marketplace catalogue API.

## Failed requests, incomplete leads and corrections

These are included because they explain the route taken and the limits of the evidence:

- Raw GitHub reads for some files, including Polyforge's config, Toolbox's README and CodeForge's README, returned cache-miss errors. Cloned sources became the stronger evidence.
- An attempted Marketplace URL for `3timeslazy.vscodium-devpodcontainers` was inaccessible. It was not treated as a verified listing or included as a recommendation.
- Attempts to open Docker's `/ai/sandboxes/features/` and a Coder registry template path were inaccessible. Later searches found the relevant current documentation and official module pages.
- The initial shell HTTP request failed due to DNS restrictions; it did not mean the public repository or file was unavailable.
- Some broad shell searches referred to nonexistent candidate subdirectories. I corrected the scope after listing files, such as inspecting Project Containers Manager's root `extension.js` and `media/template/` rather than an assumed `src/`/`templates/` layout.
- Search results repeatedly mixed coding-agent telemetry with telemetry libraries, application-agent starters, extension analytics and unrelated projects. Those were discovery noise, not evidence of a match.
- The o3s lead came from a discussion post, but its technical assessment came from the project and supporting feature source.
- Kevin's agentbox introduction initially appeared to imply default DinD. Its later README section and actual base configuration showed that the feature was optional; the report records that limitation.
- Toolbox's OTel branding initially looked promising for agent monitoring. The inspected collector configuration established environment/lifecycle monitoring, so I did not count it as configured coding-agent telemetry.
- Project Containers Manager's full-home persistence made it a strong Marketplace lead, but its generator did not establish host credential isolation. The report kept those as separate findings.

## How the evidence became the final comparison

Each candidate was compared with the same nine requested behaviors. The evidence did not support a single numerical score, because some capabilities depended on the editor, host configuration or a significant change to the workspace model.

The most consequential distinctions were:

| Initial claim or impression | Evidence checked next | Reporting consequence |
|---|---|---|
| “Supports Docker” | Feature identifiers, socket mounts and daemon implementation | Separated DinD, host-socket access and private VM engines |
| “State persists” | Volume targets, agent config directories and documented rebuild behavior | Named the state actually covered and retained gaps for VS Code/Copilot or recreation |
| “Credentials stay on host” | IDE defaults, SSH forwarding and candidate-generated config | Did not equate absent private-key files with absent authentication capability |
| “OTel enabled” | Exporter configuration, receivers and monitored signals | Separated agent export, collector/backend, gateway traces and system metrics |
| “Multi-repo” | Repository manifests, workspace files and mounts | Separated distinct repos in one container from worktrees or several containers |
| “Agent can install tools” | User permissions, sudoers, package-manager paths and persistence | Distinguished user-level installs, system packages and rebuild durability |

This produced the final shortlist: o3s for the overall workspace architecture; Polyforge for repository orchestration; Centminmod for persistence plus optional OTel; Trail of Bits for a small shared-workspace template; Kevin's agentbox for reusable provisioning; and Project Containers Manager for a Marketplace frontend. Coder, Docker Sandboxes and Clawker were retained as larger or adjacent alternatives. The rest supplied comparison evidence or reusable components.

## What was verified before delivery

The original report and JSON were first written under `docs/research/`, then moved to `research/` at the user's request. Before delivery I:

- Recorded all 15 downloaded source commits in the snapshot manifest.
- Checked that the report's reference-style Markdown links had definitions.
- Checked that pinned GitHub source links referred to files present in the corresponding local clones and matched their recorded commit IDs.
- Parsed the JSON manifest and checked Markdown table consistency.
- Inspected repository status so pre-existing user changes stayed separate from the new research documents.

These checks verified document consistency and source traceability. They were not HTTP checks of every outbound link, runtime acceptance tests, security audits, or proof that any candidate satisfies all nine requirements after installation. No candidate environment was built, launched, authenticated or rebuilt during the research.
