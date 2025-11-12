# AllInOne Protection System for Eggdrop

[![Version](https://img.shields.io/badge/version-2.6-blue.svg)](https://github.com/nukam0s/allinone)
[![Eggdrop](https://img.shields.io/badge/eggdrop-1.6%2B-green.svg)](https://www.eggheads.org/)
[![License](https://img.shields.io/badge/license-MIT-orange.svg)](LICENSE)

Complete protection and management system for Eggdrop bots with channel-specific word lists, refined permissions, and 8 types of protection including DNSBL.

## ✨ Features

### 🛡️ Protection System (8 Types)
- **Message Flood** - Protection against message flooding
- **Repeat Flood** - Detects repeated messages
- **Bad Words** - Filters prohibited words
- **Bad Part** - Controls part messages
- **Bad Channels** - Auto-ban users in prohibited channels
- **Caps Lock** - Excessive caps limit
- **Spam** - Detects spam from new users
- **DNSBL** - IP blacklist verification (multiple zones)

### 📋 Channel-Specific Lists
- Independent badwords per channel
- Badchans (prohibited channels) per channel
- Customizable spamwords per channel
- Individual configuration for each protection

### 👥 Permission System
- **Global Admin** (n/m global) - Full access
- **Channel Admin** (n/m on channel) - Channel management
- **Op** (o) - User management
- **Voice** (v) - Information commands

### ⚙️ Advanced Management
- Public and private message commands
- Customizable alias system
- Configurable command characters
- Auto-update via GitHub
- Copy configurations between channels
- Protected flags (n, m, o, b, f)

## 📥 Installation

1. **Download the script:**
```bash
cd ~/eggdrop/scripts/
wget https://raw.githubusercontent.com/nukam0s/allinone/main/allinone.tcl
```

2. **Add to eggdrop.conf:**
```tcl
source scripts/allinone.tcl
```

3. **Create data directory:**
```bash
mkdir -p ~/eggdrop/scripts/allinone
```

4. **Rehash the bot:**
```
.rehash
```

## 🚀 Quick Start

### Basic Commands
```
!help                          - Help menu
!help <topic>                  - Specific help (channel, user, protection, etc)
!protection                    - View protection status
!channels                      - List channels with summary
!chaninfo [#channel]          - Complete channel information
```

### Protection Management
```
!protection msgflood 1         - Enable flood protection
!protection maxmsg 5           - Maximum 5 messages
!protection msgtime 10         - In 10 seconds
!protection msgflood_punishment kick - Punishment: kick
!protection msgflood_bantime 30     - Ban for 30 minutes
```

### List Management
```
!badwords add word             - Add prohibited word
!badwords del word             - Remove word
!badwords list                 - View list
!badwords clear                - Clear all

!badchans add #spam            - Add prohibited channel
!badchans list                 - View list

!spamwords add viagra          - Add spam word
!spamwords list                - View list
```

### Channel Management
```
!addchan #channel [key]        - Add channel
!delchan #channel              - Remove channel
!op nick                       - Give op
!kick nick reason              - Kick user
!ban nick [minutes] [reason]   - Ban (0 = permanent)
!unban hostmask                - Remove ban
```

### User Management
```
!adduser handle hostmask       - Add user
!chattr handle flags [#channel] - Change flags
!whois handle                  - User information
!match flags [#channel]        - List users with flags
```

## 🔧 Detailed Configuration

### DNSBL Protection
```
!protection dnsbl 1                                    - Enable DNSBL
!protection dnsbl_zones "zen.spamhaus.org, ..."       - Set zones
!protection dnsbl_require_all 1                       - Require all zones
!protection dnsbl_punishment ban                      - Punishment type
!protection dnsbl_bantime 1440                        - 24h ban
```

### Caps Protection
```
!protection caps 1                 - Enable
!protection caps_percent 70        - Maximum 70% caps
!protection caps_minlen 10         - In messages 10+ characters
!protection caps_punishment kick   - Punishment
```

### Public Commands
```
!pubcmds disable [#channel]    - Disable public commands
!pubcmds enable [#channel]     - Enable public commands
!pubcmds status [#channel]     - View status
```

### Alias System
```
!alias add k kick              - Create alias
!alias del k                   - Remove alias
!alias list                    - List aliases
!alias reset                   - Reset to defaults
```

## 📊 Punishment Types

Each protection supports 3 punishment types:
- **kick** - Kicks the user
- **ban** - Temporary ban (configure minutes with `_bantime`)
- **none** - Log only (no action)

Example:
```
!protection badwords_punishment ban
!protection badwords_bantime 60    # 60 minutes
```

## 🔐 Permission Levels

| Level | Flags | Access |
|-------|-------|--------|
| Global Owner | n (global) | Everything |
| Global Master | m (global) | Everything except owner |
| Channel Admin | n/m on channel | Channel management |
| Op | o (global or channel) | Basic management |
| Voice | v (global or channel) | View only |

## 💾 Data Management

### Created Files
```
scripts/allinone/
├── config_channel.txt         - Channel configuration
├── badwords_channel.txt       - Prohibited words
├── badchans_channel.txt       - Prohibited channels
├── spamwords_channel.txt      - Spam words
├── pubcmds_channel.txt        - Public commands state
└── aliases.conf               - Command aliases
```

### Backup and Restore
```
!save                          - Save everything
!reload                        - Reload configurations
!copychan #source #dest        - Copy config between channels
!resetchan [#channel]         - Reset to defaults
```

## 🔄 Updates
```
!update                        - Auto-update via GitHub
```

The script downloads the latest version and reloads automatically.

## 📝 Usage Examples

### Scenario 1: Configure Anti-Spam Channel
```
!protection spam 1
!protection spam_time 300
!spamwords add http://
!spamwords add .com
!spamwords add viagra
!protection spam_punishment ban
!protection spam_bantime 60
```

### Scenario 2: Flood Protection
```
!protection msgflood 1
!protection maxmsg 3
!protection msgtime 5
!protection msgflood_punishment kick

!protection repeatflood 1
!protection maxrepeat 2
!protection repeattime 30
```

### Scenario 3: Full DNSBL
```
!protection dnsbl 1
!protection dnsbl_zones "zen.spamhaus.org, dnsbl.dronebl.org, cbl.abuseat.org"
!protection dnsbl_require_all 0
!protection dnsbl_punishment ban
!protection dnsbl_bantime 1440
```

## ⚠️ Important Notes

- **Protected Flags**: Users with flags n, m, o, b, f are not affected by protections
- **Ops/Voice**: Users with op or voice in the channel are not punished
- **DNSBL**: Requires `nslookup` installed on the system
- **Public Commands**: Can be disabled per channel to use only via /msg

## 🐛 Troubleshooting

### Script won't load
```bash
# Check syntax
tclsh allinone.tcl

# Check logs
tail -f ~/eggdrop/logs/eggdrop.log
```

### Protections not working
```
!protection                    # Check if active
!channels                      # View status
.console +d                    # Enable debug in partyline
```

### DNSBL not working
```bash
# Test nslookup manually
nslookup 1.0.0.127.zen.spamhaus.org
```

## 📞 Support

- **Issues**: [GitHub Issues](https://github.com/nukam0s/allinone/issues)
- **Updates**: [GitHub Releases](https://github.com/nukam0s/allinone/releases)

## 📜 License

MIT License - see [LICENSE](LICENSE) for details.

## 🙏 Credits

Developed for the Eggdrop IRC community.

---

**Version**: 2.6  
**Compatibility**: Eggdrop 1.6+  
**Last Updated**: 2025
