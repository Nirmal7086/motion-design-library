#!/usr/bin/env bash
# Refresh this library's snapshots and submodule pins to each upstream
# default branch. Does not create a commit.
#
# Snapshots are replaced with a fresh tarball of that commit (no .git
# history). SOURCE.md is rewritten. Upstream license files are kept as
# they arrived in the tarball.
#
# Submodule pins are moved to the latest commit on the configured branch.
# A submodule that is not checked out is not cloned. Large projects
# (three.js, Babylon.js, Godot, Blender, and the other submodule entries)
# stay as pins until you ask for them:
#   git submodule update --init --depth 1 <path>
#
# Usage:
#   scripts/update.sh
#   scripts/update.sh --snapshots
#   scripts/update.sh --submodules

set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"

MODE="all"
if [[ $# -gt 1 ]]; then
  echo "usage: scripts/update.sh [--snapshots|--submodules]" >&2
  exit 2
fi
if [[ $# -eq 1 ]]; then
  case "$1" in
    --snapshots) MODE="snapshots" ;;
    --submodules) MODE="submodules" ;;
    *)
      echo "usage: scripts/update.sh [--snapshots|--submodules]" >&2
      exit 2
      ;;
  esac
fi

# kind|path|url|branch|license
# kind is "snapshot" or "submodule".
# Remotion skills stays a submodule: the upstream repo publishes no license.
catalog() {
  cat <<'EOF'
snapshot|video-and-explainers/motion-canvas|https://github.com/motion-canvas/motion-canvas.git|main|MIT License
snapshot|video-and-explainers/manim|https://github.com/3b1b/manim.git|master|MIT License
snapshot|tweening-and-ui/anime|https://github.com/juliangarnier/anime.git|master|MIT License
snapshot|tweening-and-ui/ola|https://github.com/franciscop/ola.git|master|MIT License
snapshot|tweening-and-ui/tweenjs|https://github.com/CreateJS/TweenJS.git|master|MIT License
snapshot|tweening-and-ui/shifty|https://github.com/jeremyckahn/shifty.git|main|MIT License
snapshot|vector-and-2d/two.js|https://github.com/jonobr1/two.js.git|dev|MIT License
snapshot|vector-and-2d/konva|https://github.com/konvajs/konva.git|master|MIT License
snapshot|3d/gltfjsx|https://github.com/pmndrs/gltfjsx.git|master|MIT License
snapshot|particles/proton|https://github.com/drawcall/Proton.git|master|MIT License
submodule|video-and-explainers/remotion-skills|https://github.com/remotion-dev/skills.git|main|No license published
submodule|tweening-and-ui/motion|https://github.com/motiondivision/motion.git|main|MIT License
submodule|vector-and-2d/lottie-web|https://github.com/airbnb/lottie-web.git|master|MIT License
submodule|3d/three.js|https://github.com/mrdoob/three.js.git|dev|MIT License
submodule|3d/lume|https://github.com/lume/lume.git|main|MIT License
submodule|3d/babylon.js|https://github.com/BabylonJS/Babylon.js.git|master|Apache License 2.0
submodule|engines-and-apps/godot|https://github.com/godotengine/godot.git|master|MIT License
submodule|engines-and-apps/blender|https://github.com/blender/blender.git|main|GPL-2.0-or-later
EOF
}

DATE="$(date -u +%Y-%m-%d)"
SNAPSHOT_BUDGET=$((30 * 1024 * 1024))

resolve_sha() {
  local url="$1"
  local branch="$2"
  local sha
  sha="$(git ls-remote "$url" "refs/heads/${branch}" | awk 'NR==1 { print $1 }')"
  if [[ ! "$sha" =~ ^[0-9a-f]{40}$ ]]; then
    echo "could not resolve ${url} refs/heads/${branch}" >&2
    exit 1
  fi
  printf '%s\n' "$sha"
}

github_slug() {
  local url="$1"
  local rest
  rest="${url#https://github.com/}"
  rest="${rest%.git}"
  printf '%s\n' "$rest"
}

write_gitmodules() {
  local kind path url branch license
  : > .gitmodules
  while IFS='|' read -r kind path url branch license; do
    [[ -z "${kind:-}" || "$kind" == \#* ]] && continue
    [[ "$kind" == "submodule" ]] || continue
    {
      printf '[submodule "%s"]\n' "$path"
      printf '\tpath = %s\n' "$path"
      printf '\turl = %s\n' "$url"
      printf '\tbranch = %s\n' "$branch"
    } >> .gitmodules
  done < <(catalog)
  git add -- .gitmodules
}

has_license_file() {
  local dir="$1"
  local found
  found="$(find "$dir" -maxdepth 1 -type f \
    \( -iname 'license*' -o -iname 'licence*' -o -iname 'copying*' -o -iname 'unlicense*' \) \
    -print -quit)"
  [[ -n "$found" ]]
}

refresh_snapshot() {
  local path="$1"
  local url="$2"
  local branch="$3"
  local license="$4"
  local slug sha tmp src bytes big

  slug="$(github_slug "$url")"
  sha="$(resolve_sha "$url" "$branch")"
  echo "snapshot ${path} <= ${slug}@${sha}"

  tmp="$(mktemp -d)"
  # shellcheck disable=SC2064
  trap "rm -rf '$tmp'" RETURN

  curl -fsSL --retry 3 --retry-delay 2 \
    -o "${tmp}/src.tar.gz" \
    "https://codeload.github.com/${slug}/tar.gz/${sha}"
  mkdir -p "${tmp}/extract"
  tar -xzf "${tmp}/src.tar.gz" -C "${tmp}/extract"
  mapfile -d '' tops < <(find "${tmp}/extract" -mindepth 1 -maxdepth 1 -type d -print0)
  if [[ ${#tops[@]} -ne 1 ]]; then
    echo "tarball for ${slug} did not contain exactly one top-level directory" >&2
    exit 1
  fi
  src="${tops[0]}"
  rm -rf "${src}/.git"

  mapfile -d '' big < <(find "$src" -type f -size +50M -print0)
  if [[ ${#big[@]} -gt 0 ]]; then
    echo "refusing to vendor ${path}; these files are over 50 MiB:" >&2
    printf '  %s\n' "${big[@]}" >&2
    exit 1
  fi

  if ! has_license_file "$src"; then
    echo "refusing to vendor ${path}; no license file at the repo root." >&2
    echo "Link it as a submodule instead of copying." >&2
    exit 1
  fi

  cat > "${src}/SOURCE.md" <<EOF
# Source

Snapshot of the upstream default branch, without git history. Upstream license files in this folder are unchanged.

- Upstream: https://github.com/${slug}
- Commit: ${sha}
- Date: ${DATE}
- License: ${license}
EOF

  rm -rf "$path"
  mkdir -p "$(dirname "$path")"
  mv "$src" "$path"

  bytes="$(du -sb "$path" | awk '{ print $1 }')"
  if (( bytes > SNAPSHOT_BUDGET )); then
    echo "warning: ${path} is ${bytes} bytes, above the ~30 MiB snapshot budget" >&2
  fi

  # -f keeps files that the upstream .gitignore would otherwise hide but that
  # are part of the committed tree (and therefore of this snapshot).
  git add -A -f -- "$path"
  trap - RETURN
  rm -rf "$tmp"
}

refresh_submodule() {
  local path="$1"
  local url="$2"
  local branch="$3"
  local sha

  sha="$(resolve_sha "$url" "$branch")"
  if [[ -e "${path}/.git" ]]; then
    echo "submodule checkout ${path} <= ${sha}"
    git -C "$path" fetch --depth 1 origin "$branch"
    git -C "$path" checkout --detach "$sha"
  else
    echo "submodule pin ${path} <= ${sha} (not checked out)"
  fi
  git update-index --add --cacheinfo "160000,${sha},${path}"
}

if [[ "$MODE" != "snapshots" ]]; then
  write_gitmodules
fi

while IFS='|' read -r kind path url branch license; do
  [[ -z "${kind:-}" || "$kind" == \#* ]] && continue
  case "$MODE:$kind" in
    all:snapshot|snapshots:snapshot) refresh_snapshot "$path" "$url" "$branch" "$license" ;;
    all:submodule|submodules:submodule) refresh_submodule "$path" "$url" "$branch" ;;
    *) ;;
  esac
done < <(catalog)

echo "done. review git status and commit when the pins look right."
