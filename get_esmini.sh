#!/usr/bin/env bash

# Config
REPO="esmini/esmini"
ASSET_NAME="esmini-demo_Linux.zip"     # exact asset name to match
DEST_DIR="${1:-vendor/esmini}"         # optional arg: destination dir 
API_URL="https://api.github.com/repos/${REPO}/releases/latest"

# Tools check
command -v curl >/dev/null 2>&1 || { echo "curl is required"; exit 1; }
command -v jq   >/dev/null 2>&1 || { echo "jq is required (sudo apt-get install jq)"; exit 1; }

mkdir -p "$DEST_DIR"
TMPDIR="$(mktemp -d)"
cleanup() { rm -rf "$TMPDIR"; }
trap cleanup EXIT

echo "→ Querying latest release for ${REPO}…"
json="$(curl -fsSL "$API_URL")"

TAG="$(echo "$json" | jq -r '.tag_name')"
URL="$(echo "$json" | jq -r --arg name "$ASSET_NAME" '.assets[] | select(.name==$name) | .browser_download_url')"

if [[ -z "${URL}" ]]; then
  echo "Could not find asset '$ASSET_NAME' in latest release ${TAG}."
  echo "Available assets:"
  echo "$json" | jq -r '.assets[].name'
  exit 1
fi

echo "→ Latest tag: ${TAG}"
echo "→ Downloading asset: ${ASSET_NAME}"
ZIPFILE="${TMPDIR}/${ASSET_NAME}"
curl -fL --retry 3 -o "$ZIPFILE" "$URL"

echo "→ Clearing old contents in ${DEST_DIR}"
# Keep the directory but remove previous demo
find "$DEST_DIR" -mindepth 1 -maxdepth 1 -exec rm -rf {} +

echo "→ Unzipping into ${DEST_DIR}"
unzip -q "$ZIPFILE" -d "$DEST_DIR"

# Optional: make binaries executable if present
if [[ -d "${DEST_DIR}/bin" ]]; then
  chmod +x "${DEST_DIR}/bin/"*
fi

# Write a small marker file with the tag used
echo "$TAG" > "${DEST_DIR}/.esmini_version"

echo "✓ esmini demo ${TAG} installed at ${DEST_DIR}"
echo "   Binaries (if any): ${DEST_DIR}/bin"
