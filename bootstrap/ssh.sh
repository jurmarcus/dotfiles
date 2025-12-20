#!/usr/bin/env bash
set -euo pipefail

SSH_DIR="${HOME}/.ssh"
KEY_FILE="${SSH_DIR}/id_ed25519"

# Create .ssh directory with correct permissions
mkdir -p "${SSH_DIR}"
chmod 700 "${SSH_DIR}"

# Generate SSH key if it doesn't exist
if [[ -f "${KEY_FILE}" ]]; then
  echo "  SSH key already exists: ${KEY_FILE}"
else
  echo "  Generating new ed25519 SSH key..."
  read -rp "  Enter email for SSH key: " email
  ssh-keygen -t ed25519 -C "${email}" -f "${KEY_FILE}"
  echo "  SSH key generated: ${KEY_FILE}"
fi

# Add to keychain (macOS)
if [[ "$(uname -s)" == "Darwin" ]]; then
  ssh-add --apple-use-keychain "${KEY_FILE}" 2>/dev/null || true
fi

# Create SSH config if it doesn't exist
if [[ ! -f "${SSH_DIR}/config" ]]; then
  cat > "${SSH_DIR}/config" << 'EOF'
Host *
  AddKeysToAgent yes
  UseKeychain yes
  IdentityFile ~/.ssh/id_ed25519

Host github.com
  HostName github.com
  User git
  IdentityFile ~/.ssh/id_ed25519
EOF
  chmod 600 "${SSH_DIR}/config"
  echo "  Created SSH config"
fi

# Display public key for easy copying
echo ""
echo "  Public key (add to GitHub/GitLab):"
echo "  ─────────────────────────────────"
cat "${KEY_FILE}.pub"
echo ""
echo "  Copy with: pbcopy < ${KEY_FILE}.pub"
