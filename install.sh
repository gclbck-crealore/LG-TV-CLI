#!/usr/bin/env bash
# LG-TV-CLI installer: checks uv, links the `tv` command onto PATH, then finds and pairs your TV.
set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BIN_DIR="${HOME}/.local/bin"
TARGET="${BIN_DIR}/tv"

echo "== LG-TV-CLI installer =="

# 1) uv (runs the script and installs its Python dependencies on first use)
if ! command -v uv >/dev/null 2>&1; then
  echo "uv was not found. It is needed to run tv and install its Python dependencies."
  read -r -p "Install uv now with the official installer from astral.sh? [y/N]: " ans
  if [[ "${ans}" =~ ^[yY]$ ]]; then
    curl -LsSf https://astral.sh/uv/install.sh | sh
    export PATH="${HOME}/.local/bin:${HOME}/.cargo/bin:${PATH}"
  else
    echo "Stopped. Install uv yourself: https://docs.astral.sh/uv/"
    exit 1
  fi
fi

# 2) link the tv command
mkdir -p "${BIN_DIR}"
chmod +x "${REPO_DIR}/tv"
if [[ -e "${TARGET}" && ! -L "${TARGET}" ]]; then
  echo "ERROR: ${TARGET} already exists and is not a link to this project. Not overwriting it."
  exit 1
fi
ln -sfn "${REPO_DIR}/tv" "${TARGET}"
echo "Linked: ${TARGET} -> ${REPO_DIR}/tv"

case ":${PATH}:" in
  *":${BIN_DIR}:"*) ;;
  *) echo "WARNING: ${BIN_DIR} is not on your PATH. Add this to your shell profile:"
     echo "  export PATH=\"${BIN_DIR}:\$PATH\"" ;;
esac

# 3) find, pick and pair the TV
echo
echo "Make sure the TV is on and Settings > Network > LG Connect Apps is enabled."
"${REPO_DIR}/tv" setup

# 4) AI assistant setup hints
echo
"${REPO_DIR}/tv" mcp-config

echo
echo "Done. Run 'tv' to see all commands."
