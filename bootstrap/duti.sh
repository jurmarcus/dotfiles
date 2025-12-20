#!/usr/bin/env bash
set -euo pipefail

# Set default applications by file type using duti
# Find bundle IDs with: osascript -e 'id of app "App Name"'
# Or: mdls -name kMDItemCFBundleIdentifier /Applications/App.app

if ! command -v duti &>/dev/null; then
  echo "  Installing duti..."
  brew install duti
fi

# VSCodium bundle ID
CODIUM="com.vscodium"

# Default browser
BROWSER="com.apple.Safari"  # or "org.mozilla.firefox", "com.google.Chrome"

# Default PDF viewer
PDF="com.apple.Preview"  # or "net.sourceforge.skim-app.skim"

echo "  Setting default applications..."

# Code/Text files -> VSCodium
CODE_EXTENSIONS=(
  .txt .md .markdown
  .json .yaml .yml .toml
  .sh .bash .zsh .fish
  .py .pyw
  .js .mjs .cjs .ts .mts .tsx .jsx
  .html .htm .css .scss .sass .less
  .rs .go .rb .php .java .kt .swift .c .cpp .h .hpp
  .sql .graphql .prisma
  .xml .svg
  .env .env.local .env.example
  .gitignore .gitattributes .editorconfig
  .dockerignore Dockerfile
  .lua .vim .el
  .conf .cfg .ini
  .log
)

for ext in "${CODE_EXTENSIONS[@]}"; do
  duti -s "${CODIUM}" "${ext}" all 2>/dev/null || true
done
echo "    ✓ Code files -> VSCodium"

# Web files -> Browser
WEB_EXTENSIONS=(
  .html .htm .xhtml
  .url .webloc
)

for ext in "${WEB_EXTENSIONS[@]}"; do
  duti -s "${BROWSER}" "${ext}" all 2>/dev/null || true
done
echo "    ✓ Web files -> ${BROWSER##*.}"

# PDF -> Preview (or Skim)
duti -s "${PDF}" .pdf all 2>/dev/null || true
echo "    ✓ PDF files -> Preview"

# Images -> Preview
IMAGE_EXTENSIONS=(
  .png .jpg .jpeg .gif .webp .bmp .tiff .ico .heic
)

for ext in "${IMAGE_EXTENSIONS[@]}"; do
  duti -s com.apple.Preview "${ext}" all 2>/dev/null || true
done
echo "    ✓ Images -> Preview"

echo "  Default applications configured"
