# Karabiner Elements Configuration

Keyboard customization for macOS.

## Files

```
karabiner/.config/karabiner/
└── karabiner.json
```

## Current Modifications

### Simple
- **Caps Lock <-> Left Control** - Swapped

### Complex
- **Yen/Backslash swap** - For JIS keyboard
- **Shift+Enter -> Option+Enter**

## Adding Modifications

### Simple (key swap)
```json
{
  "from": { "key_code": "caps_lock" },
  "to": [{ "key_code": "left_control" }]
}
```

### Complex (with modifiers)
```json
{
  "description": "Description",
  "manipulators": [{
    "type": "basic",
    "from": {
      "key_code": "key",
      "modifiers": { "mandatory": ["shift"] }
    },
    "to": [{
      "key_code": "other_key",
      "modifiers": ["option"]
    }]
  }]
}
```

## Tips

- Use Karabiner-EventViewer to find key codes
- Changes apply immediately after saving
