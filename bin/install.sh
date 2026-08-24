#!/usr/bin/env bash
# Wire the skills into Claude Code and Codex.
# Everything is symlinked, so `git pull` updates both agents with no reinstall.
set -euo pipefail
REPO="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

link() { # link <target> <destination>
  if [ -L "$2" ]; then
    if [ "$(readlink -f "$2")" = "$(readlink -f "$1")" ]; then
      echo "  already linked $2"
    else
      echo "  WARNING: $2 points elsewhere; refusing to replace it"
    fi
  elif [ -e "$2" ]; then
    echo "  WARNING: $2 exists; refusing to replace it"
  else
    ln -s "$1" "$2"
    echo "  linked $2"
  fi
}

# Codex discovers skills per-directory here, so guidance loads on demand rather
# than being charged to every session.
CODEX_SKILLS="${HOME}/.agents/skills"
mkdir -p "$CODEX_SKILLS"
for source in "$REPO"/skills/*; do
  [ -f "$source/SKILL.md" ] || continue
  link "$source" "$CODEX_SKILLS/$(basename "$source")"
done

# Claude Code: the skills dir loads the working tree directly. A marketplace
# install would copy into a versioned cache instead, which `git pull` cannot reach.
mkdir -p "${HOME}/.claude/skills"
link "$REPO" "${HOME}/.claude/skills/maxlab-infra"

echo
echo "Done. Start a new Codex session to discover the skills. In Claude Code,"
echo "/reload-plugins (or a new session) loads maxlab-infra@skills-dir."
echo "Claude verification: claude plugin details maxlab-infra@skills-dir"
