# maxlab-infra-skills

Agent guidance for MaxLab infrastructure. The current skill covers Babel, CMU's
shared cluster; future GCP/TPU and other infrastructure guidance can live alongside
it.

## Install

```bash
git clone <this repo> ~/maxlab-infra-skills
cd ~/maxlab-infra-skills
./bin/install.sh
```

When explicitly run, the installer links:

- the Babel skill into `~/.agents/skills/` for Codex; and
- the repo into `~/.claude/skills/` for Claude Code.

Symlinks keep both agents on the current working tree after `git pull`.

## Layout

```text
skills/                infrastructure skills and their on-demand resources
AGENTS.md              portable policy + authoring conventions
CLAUDE.md              symlink to AGENTS.md, so every agent reads the same file
bin/install.sh         cross-agent installation
tests/                 regression tests
```
