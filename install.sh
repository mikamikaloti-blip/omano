#!/usr/bin/env bash
# omano installer — downloads the latest binary from GitHub Releases,
# installs it to ~/.local/bin, and verifies it runs.
# Usage: bash install.sh
set -e

REPO="mikamikaloti-blip/omano"
INSTALL_DIR="$HOME/.local/bin"
BIN_NAME="omano"

echo "╔════════════════════════════════════╗"
echo "║        omano installer             ║"
echo "║  OpenBullet 2 proxy toolkit        ║"
echo "╚════════════════════════════════════╝"
echo ""

# 1. Check for a GitHub token (private repo needs one to download)
if [ -z "$GITHUB_TOKEN" ]; then
    echo "🔒 This is a private repository."
    echo "   You need the token your vendor gave you."
    echo ""
    read -rp "Paste your GitHub token: " GITHUB_TOKEN
    export GITHUB_TOKEN
fi

# 2. Pick the right asset for this platform
ARCH=$(uname -m)
case "$ARCH" in
    x86_64) ASSET="omano-linux-x86_64" ;;
    aarch64|arm64) ASSET="omano-linux-aarch64" ;;
    *) echo "❌ Unsupported architecture: $ARCH"; exit 1 ;;
esac

# 3. Get the latest release download URL
echo "📡 Looking up the latest release..."
API="https://api.github.com/repos/${REPO}/releases/latest"
ASSET_URL=$(curl -sf -H "Authorization: token $GITHUB_TOKEN" "$API" \
    | grep -o "\"browser_download_url\": *\"[^\"]*${ASSET}\"" \
    | head -1 | sed 's/.*"\(https[^"]*\)"/\1/')

if [ -z "$ASSET_URL" ]; then
    echo "❌ Could not find release asset '${ASSET}'."
    echo "   Check your token has repo access: https://github.com/settings/tokens"
    exit 1
fi

# 4. Download
mkdir -p "$INSTALL_DIR"
TMP=$(mktemp /tmp/omano-XXXXX)
echo "⬇️  Downloading ${ASSET} (~75 MB)..."
curl -#fL -H "Authorization: token $GITHUB_TOKEN" "$ASSET_URL" -o "$TMP"

# 5. Install
chmod +x "$TMP"
mv "$TMP" "$INSTALL_DIR/$BIN_NAME"
echo "📦 Installed → $INSTALL_DIR/$BIN_NAME"

# 6. Make sure ~/.local/bin is on PATH
case ":$PATH:" in
    *":$INSTALL_DIR:"*) ;;
    *)
        SHELL_RC="$HOME/.bashrc"
        [ -n "$ZSH_VERSION" ] && SHELL_RC="$HOME/.zshrc"
        echo "export PATH=\"\$HOME/.local/bin:\$PATH\"" >> "$SHELL_RC"
        echo "🔧 Added $INSTALL_DIR to PATH (in $SHELL_RC)"
        ;;
esac

# 7. Verify
echo ""
if "$INSTALL_DIR/$BIN_NAME" --help >/dev/null 2>&1; then
    echo "✅ omano installed successfully!"
    echo ""
    echo "┌─────────────────────────────────────────────┐"
    echo "│  NEXT STEPS                                 │"
    echo "├─────────────────────────────────────────────┤"
    echo "│  1. Open a NEW terminal (or: source ~/.bashrc) │"
    echo "│  2. Get your machine ID:                    │"
    echo "│        omano lic machine-id                 │"
    echo "│  3. Send that ID to your vendor             │"
    echo "│  4. Activate the license you receive:       │"
    echo "│        omano lic activate <KEY>             │"
    echo "│  5. Run:                                    │"
    echo "│        omano check proxies.txt              │"
    echo "└─────────────────────────────────────────────┘"
else
    echo "❌ Install finished but the binary did not run."
    echo "   Try manually: $INSTALL_DIR/$BIN_NAME --help"
    exit 1
fi
