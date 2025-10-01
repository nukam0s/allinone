# AllInOne Protection System for Eggdrop

[![License: MIT](https://imgshields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![TCL](https://imgshields.io/badge/Language-Tcl-blue.svg)](https://www.tcl.tk/)

The **AllInOne Protection System** is an advanced Tcl script for Eggdrop bots, designed to provide a modular and channel-configurable protection system, replacing the need for multiple flood scripts and global word lists.

## ✨ Features

* **Channel-Specific Modular Protection:** Independent management of `badwords`, `badchans`, and `spamwords` for each channel.
* **8 Protection Types:** Includes message flood, repeat flood, bad words, bad part, bad channel, caps, spam, and **DNSBL** (DNS Blacklist).
* **Refined Permissions:** Granular access control based on global flags (`n/m`) and channel-specific flags (`n/m/o/v`).
* **Flexible Aliases and Commands:** Supports multiple command prefixes (`!@#.`); configurable and persistent aliases (`aliases.conf`).
* **Automatic Migration:** Existing global lists are automatically migrated to channel-specific lists on the first run.
* **Auto-Update:** Use `!update` to fetch the latest version directly from GitHub and reload the script.

## ⚙️ Installation

1.  **Download:** Clone or download the script to your Eggdrop `scripts` directory.
    ```bash
    cp allinone.tcl scripts/allinone.tcl
    ```
2.  **Dependencies:** Ensure that `wget` and the Tcl `http` package are installed on your system, as they are required for the auto-update functionality.
3.  **Eggdrop Configuration:** Add the following line to your `eggdrop.conf`:
    ```tcl
    source scripts/allinone.tcl
    ```
4.  **Reload:** Use the `.rehash` or `.reload` command in IRC (or restart the bot).

## 📝 Usage (Commands)

The default command prefix is `!`, but it also accepts `@`, `#`, and `.`. All commands work via public message in the channel or via private `MSG` to the bot (in which case, channel commands require the `#channel` parameter).

### 🛡️ Protection and Configuration

| Command | Description | Permission |
| :--- | :--- | :--- |
| `!protection [#chan]` | Displays the status of all protections for the channel. | Channel Admin |
| `!protection <option> <value> [#chan]` | Changes a specific protection setting. | Channel Admin |
| `!protectionall <option> <value>` | Applies the setting to *all* channels. | Global Admin |
| `!copychan #source #dest` | Copies all settings and word lists from one channel to another. | Channel Admin |
| `!resetchan [#chan]` | Resets all channel settings and lists to default values. | Channel Admin |

#### Protection Configuration Options

| Protection Type | Key Settings | Default |
| :--- | :--- | :--- |
| **Message Flood** | `msgflood`, `maxmsg`, `msgtime` | 5 messages in 5s |
| **Repeat Flood** | `repeatflood`, `maxrepeat`, `repeattime` | 3 repeats in 30s |
| **Caps** | `caps`, `caps_percent`, `caps_minlen` | > 90% caps in messages > 15 chars |
| **New User Spam**| `spam`, `spam_time` | Checks for spam words for 30s after join |
| **DNSBL** | `dnsbl`, `dnsbl_zones`, `dnsbl_require_all` | Ban for IP listed in DNSBL zones |
| **General** | `<type>_punishment`, `<type>_bantime` | Default punishment is `kick` and ban time is variable |

### 🛑 List Management (Word Lists)

Word lists support `*` (asterisk) as a wildcard for flexible matching.

| Command | List Type | Example Usage |
| :--- | :--- | :--- |
| `!badwords <add|del|list|clear> [word] [#chan]` | Prohibited words in messages and part reasons. | Ex: `!badwords add *spam*site*` |
| `!badchans <add|del|list|clear> [#badchan] [#chan]` | Prohibited channels: bans the user if they are on the prohibited channel upon joining. | Ex: `!badchans add #rival` |
| `!spamwords <add|del|list|clear> [word] [#chan]` | Words that trigger the `spam` punishment if said by a newly joined user. | Ex: `!spamwords add freecoins` |

### 💻 System Commands

| Command | Description | Permission |
| :--- | :--- | :--- |
| `!alias <add|del|list|reset>` | Manages or lists command aliases. | Global Admin |
| `!char <chars>` | Sets the command characters (e.g., `!@#$`). | Global Admin |
| `!save` | Manually saves all channel configurations and lists immediately. | Global Admin |
| `!reload` | Reloads all configurations for all channels from disk. | Global Admin |
| `!update` | Downloads the latest version of the script and reloads it. | Global Admin |

### ℹ️ Information and Operation Commands

| Command | Description | Permission |
| :--- | :--- | :--- |
| `!chaninfo <#channel>` | Displays the complete configuration (Eggdrop and AllInOne) and status of the channel. | Op/Voice |
| `!channels` | Lists all channels the bot is in and which protections are active on each. | Op/Voice |
| `!chanset [#chan] <setting> [value]` | Alters native Eggdrop channel settings. | Channel Admin |
| `!pubcmds <enable|disable|status> [#chan]` | Enables or disables the use of commands in public (forces MSG usage). | Channel Admin |

## 🔑 Permissions (Eggdrop Flags)

| Level | Flags | Access |
| :--- | :--- | :--- |
| **Global Admin** | `n` or `m` globally | Full access, including `!protectionall`, `!alias`, `!update`.
| **Channel Admin** | `n` or `m` on the channel | Manages channel protections, lists (`!badwords`, etc.), and settings (`!chanset`).
| **Op** | `o` on the channel | Basic channel commands (`!kick`, `!ban`, `!op`) and information viewing (`!chaninfo`).
| **Voice** | `v` on the channel | View-only commands (`!channels`, `!chaninfo`).

## 📂 Configuration Files

Persistent data is saved in the `scripts/allinone/` directory:

* `scripts/allinone/badwords_<chan>.txt`
* `scripts/allinone/badchans_<chan>.txt`
* `scripts/allinone/spamwords_<chan>.txt`
* `scripts/allinone/config_<chan>.txt`
* `scripts/allinone/aliases.conf` (Command aliases)
* `scripts/allinone/pubcmds_<chan>.txt` (Public command status)

## 🗃️ Requirements

* Eggdrop 1.8+
* Tcl `http` package
* `wget` (for HTTPS script updates)

## 📜 License

This project is licensed under the **MIT License**.
