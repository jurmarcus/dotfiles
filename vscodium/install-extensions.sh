#!/usr/bin/env bash
# Install VSCodium extensions from the extensions file

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
EXTENSIONS_FILE="$SCRIPT_DIR/extensions"

if ! command -v codium &> /dev/null; then
    echo "Error: codium command not found. Please install VSCodium first."
    exit 1
fi

echo "Installing VSCodium extensions..."

# Read extensions file, skip comments and empty lines
while IFS= read -r extension || [ -n "$extension" ]; do
    # Skip comments and empty lines
    [[ "$extension" =~ ^#.*$ ]] && continue
    [[ -z "$extension" ]] && continue

    echo "Installing: $extension"
    codium --install-extension "$extension"
done < "$EXTENSIONS_FILE"

echo "✓ All extensions installed successfully!"
