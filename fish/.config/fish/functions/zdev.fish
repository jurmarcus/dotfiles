# Zellij session helper
function zdev
    echo "Zellij sessions:"
    echo "  zssh      - ssh session (shared)"
    echo "  zclaude   - new claude session (claude-1, claude-2, ...)"
    echo "  zopencode - new opencode session (opencode-1, opencode-2, ...)"
    echo "  zservice  - new service session (service-1, service-2, ...)"
    echo "  zls       - list sessions"
    echo "  zcd NAME  - switch to session"
    echo "  zrm NAME  - delete session"
    echo ""
    zellij list-sessions 2>/dev/null; or echo "No active sessions"
end
