# OpenCode Configuration

OpenCode AI coding assistant configuration.

## Files

```
opencode/.config/opencode/
├── opencode.json        # Main config (providers, models)
└── oh-my-opencode.json  # oh-my-opencode settings (agents, experimental)
```

## Provider Setup

Uses ProxyPal local proxy for model access (with direct provider fallbacks for testing):

- **Endpoint**: `http://127.0.0.1:8317/v1`
- **API Key**: `proxypal-local`

## Available Models (via ProxyPal)

### Claude (proxypal/)
| Model Key | API ID | Thinking Budget |
|-----------|--------|-----------------|
| claude-haiku-4-5-low | claude-haiku-4-5-20251001 | 8k |
| claude-haiku-4-5-medium | claude-haiku-4-5-20251001 | 16k |
| claude-sonnet-4-5-low | claude-sonnet-4-5-20250929 | 8k |
| claude-sonnet-4-5-medium | claude-sonnet-4-5-20250929 | 16k |
| claude-sonnet-4-5-high | claude-sonnet-4-5-20250929 | 32k |
| claude-sonnet-4-5-xhigh | claude-sonnet-4-5-20250929 | 64k |
| claude-opus-4-5-medium | claude-opus-4-5-20251101 | 16k |
| claude-opus-4-5-high | claude-opus-4-5-20251101 | 32k |
| claude-opus-4-5-xhigh | claude-opus-4-5-20251101 | 64k |

### Gemini (proxypal/)
| Model Key | API ID |
|-----------|--------|
| gemini-3-pro-low | gemini-3-pro-preview |
| gemini-3-pro-high | gemini-3-pro-preview |
| gemini-3-flash | gemini-3-flash-preview |

### GPT (proxypal/)
| Model Key | API ID | Reasoning |
|-----------|--------|-----------|
| gpt-5-2-medium | gpt-5.2 | medium |
| gpt-5-2-high | gpt-5.2 | high |
| gpt-5-2-pro-medium | gpt-5.2-pro | medium |
| gpt-5-2-pro-high | gpt-5.2-pro | high |

## Agent Configuration

oh-my-opencode.json defines specialized agents (all via proxypal):

| Agent | Model | Purpose |
|-------|-------|---------|
| Sisyphus | proxypal/claude-opus-4-5-xhigh | Main coding agent |
| Planner-Sisyphus | proxypal/gemini-3-flash | Task planning |
| oracle | proxypal/gpt-5-2-medium | Knowledge queries |
| librarian | proxypal/claude-sonnet-4-5-xhigh | Documentation |
| explore | proxypal/gemini-3-flash | Codebase exploration |
| frontend-ui-ux-engineer | proxypal/gemini-3-pro-high | UI/UX work |
| document-writer | proxypal/claude-sonnet-4-5-xhigh | Writing docs |
| multimodal-looker | proxypal/gemini-3-flash | Image analysis |

## Experimental Features

```json
{
  "aggressive_truncation": true,
  "auto_resume": true,
  "truncate_all_tool_outputs": true,
  "enable_preview_features": true
}
```
