#!/usr/bin/env bash
# omano installer — downloads the latest binary from GitHub Releases,
# installs it to ~/.local/bin, and verifies it runs.
# Usage: bash <(curl -fsSL https://raw.githubusercontent.com/mikamikaloti-blip/omano/main/install.sh)
set -e

REPO="mikamikaloti-blip/omano"
INSTALL_DIR="$HOME/.local/bin"
BIN_NAME="omano"

echo "╔════════════════════════════════════╗"
echo "║        omano installer             ║"
echo "║  OpenBullet 2 proxy toolkit        ║"
echo "╚════════════════════════════════════╝"
echo ""

# 1. Pick the right asset for this platform
ARCH=$(uname -m)
case "$ARCH" in
    x86_64) ASSET="omano-linux-x86_64" ;;
    aarch64|arm64) ASSET="omano-linux-aarch64" ;;
    *) echo "❌ Unsupported architecture: $ARCH"; exit 1 ;;
esac

# 2. Get the latest release download URL
echo "📡 Looking up the latest release..."
API="https://api.github.com/repos/${REPO}/releases/latest"
ASSET_URL=$(curl -sf "$API" \
    | python3 -c "
import json, sys
data = json.load(sys.stdin)
for a in data.get('assets', []):
    if a['name'] == '$ASSET':
        print(a['browser_download_url'])
        break
")

if [ -z "$ASSET_URL" ]; then
    echo "❌ Could not find release asset '${ASSET}'."
    exit 1
fi

# 3. Download
mkdir -p "$INSTALL_DIR"
TMP=$(mktemp /tmp/omano-XXXXX)
echo "⬇️  Downloading ${ASSET} (~75 MB)..."
curl -#fL "$ASSET_URL" -o "$TMP"

# 4. Install
chmod +x "$TMP"
mv "$TMP" "$INSTALL_DIR/$BIN_NAME"
echo "📦 Installed → $INSTALL_DIR/$BIN_NAME"

# 5. Make sure ~/.local/bin is on PATH
case ":$PATH:" in
    *":$INSTALL_DIR:"*) ;;
    *)
        SHELL_RC="$HOME/.bashrc"
        [ -n "$ZSH_VERSION" ] && SHELL_RC="$HOME/.zshrc"
        echo "export PATH=\"\$HOME/.local/bin:\$PATH\"" >> "$SHELL_RC"
        echo "🔧 Added $INSTALL_DIR to PATH (in $SHELL_RC)"
        ;;
esac

# 6. Verify
echo ""
if "$INSTALL_DIR/$BIN_NAME" --help >/dev/null 2>&1; then
    echo "✅ omano installed successfully!"
    echo ""
    echo "┌──────────────────────────────────────────────────┐"
    echo "│  NEXT STEPS                                      │"
    echo "├──────────────────────────────────────────────────┤"
    echo "│  1. Open a NEW terminal (or: source ~/.bashrc)   │"
    echo "│  2. Get your machine ID:                         │"
    echo "│        omano lic machine-id                      │"
    echo "│  3. Send that ID to your vendor                  │"
    echo "│  4. Activate the license you receive:            │"
    echo "│        omano lic activate <KEY>                  │"
    echo "│  5. Run:                                         │"
    echo "│        omano check proxies.txt                   │"
    echo "└──────────────────────────────────────────────────┘"
else
    echo "❌ Install finished but the binary did not run."
    echo "   Try manually: $INSTALL_DIR/$BIN_NAME --help"
    exit 1
fi
