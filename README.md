# AllInOne Protection System v2.6

**Channel-Specific Word Lists & Refined Permissions for Eggdrop Bots**

## Features

- **Channel-Specific Lists**: Independent `badwords`, `badchans`, and `spamwords` per channel.
- **Refined Permissions**:
  - Global Admin (flags `n/m` globally): full access.
  - Channel Admin (flags `n/m` on a channel): manage only that channel.
  - Op (flag `o`): channel commands & view info.
  - Voice (flag `v`): view-only info commands.
- **7 Protection Types**: message flood, repeat flood, bad words, bad part, bad channel, caps, spam.
- **Multi-Character Command Support**: `!@#.` command prefixes.
- **Configurable Aliases**: dynamic `!alias` command (persistent via `aliases.conf`).
- **Automatic Migration**: global lists migrate to channel-specific on first run.
- **Auto-Update**: `!update` fetches script from GitHub and reloads.
- **Private Message Support**: all commands available via PM.

## Installation

1. Clone or download the script to your Eggdrop `scripts` directory:
   ```bash
   cp allinone.tcl scripts/allinone.tcl
   ```
2. Ensure `wget` is installed for updates.
3. Load the script in your `eggdrop.conf`:
   ```tcl
   source scripts/allinone.tcl
   ```
4. Reload or restart the bot:
   ```irc
   .reload
   ```

## Usage

### General Commands

- `!help <topic>`: display help topics.
- `!channels`: list all channels and their protections.
- `!chaninfo <#channel>`: show channel config and status.
- `!chanset <#channel> <setting> <value>`: change Eggdrop channel settings.

### Protection Commands

- `!protection [<#channel>]`: view protection settings.
- `!protection <option> <value> [#chan]`: change setting.
- `!protectionall <option> <value>`: apply setting to all channels.

Options include:
```
msgflood repeatflood badwords badpart badchan caps spam
maxmsg msgtime maxrepeat repeattime caps_percent caps_minlen spam_time
<type>_punishment <type>_bantime
```

### Word Lists

Use channel-specific lists:

- `!badwords add|del|list|clear [word] [#chan]`
- `!badchans add|del|list|clear [#badchan] [#chan]`
- `!spamwords add|del|list|clear [word] [#chan]`

### Aliases

Manage command aliases:

- `!alias list`
- `!alias add <alias> <command>`
- `!alias del <alias>`
- `!alias reset`

### Update

Fetch latest script and reload:

```
!update
```  

Ensure `customscript(update_url)` in the script points to the raw GitHub URL.

## Configuration Files

- `scripts/allinone/badwords_<chan>.txt`
- `scripts/allinone/badchans_<chan>.txt`
- `scripts/allinone/spamwords_<chan>.txt`
- `scripts/allinone/config_<chan>.txt`
- `scripts/allinone/aliases.conf`

## Requirements

- Eggdrop 1.8+  
- Tcl `http` package  
- `wget` (for HTTPS script updates)

## License

MIT License