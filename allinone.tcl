# ========================================================================
# AllInOne Protection System v2.6 - Channel-Specific Word Lists
# ========================================================================
# Features:
# - Channel-specific badwords/badchans/spamwords lists
# - Refined permissions (global vs channel admin)
# - 7 types of protection with individual punishments
# - Multi-character command support
# - Private message support
# - Automatic migration from global lists
# ========================================================================
package require http

namespace eval ::customscript {
    variable version "2.6"
}

# Configuration
set customscript(cmdchars) "!@#."
set customscript(datadir) "scripts/allinone"
set customscript(update_url) "https://raw.githubusercontent.com/nukam0s/allinone/main/allinone.tcl"


# Channel-specific word lists (replaces global lists)
array set channel_badwords {}
array set channel_badchans {}
array set channel_spamwords {}

# Protection settings per channel
array set channel_settings {}

# Default settings
array set default_settings {
    msgflood 0
    maxmsg 5
    msgtime 5
    msgflood_punishment "kick"
    msgflood_bantime 10
    
    repeatflood 0
    maxrepeat 3
    repeattime 30
    repeatflood_punishment "kick"
    repeatflood_bantime 10
    
    badwords 0
    badwords_punishment "kick"
    badwords_bantime 30
    
    badpart 0
    badpart_punishment "kick"
    badpart_bantime 30
    
    badchan 0
    badchan_punishment "ban"
    badchan_bantime 60
    
    caps 0
    caps_percent 90
    caps_minlen 15
    caps_punishment "kick"
    caps_bantime 10
    
    spam 0
    spam_time 30
    spam_punishment "ban"
    spam_bantime 30
}

# Protected flags from protection
set protected_flags {n m o b f}

# Command aliases system
array set command_aliases {}


# ========================================================================
# PERMISSION FUNCTIONS
# ========================================================================

proc is_admin {nick chan} {
    set hand [nick2hand $nick $chan]
    # Admin global OU admin do canal específico
    if {[matchattr $hand n] || [matchattr $hand m] ||
        [matchattr $hand n $chan] || [matchattr $hand m $chan]} {
        return 1
    }
    return 0
}

proc is_op_level {nick chan} {
    set hand [nick2hand $nick $chan]
    # Global OU específico do canal
    if {[matchattr $hand n] || [matchattr $hand m] || [matchattr $hand o] ||
        [matchattr $hand n $chan] || [matchattr $hand m $chan] || [matchattr $hand o $chan]} {
        return 1
    }
    return 0
}

proc is_voice_level {nick chan} {
    set hand [nick2hand $nick $chan]
    # Global OU específico do canal
    if {[matchattr $hand n] || [matchattr $hand m] || [matchattr $hand o] || [matchattr $hand v] ||
        [matchattr $hand n $chan] || [matchattr $hand m $chan] || [matchattr $hand o $chan] || [matchattr $hand v $chan]} {
        return 1
    }
    return 0
}


# New permission functions for channel-specific security
proc is_global_admin {nick} {
    set hand [nick2hand $nick]
    if {[matchattr $hand n] || [matchattr $hand m]} {
        return 1
    }
    return 0
}

proc is_admin_on_channel {nick target_chan} {
    set hand [nick2hand $nick $target_chan]
    # Global OU específico do canal
    if {[matchattr $hand n] || [matchattr $hand m] ||
        [matchattr $hand n $target_chan] || [matchattr $hand m $target_chan]} {
        return 1
    }
    return 0
}

proc is_op_on_channel {nick target_chan} {
    set hand [nick2hand $nick $target_chan]
    # Global OU específico do canal
    if {[matchattr $hand n] || [matchattr $hand m] || [matchattr $hand o] ||
        [matchattr $hand n $target_chan] || [matchattr $hand m $target_chan] || [matchattr $hand o $target_chan]} {
        return 1
    }
    return 0
}

# ========================================================================
# CHANNEL-SPECIFIC WORD LISTS FUNCTIONS
# ========================================================================

proc get_channel_badwords {chan} {
    global channel_badwords
    if {[info exists channel_badwords($chan)]} {
        return $channel_badwords($chan)
    }
    return {}
}

proc add_channel_badword {chan word} {
    global channel_badwords
    set current [get_channel_badwords $chan]
    set word [string tolower $word]
    if {[lsearch -exact $current $word] == -1} {
        lappend current $word
        set channel_badwords($chan) $current
        save_channel_badwords $chan
        return 1
    }
    return 0
}

proc del_channel_badword {chan word} {
    global channel_badwords
    set current [get_channel_badwords $chan]
    set word [string tolower $word]
    set index [lsearch -exact $current $word]
    if {$index != -1} {
        set new_list [lreplace $current $index $index]
        set channel_badwords($chan) $new_list
        save_channel_badwords $chan
        return 1
    }
    return 0
}

proc get_channel_badchans {chan} {
    global channel_badchans
    if {[info exists channel_badchans($chan)]} {
        return $channel_badchans($chan)
    }
    return {}
}

proc add_channel_badchan {chan badchan} {
    global channel_badchans
    set current [get_channel_badchans $chan]
    set badchan [string tolower $badchan]
    if {[lsearch -exact $current $badchan] == -1} {
        lappend current $badchan
        set channel_badchans($chan) $current
        save_channel_badchans $chan
        return 1
    }
    return 0
}

proc del_channel_badchan {chan badchan} {
    global channel_badchans
    set current [get_channel_badchans $chan]
    set badchan [string tolower $badchan]
    set index [lsearch -exact $current $badchan]
    if {$index != -1} {
        set new_list [lreplace $current $index $index]
        set channel_badchans($chan) $new_list
        save_channel_badchans $chan
        return 1
    }
    return 0
}

proc get_channel_spamwords {chan} {
    global channel_spamwords
    if {[info exists channel_spamwords($chan)]} {
        return $channel_spamwords($chan)
    }
    return {}
}

proc add_channel_spamword {chan word} {
    global channel_spamwords
    set current [get_channel_spamwords $chan]
    set word [string tolower $word]
    if {[lsearch -exact $current $word] == -1} {
        lappend current $word
        set channel_spamwords($chan) $current
        save_channel_spamwords $chan
        return 1
    }
    return 0
}

proc del_channel_spamword {chan word} {
    global channel_spamwords
    set current [get_channel_spamwords $chan]
    set word [string tolower $word]
    set index [lsearch -exact $current $word]
    if {$index != -1} {
        set new_list [lreplace $current $index $index]
        set channel_spamwords($chan) $current
        save_channel_spamwords $chan
        return 1
    }
    return 0
}

# ========================================================================
# SAVE/LOAD FUNCTIONS FOR CHANNEL LISTS
# ========================================================================
proc fetch_and_write {url filePath} {
    # Usa wget para descarregar via HTTPS
    # Gera um ficheiro temporário no mesmo diretório
    set tmpfile "${filePath}.new"

    # Descarrega com wget -q para quiet e -O para output
    if {[catch {exec wget -q -O $tmpfile $url} err]} {
        return -code error "Download error: $err"
    }

    # Verifica existência do ficheiro temporário
    if {![file exists $tmpfile]} {
        return -code error "Download failed: no data"
    }

    # Substitui o ficheiro original
    if {[catch {file rename -force $tmpfile $filePath} err2]} {
        # Se falhar, apaga o tmpfile
        catch {file delete $tmpfile}
        return -code error "File write error: $err2"
    }
}



proc save_channel_badwords {chan} {
    global customscript channel_badwords
    set safe_chan [string map {"/" "_" "#" ""} $chan]
    set file [file join $customscript(datadir) "badwords_${safe_chan}.txt"]
    
    if {[catch {open $file w} fd]} {
        putlog "ERROR: Could not save $file"
        return
    }
    
    puts $fd "# Badwords for channel $chan"
    puts $fd "# One word per line"
    puts $fd ""
    
    if {[info exists channel_badwords($chan)]} {
        foreach word $channel_badwords($chan) {
            puts $fd $word
        }
    }
    close $fd
}

proc load_channel_badwords {chan} {
    global customscript channel_badwords
    set safe_chan [string map {"/" "_" "#" ""} $chan]
    set file [file join $customscript(datadir) "badwords_${safe_chan}.txt"]
    
    if {![file exists $file]} return
    
    if {[catch {open $file r} fd]} {
        putlog "ERROR: Could not read $file"
        return
    }
    
    set word_list {}
    while {[gets $fd line] >= 0} {
        set line [string trim $line]
        if {$line != "" && [string index $line 0] != "#"} {
            lappend word_list [string tolower $line]
        }
    }
    close $fd
    
    set channel_badwords($chan) $word_list
    putlog "Badwords for $chan loaded: [llength $word_list] words"
}

proc save_channel_badchans {chan} {
    global customscript channel_badchans
    set safe_chan [string map {"/" "_" "#" ""} $chan]
    set file [file join $customscript(datadir) "badchans_${safe_chan}.txt"]
    
    if {[catch {open $file w} fd]} {
        putlog "ERROR: Could not save $file"
        return
    }
    
    puts $fd "# Bad channels for $chan"
    puts $fd "# One channel per line"
    puts $fd ""
    
    if {[info exists channel_badchans($chan)]} {
        foreach badchan $channel_badchans($chan) {
            puts $fd $badchan
        }
    }
    close $fd
}

proc load_channel_badchans {chan} {
    global customscript channel_badchans
    set safe_chan [string map {"/" "_" "#" ""} $chan]
    set file [file join $customscript(datadir) "badchans_${safe_chan}.txt"]
    
    if {![file exists $file]} return
    
    if {[catch {open $file r} fd]} {
        putlog "ERROR: Could not read $file"
        return
    }
    
    set chan_list {}
    while {[gets $fd line] >= 0} {
        set line [string trim $line]
        if {$line != "" && [string index $line 0] != "#"} {
            lappend chan_list [string tolower $line]
        }
    }
    close $fd
    
    set channel_badchans($chan) $chan_list
    putlog "Bad channels for $chan loaded: [llength $chan_list] channels"
}

proc save_channel_spamwords {chan} {
    global customscript channel_spamwords
    set safe_chan [string map {"/" "_" "#" ""} $chan]
    set file [file join $customscript(datadir) "spamwords_${safe_chan}.txt"]
    
    if {[catch {open $file w} fd]} {
        putlog "ERROR: Could not save $file"
        return
    }
    
    puts $fd "# Spam words for $chan"
    puts $fd "# One word per line"
    puts $fd ""
    
    if {[info exists channel_spamwords($chan)]} {
        foreach word $channel_spamwords($chan) {
            puts $fd $word
        }
    }
    close $fd
}

proc load_channel_spamwords {chan} {
    global customscript channel_spamwords
    set safe_chan [string map {"/" "_" "#" ""} $chan]
    set file [file join $customscript(datadir) "spamwords_${safe_chan}.txt"]
    
    if {![file exists $file]} return
    
    if {[catch {open $file r} fd]} {
        putlog "ERROR: Could not read $file"
        return
    }
    
    set word_list {}
    while {[gets $fd line] >= 0} {
        set line [string trim $line]
        if {$line != "" && [string index $line 0] != "#"} {
            lappend word_list [string tolower $line]
        }
    }
    close $fd
    
    set channel_spamwords($chan) $word_list
    putlog "Spam words for $chan loaded: [llength $word_list] words"
}

# ========================================================================
# ALIASES SAVE/LOAD FUNCTIONS  
# ========================================================================

proc save_aliases {} {
    global customscript command_aliases
    set file [file join $customscript(datadir) "aliases.conf"]
    
    if {[catch {open $file w} fd]} {
        putlog "ERROR: Could not save aliases"
        return
    }
    
    puts $fd "# Command aliases"
    puts $fd "# Format: alias real_command"
    puts $fd ""
    
    foreach alias [array names command_aliases] {
        puts $fd "$alias $command_aliases($alias)"
    }
    close $fd
}

proc load_aliases {} {
    global customscript command_aliases
    set file [file join $customscript(datadir) "aliases.conf"]
    
    if {![file exists $file]} {
        # Se não existe arquivo, carrega aliases padrão
        array set command_aliases {
            o "op"
			do "deop"
            v "voice"
            dv "devoice"
            k "kick"
            b "ban"
            ub "unban"
            w "whois"
            ci "chaninfo"
            cs "chanset"
            p "protection"
            pa "protectionall"
            ch "channels"
            cc "copychan"
            rc "resetchan"
            bw "badwords"
            bc "badchans"
            sw "spamwords"
            s "save"
            r "reload"
            h "help"
			ajuda "help"
			prot "protection"
        }
        save_aliases
        putlog "Created default command aliases"
        return
    }
    
    if {[catch {open $file r} fd]} {
        putlog "ERROR: Could not read aliases"
        return
    }
    
    set count 0
    while {[gets $fd line] >= 0} {
        set line [string trim $line]
        if {$line != "" && [string index $line 0] != "#"} {
            set parts [split $line " "]
            if {[llength $parts] >= 2} {
                set alias [lindex $parts 0]
                set real_cmd [lindex $parts 1]
                set command_aliases($alias) $real_cmd
                incr count
            }
        }
    }
    close $fd
    
    if {$count > 0} {
        putlog "Loaded $count command aliases"
    }
}

# ========================================================================
# MIGRATION FUNCTION
# ========================================================================

proc migrate_global_lists {} {
    global badwords_list badchans_list spamwords_list
    global channel_badwords channel_badchans channel_spamwords
    
    set migrated 0
    
    # Migrate global badwords if they exist
    if {[info exists badwords_list] && [llength $badwords_list] > 0} {
        foreach chan [channels] {
            foreach word $badwords_list {
                add_channel_badword $chan $word
            }
            putlog "MIGRATION: Badwords migrated to $chan ([llength $badwords_list] words)"
        }
        unset badwords_list
        set migrated 1
    }
    
    # Migrate global badchans if they exist
    if {[info exists badchans_list] && [llength $badchans_list] > 0} {
        foreach chan [channels] {
            foreach badchan $badchans_list {
                add_channel_badchan $chan $badchan
            }
            putlog "MIGRATION: Bad channels migrated to $chan ([llength $badchans_list] channels)"
        }
        unset badchans_list
        set migrated 1
    }
    
    # Migrate global spamwords if they exist
    if {[info exists spamwords_list] && [llength $spamwords_list] > 0} {
        foreach chan [channels] {
            foreach word $spamwords_list {
                add_channel_spamword $chan $word
            }
            putlog "MIGRATION: Spam words migrated to $chan ([llength $spamwords_list] words)"
        }
        unset spamwords_list
        set migrated 1
    }
    
    if {$migrated} {
        putlog "MIGRATION COMPLETE: Global lists migrated to channel-specific lists"
    }
}

# ========================================================================
# CHANNEL SETTINGS FUNCTIONS
# ========================================================================

proc get_channel_setting {chan setting} {
    global channel_settings default_settings
    if {[info exists channel_settings($chan,$setting)]} {
        return $channel_settings($chan,$setting)
    } elseif {[info exists default_settings($setting)]} {
        return $default_settings($setting)
    }
    return ""
}

proc set_channel_setting {chan setting value} {
    global channel_settings
    set channel_settings($chan,$setting) $value
    save_channel_config $chan
}

proc save_channel_config {chan} {
    global customscript channel_settings default_settings
    set safe_chan [string map {"/" "_" "#" ""} $chan]
    set file [file join $customscript(datadir) "config_${safe_chan}.txt"]
    
    if {[catch {open $file w} fd]} {
        putlog "ERROR: Could not save config for $chan"
        return
    }
    
    puts $fd "# Configuration for channel $chan"
    puts $fd "# Format: setting value"
    puts $fd ""
    
    foreach setting [array names default_settings] {
        if {[info exists channel_settings($chan,$setting)]} {
            puts $fd "$setting $channel_settings($chan,$setting)"
        }
    }
    close $fd
}

proc load_channel_config {chan} {
    global customscript channel_settings
    set safe_chan [string map {"/" "_" "#" ""} $chan]
    set file [file join $customscript(datadir) "config_${safe_chan}.txt"]
    
    if {![file exists $file]} return
    
    if {[catch {open $file r} fd]} {
        putlog "ERROR: Could not read config for $chan"
        return
    }
    
    set count 0
    while {[gets $fd line] >= 0} {
        set line [string trim $line]
        if {$line != "" && [string index $line 0] != "#"} {
            set parts [split $line " "]
            if {[llength $parts] >= 2} {
                set setting [lindex $parts 0]
                set value [join [lrange $parts 1 end] " "]
                set channel_settings($chan,$setting) $value
                incr count
            }
        }
    }
    close $fd
    
    if {$count > 0} {
        putlog "Config for $chan loaded: $count settings"
    }
}

# ========================================================================
# PROTECTION FUNCTIONS
# ========================================================================

proc check_msgflood {nick uhost hand chan text} {
    global flood_array
    
    if {![get_channel_setting $chan msgflood]} return
    
    set maxmsg [get_channel_setting $chan maxmsg]
    set msgtime [get_channel_setting $chan msgtime]
    
    set now [unixtime]
    set key "${nick}:${chan}"
    
    if {![info exists flood_array($key)]} {
        set flood_array($key) [list $now]
        return
    }
    
    # Clean old entries
    set newlist {}
    foreach timestamp $flood_array($key) {
        if {[expr {$now - $timestamp}] <= $msgtime} {
            lappend newlist $timestamp
        }
    }
    lappend newlist $now
    set flood_array($key) $newlist
    
    if {[llength $newlist] > $maxmsg} {
        apply_punishment $nick $uhost $chan "msgflood" "Message flood ($maxmsg msgs in ${msgtime}s)"
        unset flood_array($key)
    }
}

proc check_repeatflood {nick uhost hand chan text} {
    global repeat_array
    
    if {![get_channel_setting $chan repeatflood]} return
    
    set maxrepeat [get_channel_setting $chan maxrepeat]
    set repeattime [get_channel_setting $chan repeattime]
    
    set now [unixtime]
    set key "${nick}:${chan}"
    set normalized_text [string tolower [string trim $text]]
    
    if {$normalized_text == ""} return
    
    if {![info exists repeat_array($key)]} {
        set repeat_array($key) [list [list $now $normalized_text]]
        return
    }
    
    # Clean old entries and count repeats
    set newlist {}
    set repeat_count 0
    foreach entry $repeat_array($key) {
        set timestamp [lindex $entry 0]
        set msg [lindex $entry 1]
        if {[expr {$now - $timestamp}] <= $repeattime} {
            lappend newlist $entry
            if {$msg == $normalized_text} {
                incr repeat_count
            }
        }
    }
    lappend newlist [list $now $normalized_text]
    set repeat_array($key) $newlist
    
    if {$repeat_count >= $maxrepeat} {
        apply_punishment $nick $uhost $chan "repeatflood" "Repeat flood (${repeat_count}x same message)"
        unset repeat_array($key)
    }
}

proc check_badwords {nick uhost hand chan text} {
    if {![get_channel_setting $chan badwords]} return
    
    set badwords [get_channel_badwords $chan]
    if {[llength $badwords] == 0} return
    
    set normalized_text [string tolower $text]
    
    foreach word $badwords {
        if {[string match "*$word*" $normalized_text]} {
            apply_punishment $nick $uhost $chan "badwords" "Bad word detected: $word"
            return
        }
    }
}

proc check_caps {nick uhost hand chan text} {
    if {![get_channel_setting $chan caps]} return
    
    set caps_percent [get_channel_setting $chan caps_percent]
    set caps_minlen [get_channel_setting $chan caps_minlen]
    
    set textlen [string length $text]
    if {$textlen < $caps_minlen} return
    
    set caps_count 0
    for {set i 0} {$i < $textlen} {incr i} {
        set char [string index $text $i]
        if {[string is upper $char] && [string is alpha $char]} {
            incr caps_count
        }
    }
    
    set actual_percent [expr {($caps_count * 100) / $textlen}]
    
    if {$actual_percent > $caps_percent} {
        apply_punishment $nick $uhost $chan "caps" "Excessive caps (${actual_percent}%)"
    }
}

proc check_spam_newuser {nick uhost hand chan} {
    global spam_array
    
    if {![get_channel_setting $chan spam]} return
    
    set spam_time [get_channel_setting $chan spam_time]
    set now [unixtime]
    set key "${nick}:${chan}"
    
    set spam_array($key) $now
    
    utimer $spam_time [list cleanup_spam_array $key]
}

proc cleanup_spam_array {key} {
    global spam_array
    catch {unset spam_array($key)}
}

proc check_spam_words {nick uhost hand chan text} {
    global spam_array
    
    if {![get_channel_setting $chan spam]} return
    
    set key "${nick}:${chan}"
    if {![info exists spam_array($key)]} return
    
    set spamwords [get_channel_spamwords $chan]
    if {[llength $spamwords] == 0} return
    
    set normalized_text [string tolower $text]
    
    foreach word $spamwords {
        if {[string match "*$word*" $normalized_text]} {
            apply_punishment $nick $uhost $chan "spam" "Spam detected from new user: $word"
            unset spam_array($key)
            return
        }
    }
}

proc check_badpart {nick uhost hand chan reason} {
    if {![get_channel_setting $chan badpart]} return
    
    set badwords [get_channel_badwords $chan]
    if {[llength $badwords] == 0} return
    
    set normalized_reason [string tolower $reason]
    
    foreach word $badwords {
        if {[string match "*$word*" $normalized_reason]} {
            set mask "*!*@[lindex [split $uhost "@"] 1]"
            set bantime [get_channel_setting $chan badpart_bantime]
            newchanban $chan $mask "BadPart" "BadPart: $word" [expr {$bantime * 60}]
            putlog "BADPART: Banned $nick ($mask) from $chan for part message: $word"
            return
        }
    }
}

proc check_badchan {nick uhost hand chan} {
    if {![get_channel_setting $chan badchan]} return
    
    set badchans [get_channel_badchans $chan]
    if {[llength $badchans] == 0} return
    
    foreach badchan $badchans {
        if {[onchan $nick $badchan]} {
            apply_punishment $nick $uhost $chan "badchan" "User in prohibited channel: $badchan"
            return
        }
    }
}

proc apply_punishment {nick uhost chan type reason} {
    set punishment [get_channel_setting $chan "${type}_punishment"]
    set bantime [get_channel_setting $chan "${type}_bantime"]
    
    # Verificar se o utilizador tem flags protegidas
    global protected_flags
    set hand [nick2hand $nick $chan]
    
    # Verificar flags globais e do canal
    set user_flags [chattr $hand]
    append user_flags [chattr $hand $chan]
    
    foreach protected_flag $protected_flags {
        if {[string match "*${protected_flag}*" $user_flags]} {
            putlog "PROTECTION: Not punishing $nick ($type): has protected flag $protected_flag"
            return
        }
    }
    
    # Verificar se tem op/voice no canal (proteção adicional)
    if {[isop $nick $chan] || [isvoice $nick $chan]} {
        putlog "PROTECTION: Not punishing $nick ($type): has op/voice"
        return
    }
    
    switch $punishment {
        "kick" {
            putkick $chan $nick $reason
            putlog "PROTECTION: Kicked $nick from $chan ($type): $reason"
        }
        "ban" {
            set mask "*!*@[lindex [split $uhost "@"] 1]"
            newchanban $chan $mask "Protection" $reason [expr {$bantime * 60}]
            putkick $chan $nick $reason
            putlog "PROTECTION: Banned $nick from $chan for ${bantime}min ($type): $reason"
        }
        "none" {
            putlog "PROTECTION: $type violation by $nick in $chan: $reason (no punishment)"
        }
    }
}

# ========================================================================
# EVENT BINDINGS
# ========================================================================

bind pubm - * check_message
bind join - * check_join
bind part - * check_part

proc check_message {nick uhost hand chan text} {
    if {[isbotnick $nick]} return
    
    check_msgflood $nick $uhost $hand $chan $text
    check_repeatflood $nick $uhost $hand $chan $text
    check_badwords $nick $uhost $hand $chan $text
    check_caps $nick $uhost $hand $chan $text
    check_spam_words $nick $uhost $hand $chan $text
}

proc check_join {nick uhost hand chan} {
    if {[isbotnick $nick]} return
    
    check_badchan $nick $uhost $hand $chan
    check_spam_newuser $nick $uhost $hand $chan
}

proc check_part {nick uhost hand chan reason} {
    if {[isbotnick $nick]} return
    
    check_badpart $nick $uhost $hand $chan $reason
}

# ========================================================================
# COMMAND BINDING SYSTEM
# ========================================================================

proc bind_all_command {chars cmd procname} {
    foreach c [split $chars ""] {
        catch {unbind pub - "${c}${cmd}" $procname}
        bind pub - "${c}${cmd}" $procname
        
        catch {unbind msg - "${c}${cmd}" "msg_$procname"}
        bind msg - "${c}${cmd}" "msg_$procname"
    }
}

# ========================================================================
# CHANNEL MANAGEMENT COMMANDS
# ========================================================================
proc pub_addchan {nick uhost hand chan text} {
    if {![is_global_admin $nick]} {
        putserv "NOTICE $nick :Access denied. Global master/owner required."
        return
    }
    
    set args [split $text]
    set target_chan [lindex $args 0]
    set chan_key [lindex $args 1]
    
    if {$target_chan == "" || [string index $target_chan 0] != "#"} {
        putserv "NOTICE $nick :Syntax: addchan <#channel> [key]"
        return
    }
    
    # Check if already in channel
    if {[lsearch -exact [channels] $target_chan] != -1} {
        putserv "NOTICE $nick :Already in $target_chan"
        return
    }
    
    # Add channel to Eggdrop
    if {$chan_key != ""} {
        channel add $target_chan {chanmode +nt idle-kick 0 key $chan_key}
    } else {
        channel add $target_chan {chanmode +nt idle-kick 0}
    }
    
    # Join the channel
    putserv "JOIN $target_chan $chan_key"
    
    # Initialize protection settings
    init_channel_protection $target_chan
    
    putserv "NOTICE $nick :Added and joined $target_chan"
    putlog "ADDCHAN: $nick added channel $target_chan"
}

proc pub_delchan {nick uhost hand chan text} {
    if {![is_global_admin $nick]} {
        putserv "NOTICE $nick :Access denied. Global master/owner required."
        return
    }
    
    set target_chan [lindex $text 0]
    
    if {$target_chan == "" || [string index $target_chan 0] != "#"} {
        putserv "NOTICE $nick :Syntax: delchan <#channel>"
        return
    }
    
    # Check if in channel
    if {[lsearch -exact [channels] $target_chan] == -1} {
        putserv "NOTICE $nick :Not in $target_chan"
        return
    }
    
    # Part the channel
    putserv "PART $target_chan :Removed by $nick"
    
    # Remove from Eggdrop config
    channel remove $target_chan
    
    putserv "NOTICE $nick :Left and removed $target_chan"
    putlog "DELCHAN: $nick removed channel $target_chan"
}

proc init_channel_protection {chan} {
    global default_settings channel_settings
    
    # Initialize with default settings if not already set
    foreach setting [array names default_settings] {
        if {![info exists channel_settings($chan,$setting)]} {
            set channel_settings($chan,$setting) $default_settings($setting)
        }
    }
    
    save_channel_config $chan
    putlog "Initialized protection settings for $chan"
}

proc pub_op {nick uhost hand chan text} {
    if {![is_op_level $nick $chan]} {
        putserv "NOTICE $nick :Access denied."
        return
    }
    
    if {$text == ""} {
        putserv "NOTICE $nick :Syntax: op <nick>"
        return
    }
    
    set target [lindex $text 0]
    if {[onchan $target $chan]} {
        putserv "MODE $chan +o $target"
        putlog "OP: $nick gave op to $target in $chan"
    } else {
        putserv "NOTICE $nick :$target is not in the channel."
    }
}

proc pub_deop {nick uhost hand chan text} {
    if {![is_op_level $nick $chan]} {
        putserv "NOTICE $nick :Access denied."
        return
    }
    
    if {$text == ""} {
        putserv "NOTICE $nick :Syntax: deop <nick>"
        return
    }
    
    set target [lindex $text 0]
    if {[onchan $target $chan]} {
        putserv "MODE $chan -o $target"
        putlog "DEOP: $nick removed op from $target in $chan"
    } else {
        putserv "NOTICE $nick :$target is not in the channel."
    }
}

proc pub_voice {nick uhost hand chan text} {
    if {![is_op_level $nick $chan]} {
        putserv "NOTICE $nick :Access denied."
        return
    }
    
    if {$text == ""} {
        putserv "NOTICE $nick :Syntax: voice <nick>"
        return
    }
    
    set target [lindex $text 0]
    if {[onchan $target $chan]} {
        putserv "MODE $chan +v $target"
        putlog "VOICE: $nick gave voice to $target in $chan"
    } else {
        putserv "NOTICE $nick :$target is not in the channel."
    }
}

proc pub_devoice {nick uhost hand chan text} {
    if {![is_op_level $nick $chan]} {
        putserv "NOTICE $nick :Access denied."
        return
    }
    
    if {$text == ""} {
        putserv "NOTICE $nick :Syntax: devoice <nick>"
        return
    }
    
    set target [lindex $text 0]
    if {[onchan $target $chan]} {
        putserv "MODE $chan -v $target"
        putlog "DEVOICE: $nick removed voice from $target in $chan"
    } else {
        putserv "NOTICE $nick :$target is not in the channel."
    }
}

proc pub_kick {nick uhost hand chan text} {
    if {![is_op_level $nick $chan]} {
        putserv "NOTICE $nick :Access denied."
        return
    }
    
    if {$text == ""} {
        putserv "NOTICE $nick :Syntax: kick <nick> \[reason\]"
        return
    }
    
    set args [split $text]
    set target [lindex $args 0]
    set reason [join [lrange $args 1 end] " "]
    
    if {$reason == ""} { set reason "Requested by $nick" }
    
    if {[onchan $target $chan]} {
        putkick $chan $target $reason
        putlog "KICK: $nick kicked $target from $chan ($reason)"
    } else {
        putserv "NOTICE $nick :$target is not in the channel."
    }
}

proc pub_ban {nick uhost hand chan text} {
    if {![is_op_level $nick $chan]} {
        putserv "NOTICE $nick :Access denied."
        return
    }
    
    if {$text == ""} {
        putserv "NOTICE $nick :Syntax: ban <nick/mask> \[minutes\]"
        return
    }
    
    set args [split $text]
    set target [lindex $args 0]
    set minutes [lindex $args 1]
    
    if {$minutes == "" || ![string is integer $minutes]} {
        set minutes 30
    }
    
    if {[onchan $target $chan]} {
        set uhost [getchanhost $target $chan]
        set mask "*!*@[lindex [split $uhost "@"] 1]"
    } else {
        set mask $target
    }
    
    newchanban $chan $mask $nick "Banned by $nick" [expr {$minutes * 60}]
    if {[onchan $target $chan]} {
        putkick $chan $target "Banned for $minutes minutes"
    }
    putlog "BAN: $nick banned $mask from $chan for $minutes minutes"
    putserv "NOTICE $nick :Banned $mask from $chan for $minutes minutes"
}

proc pub_unban {nick uhost hand chan text} {
    if {![is_op_level $nick $chan]} {
        putserv "NOTICE $nick :Access denied."
        return
    }
    
    if {$text == ""} {
        putserv "NOTICE $nick :Syntax: unban <hostmask>"
        return
    }
    
    set mask $text
    if {[isban $mask $chan]} {
        killchanban $chan $mask
        putlog "UNBAN: $nick unbanned $mask from $chan"
        putserv "NOTICE $nick :Unbanned $mask from $chan"
    } else {
        putserv "NOTICE $nick :$mask is not banned in $chan"
    }
}

# ========================================================================
# USER MANAGEMENT COMMANDS
# ========================================================================

proc pub_chattr {nick uhost hand chan text} {
    if {![is_admin $nick $chan]} {
        putserv "NOTICE $nick :Access denied."
        return
    }
    
    set args [split $text]
    set target_handle [lindex $args 0]
    set new_flags [lindex $args 1]
    set target_chan [lindex $args 2]
    
    if {$target_handle == ""} {
        putserv "NOTICE $nick :Syntax: chattr <handle> [flags] [#channel]"
        return
    }
    
    if {![validuser $target_handle]} {
        putserv "NOTICE $nick :User $target_handle not found."
        return
    }
    
    if {$new_flags == ""} {
        if {$target_chan != ""} {
            set flags [chattr $target_handle $target_chan]
            putserv "NOTICE $nick :Flags for $target_handle on $target_chan: $flags"
        } else {
            set global_flags [chattr $target_handle]
            putserv "NOTICE $nick :Global flags for $target_handle: $global_flags"
            foreach c [channels] {
                set chan_flags [chattr $target_handle $c]
                if {$chan_flags != ""} {
                    putserv "NOTICE $nick : $c: $chan_flags"
                }
            }
        }
        return
    }
    
    # Parse operations
    set operations {}
    set current_op ""
    set i 0
    
    while {$i < [string length $new_flags]} {
        set char [string index $new_flags $i]
        if {$char == "+" || $char == "-"} {
            set current_op $char
        } elseif {$char == " "} {
        } else {
            if {$current_op != ""} {
                lappend operations "$current_op$char"
            } else {
                lappend operations "+$char"
            }
        }
        incr i
    }
    
    # Get my flags - distinguish between global and channel context
    set my_global_flags [chattr $hand]
    if {$target_chan != ""} {
        set my_chan_flags [chattr $hand $target_chan]
    } else {
        set my_chan_flags ""
    }
    
    # Check each operation
    foreach op $operations {
        set operator [string index $op 0]
        set flag [string index $op 1]
        
        set has_permission 0
        
        if {$target_chan != ""} {
            # Setting channel flags - check channel permissions
            if {[string match "*n*" $my_chan_flags] || [string match "*n*" $my_global_flags]} {
                set has_permission 1
            } elseif {[string match "*m*" $my_chan_flags] || [string match "*m*" $my_global_flags]} {
                if {$flag != "n"} {
                    set has_permission 1
                }
            } elseif {[string match "*o*" $my_chan_flags] || [string match "*o*" $my_global_flags]} {
                if {[lsearch -exact {v f} $flag] != -1} {
                    set has_permission 1
                }
            }
        } else {
            # Setting GLOBAL flags - need GLOBAL permissions only
            if {[string match "*n*" $my_global_flags]} {
                set has_permission 1
            } elseif {[string match "*m*" $my_global_flags]} {
                if {$flag != "n"} {
                    set has_permission 1
                }
            } elseif {[string match "*o*" $my_global_flags]} {
                if {[lsearch -exact {v f} $flag] != -1} {
                    set has_permission 1
                }
            }
        }
        
        if {!$has_permission} {
            if {$target_chan != ""} {
                putserv "NOTICE $nick :Access denied. You don't have flag '$flag' on $target_chan to give/remove it"
            } else {
                putserv "NOTICE $nick :Access denied. You don't have global flag '$flag' to give/remove it"
            }
            return
        }
        
        # Special protection: cannot remove own critical flags
        if {$operator == "-" && $target_handle == $hand} {
            if {[lsearch -exact {n m o} $flag] != -1} {
                putserv "NOTICE $nick :Access denied. Cannot remove your own critical flag: $flag"
                return
            }
        }
    }
    
    # Apply the changes
    if {$target_chan != ""} {
        if {[catch {chattr $target_handle $new_flags $target_chan} err]} {
            putserv "NOTICE $nick :Error setting flags: $err"
            return
        }
        putserv "NOTICE $nick :Set flags for $target_handle on $target_chan: $new_flags"
        putlog "CHATTR: $nick set flags for $target_handle on $target_chan: $new_flags"
    } else {
        if {[catch {chattr $target_handle $new_flags} err]} {
            putserv "NOTICE $nick :Error setting flags: $err"
            return
        }
        putserv "NOTICE $nick :Set global flags for $target_handle: $new_flags"
        putlog "CHATTR: $nick set global flags for $target_handle: $new_flags"
    }
}

proc pub_match {nick uhost hand chan text} {
    if {![is_voice_level $nick $chan]} {
        putserv "NOTICE $nick :Access denied."
        return
    }
    
    set args [split $text]
    set flags [lindex $args 0]
    set target_chan [lindex $args 1]
    
    if {$flags == ""} {
        putserv "NOTICE $nick :Syntax: match <flags> \[#channel\]"
        return
    }
    
    if {$target_chan != ""} {
        set matches [userlist $flags $target_chan]
        putserv "NOTICE $nick :Users with flags $flags on $target_chan:"
    } else {
        set matches [userlist $flags]
        putserv "NOTICE $nick :Users with global flags $flags:"
    }
    
    if {[llength $matches] == 0} {
        putserv "NOTICE $nick :No matches found."
    } else {
        set count 0
        set output ""
        foreach user $matches {
            append output "$user "
            incr count
            if {$count >= 10} {
                putserv "NOTICE $nick :$output"
                set output ""
                set count 0
            }
        }
        if {$output != ""} {
            putserv "NOTICE $nick :$output"
        }
        putserv "NOTICE $nick :Total: [llength $matches] users"
    }
}

proc pub_adduser {nick uhost hand chan text} {
    if {![is_admin $nick $chan]} {
        putserv "NOTICE $nick :Access denied."
        return
    }
    
    set args [split $text]
    set new_handle [lindex $args 0]
    set hostmask [lindex $args 1]
    
    if {$new_handle == "" || $hostmask == ""} {
        putserv "NOTICE $nick :Syntax: adduser <handle> <hostmask>"
        return
    }
    
    if {[validuser $new_handle]} {
        putserv "NOTICE $nick :User $new_handle already exists."
        return
    }
    
    adduser $new_handle $hostmask
    putserv "NOTICE $nick :Added user $new_handle with hostmask $hostmask"
    putlog "ADDUSER: $nick added user $new_handle ($hostmask)"
}

proc pub_deluser {nick uhost hand chan text} {
    if {![is_admin $nick $chan]} {
        putserv "NOTICE $nick :Access denied."
        return
    }
    
    if {$text == ""} {
        putserv "NOTICE $nick :Syntax: deluser <handle>"
        return
    }
    
    set target_handle $text
    
    if {![validuser $target_handle]} {
        putserv "NOTICE $nick :User $target_handle not found."
        return
    }
    
    if {$target_handle == $hand} {
        putserv "NOTICE $nick :You cannot delete yourself."
        return
    }
    
    deluser $target_handle
    putserv "NOTICE $nick :Deleted user $target_handle"
    putlog "DELUSER: $nick deleted user $target_handle"
}

proc pub_addhost {nick uhost hand chan text} {
    if {![is_admin $nick $chan]} {
        putserv "NOTICE $nick :Access denied."
        return
    }
    
    set args [split $text]
    set target_handle [lindex $args 0]
    set hostmask [lindex $args 1]
    
    if {$target_handle == "" || $hostmask == ""} {
        putserv "NOTICE $nick :Syntax: addhost <handle> <hostmask>"
        return
    }
    
    if {![validuser $target_handle]} {
        putserv "NOTICE $nick :User $target_handle not found."
        return
    }
    
    setuser $target_handle HOSTS $hostmask
    putserv "NOTICE $nick :Added hostmask $hostmask to $target_handle"
    putlog "ADDHOST: $nick added hostmask $hostmask to $target_handle"
}

proc pub_delhost {nick uhost hand chan text} {
    if {![is_admin $nick $chan]} {
        putserv "NOTICE $nick :Access denied."
        return
    }
    
    set args [split $text]
    set target_handle [lindex $args 0]
    set hostmask [lindex $args 1]
    
    if {$target_handle == "" || $hostmask == ""} {
        putserv "NOTICE $nick :Syntax: delhost <handle> <hostmask>"
        return
    }
    
    if {![validuser $target_handle]} {
        putserv "NOTICE $nick :User $target_handle not found."
        return
    }
    
    delhost $target_handle $hostmask
    putserv "NOTICE $nick :Removed hostmask $hostmask from $target_handle"
    putlog "DELHOST: $nick removed hostmask $hostmask from $target_handle"
}

proc pub_whois {nick uhost hand chan text} {
    # Se chamado com chan vazio, escolhe um canal onde o bot esteja
    if {$chan == ""} {
        set chan [lindex [channels] 0]
    }
    # Verificação de permissões: voice ou global admin
    if {![is_voice_level $nick $chan] && ![is_global_admin $nick]} {
        putserv "NOTICE $nick :Access denied."
        return
    }
    if {$text == ""} {
        putserv "NOTICE $nick :Syntax: whois <handle>"
        return
    }
    set target $text
    if {![validuser $target]} {
        putserv "NOTICE $nick :User $target not found."
        return
    }

    putserv "NOTICE $nick := Info for $target ="
    # Global flags
    set gflags [chattr $target]
    putserv "NOTICE $nick :Global flags: $gflags"
    # Flags por canal
    foreach c [channels] {
        set cflags [chattr $target $c]
        if {$cflags ne ""} {
            putserv "NOTICE $nick :$c: $cflags"
        }
    }
    # Hostmasks
    set hosts [getuser $target HOSTS]
    if {[llength $hosts] > 0} {
        putserv "NOTICE $nick :Hostmasks: [join $hosts {, }]"
    }
    # Last seen com catch
    set last ""
    if {[catch {set last [getuser $target LASTSEEN]} err1]} {
        catch {set last [getuser $target lastseen]}
    }
    if {$last ne ""} {
        putserv "NOTICE $nick :Last seen: $last"
    }
}

proc msg_pub_whois {nick uhost hand text} {
    pub_whois $nick $uhost $hand "" $text
}



# ========================================================================
# CHANNEL INFO COMMANDS
# ========================================================================

proc pub_chaninfo {nick uhost hand chan text} {
    if {![is_voice_level $nick $chan]} {
        putserv "NOTICE $nick :Access denied."
        return
    }
    set target_chan $chan
    if {$text ne ""} {
        set target_chan $text
    }

    set vars {
        chanmode need-op need-invite need-key need-unban need-limit
        idle-kick stopnethack-mode revenge-mode ban-type ban-time
        exempt-time invite-time flood-chan flood-ctcp flood-join
        flood-kick flood-deop flood-nick aop-delay enforcebans
        dynamicbans userbans autoop autohalfop bitch greet
        protectops protecthalfops protectfriends dontkickops
        inactive statuslog revenge revengebot secret shared
        autovoice cycle seen dynamicexempts userexempts
        dynamicinvites userinvites nodesynch static
    }

    set pairs {}
    foreach v $vars {
        if {[catch {set val [channel get $target_chan $v]} err]} {
            set val "(error)"
        }
        if {[string match \{*\} $val]} {
            set list [lrange [string trim $val \{\}] 0 end]
            set val [join $list ", "]
        }
        lappend pairs "$v: $val"
    }

    putserv "NOTICE $nick :=== CONFIG FOR $target_chan ==="
    set group_size 6
    for {set i 0} {$i < [llength $pairs]} {incr i $group_size} {
        set slice [lrange $pairs $i [expr {$i + $group_size - 1}]]
        putserv "NOTICE $nick :[join $slice { ; }]"
    }

    putserv "NOTICE $nick :--- CHANNEL STATUS ---"
    
    if {[catch {set modes [getchanmode $target_chan]} err]} {
        set modes "unknown"
    }
    putserv "NOTICE $nick :Channel modes: $modes"
    
    if {[catch {set all_users [chanlist $target_chan]} err]} {
        set user_count 0
        set ops_count 0
        set voiced_count 0
    } else {
        set user_count [llength $all_users]
        set ops_count 0
        set voiced_count 0
        
        foreach user $all_users {
            if {[isop $user $target_chan]} { incr ops_count }
            if {[isvoice $user $target_chan]} { incr voiced_count }
        }
    }
    
    putserv "NOTICE $nick :Users: $user_count | Ops: $ops_count | Voiced: $voiced_count"
    
    if {[catch {set bans [chanbans $target_chan]} err]} {
        set bans_count 0
    } else {
        set bans_count [llength $bans]
    }
    putserv "NOTICE $nick :Active bans: $bans_count"
    
    if {$user_count > 0 && $user_count <= 10} {
        putserv "NOTICE $nick :Users online: [join $all_users {, }]"
    } elseif {$user_count > 10} {
        set sample [lrange $all_users 0 9]
        putserv "NOTICE $nick :Users online (first 10): [join $sample {, }] ... and [expr {$user_count - 10}] more"
    }
    
    if {[catch {set topic [topic $target_chan]} err] == 0 && $topic ne ""} {
        putserv "NOTICE $nick :Topic: $topic"
    }
    
    if {[catch {set status [channel info $target_chan]} err2] == 0} {
        set fields [split [string trim $status] " "]
        set flags_start 20
        if {[llength $fields] > $flags_start} {
            set flags [lrange $fields $flags_start end]
            set enabled {}
            foreach flag $flags {
                if {[string index $flag 0] eq "+"} {
                    lappend enabled [string range $flag 1 end]
                }
            }
            if {[llength $enabled] > 0} {
                putserv "NOTICE $nick :Enabled flags: [join $enabled {, }]"
            }
        }
    }
}

proc pub_chanset {nick uhost hand chan text} {
    set args [split $text]
    
    set target_chan $chan
    if {[llength $args] > 0 && [string index [lindex $args 0] 0] == "#"} {
        set target_chan [lindex $args 0]
        set setting [lindex $args 1]
        set value [lindex $args 2]
    } else {
        set setting [lindex $args 0]
        set value [lindex $args 1]
    }
    
    if {![is_admin_on_channel $nick $target_chan]} {
        putserv "NOTICE $nick :Access denied on $target_chan."
        return
    }
    
    if {$setting == ""} {
        putserv "NOTICE $nick :Syntax: chanset \[#channel\] <setting> \[value\]"
        return
    }
    
    if {$value == ""} {
        if {[catch {set current [channel get $target_chan $setting]} err]} {
            putserv "NOTICE $nick :Error getting $setting for $target_chan: $err"
        } else {
            putserv "NOTICE $nick :$setting for $target_chan: $current"
        }
    } else {
        if {[catch {channel set $target_chan $setting $value} err]} {
            putserv "NOTICE $nick :Error setting $setting for $target_chan: $err"
        } else {
            putserv "NOTICE $nick :Set $setting to '$value' for $target_chan"
            putlog "CHANSET: $nick set $setting to '$value' for $target_chan"
        }
    }
}

proc pub_channels {nick uhost hand chan text} {
    if {![is_voice_level $nick $chan]} {
        putserv "NOTICE $nick :Access denied."
        return
    }
    
    putserv "NOTICE $nick :=== BOT CHANNELS ==="
    
    foreach c [channels] {
        set user_count 0
        if {[catch {set users [chanlist $c]} err] == 0} {
            set user_count [llength $users]
        }
        
        set protections {}
        if {[get_channel_setting $c msgflood]} { lappend protections "msgflood" }
        if {[get_channel_setting $c repeatflood]} { lappend protections "repeat" }
        if {[get_channel_setting $c badwords]} { lappend protections "badwords" }
        if {[get_channel_setting $c caps]} { lappend protections "caps" }
        if {[get_channel_setting $c spam]} { lappend protections "spam" }
        if {[get_channel_setting $c badpart]} { lappend protections "badpart" }
        if {[get_channel_setting $c badchan]} { lappend protections "badchan" }
        
        set prot_text [join $protections ","]
        if {$prot_text == ""} { set prot_text "none" }
        
        putserv "NOTICE $nick :$c ($user_count users) - Protections: $prot_text"
    }
}

# ========================================================================
# PROTECTION CONFIGURATION COMMANDS
# ========================================================================

proc pub_protection {nick uhost hand chan text} {
    set args [split $text]
    set numargs [llength $args]
    
    set target_chan $chan
    if {$numargs == 3 && [string index [lindex $args 2] 0] == "#"} {
        set target_chan [lindex $args 2]
    }
    
    if {![is_admin_on_channel $nick $target_chan]} {
        putserv "NOTICE $nick :Access denied on $target_chan."
        return
    }
    
    if {$numargs == 0 || ($numargs == 1 && [string index [lindex $args 0] 0] == "#")} {
        if {$numargs == 1} { set target_chan [lindex $args 0] }
        
        putserv "NOTICE $nick :=== PROTECTION STATUS FOR $target_chan ==="
        
        set msgflood_status [get_channel_setting $target_chan msgflood]
        set maxmsg [get_channel_setting $target_chan maxmsg]
        set msgtime [get_channel_setting $target_chan msgtime]
        set msgflood_punishment [get_channel_setting $target_chan msgflood_punishment]
        set msgflood_bantime [get_channel_setting $target_chan msgflood_bantime]
        putserv "NOTICE $nick :msgflood: $msgflood_status (max: $maxmsg in ${msgtime}s) - punishment: $msgflood_punishment (${msgflood_bantime}min)"
        
        set repeatflood_status [get_channel_setting $target_chan repeatflood]
        set maxrepeat [get_channel_setting $target_chan maxrepeat]
        set repeattime [get_channel_setting $target_chan repeattime]
        set repeatflood_punishment [get_channel_setting $target_chan repeatflood_punishment]
        set repeatflood_bantime [get_channel_setting $target_chan repeatflood_bantime]
        putserv "NOTICE $nick :repeatflood: $repeatflood_status (max: $maxrepeat in ${repeattime}s) - punishment: $repeatflood_punishment (${repeatflood_bantime}min)"
        
        set badwords_count [llength [get_channel_badwords $target_chan]]
        set badwords_status [get_channel_setting $target_chan badwords]
        set badwords_punishment [get_channel_setting $target_chan badwords_punishment]
        set badwords_bantime [get_channel_setting $target_chan badwords_bantime]
        putserv "NOTICE $nick :badwords: $badwords_status ($badwords_count words) - punishment: $badwords_punishment (${badwords_bantime}min)"
        
        set badpart_status [get_channel_setting $target_chan badpart]
        set badpart_punishment [get_channel_setting $target_chan badpart_punishment]
        set badpart_bantime [get_channel_setting $target_chan badpart_bantime]
        putserv "NOTICE $nick :badpart: $badpart_status - punishment: $badpart_punishment (${badpart_bantime}min)"
        
        set badchans_count [llength [get_channel_badchans $target_chan]]
        set badchan_status [get_channel_setting $target_chan badchan]
        set badchan_punishment [get_channel_setting $target_chan badchan_punishment]
        set badchan_bantime [get_channel_setting $target_chan badchan_bantime]
        putserv "NOTICE $nick :badchan: $badchan_status ($badchans_count channels) - punishment: $badchan_punishment (${badchan_bantime}min)"
        
        set caps_status [get_channel_setting $target_chan caps]
        set caps_percent [get_channel_setting $target_chan caps_percent]
        set caps_minlen [get_channel_setting $target_chan caps_minlen]
        set caps_punishment [get_channel_setting $target_chan caps_punishment]
        set caps_bantime [get_channel_setting $target_chan caps_bantime]
        putserv "NOTICE $nick :caps: $caps_status (max: ${caps_percent}% in ${caps_minlen}+ chars) - punishment: $caps_punishment (${caps_bantime}min)"
        
        set spamwords_count [llength [get_channel_spamwords $target_chan]]
        set spam_status [get_channel_setting $target_chan spam]
        set spam_time [get_channel_setting $target_chan spam_time]
        set spam_punishment [get_channel_setting $target_chan spam_punishment]
        set spam_bantime [get_channel_setting $target_chan spam_bantime]
        putserv "NOTICE $nick :spam: $spam_status (${spam_time}s check, $spamwords_count words) - punishment: $spam_punishment (${spam_bantime}min)"
        
        return
    }
    
    set option [lindex $args 0]
    set value [lindex $args 1]
    
    if {$value == ""} {
        putserv "NOTICE $nick :Current value of $option for $target_chan: [get_channel_setting $target_chan $option]"
        return
    }
    
    set_channel_setting $target_chan $option $value
    putserv "NOTICE $nick :Set $option to $value for $target_chan"
    putlog "PROTECTION: $nick set $option to $value for $target_chan"
}

proc pub_protectionall {nick uhost hand chan text} {
    set hand_user [nick2hand $nick]
    if {![matchattr $hand_user n]} {
        putserv "NOTICE $nick :Access denied. Global owner required."
        return
    }
    
    set args [split $text]
    if {[llength $args] != 2} {
        putserv "NOTICE $nick :Syntax: protectionall <option> <value>"
        return
    }
    
    set option [lindex $args 0]
    set value [lindex $args 1]
    
    set count 0
    foreach c [channels] {
        set_channel_setting $c $option $value
        incr count
    }
    
    putserv "NOTICE $nick :Set $option to $value for all $count channels"
    putlog "PROTECTIONALL: $nick set $option to $value for all channels"
}

proc pub_copychan {nick uhost hand chan text} {
    if {![is_admin $nick $chan]} {
        putserv "NOTICE $nick :Access denied."
        return
    }
    
    set args [split $text]
    if {[llength $args] != 2} {
        putserv "NOTICE $nick :Syntax: copychan <#source> <#dest>"
        return
    }
    
    set source [lindex $args 0]
    set dest [lindex $args 1]
    
    # Verificar se os canais existem
    if {![validchan $source]} {
        putserv "NOTICE $nick :Source channel $source not found."
        return
    }
    
    if {![validchan $dest]} {
        putserv "NOTICE $nick :Destination channel $dest not found."
        return
    }
    
    if {![is_admin_on_channel $nick $source] || ![is_admin_on_channel $nick $dest]} {
        putserv "NOTICE $nick :Access denied. You need admin on both channels."
        return
    }
    
    global default_settings
    set count 0
    
    foreach setting [array names default_settings] {
        set value [get_channel_setting $source $setting]
        set_channel_setting $dest $setting $value
        incr count
    }
    
    # Copy word lists
    global channel_badwords channel_badchans channel_spamwords
    
    if {[info exists channel_badwords($source)]} {
        set channel_badwords($dest) $channel_badwords($source)
        save_channel_badwords $dest
    }
    
    if {[info exists channel_badchans($source)]} {
        set channel_badchans($dest) $channel_badchans($source)
        save_channel_badchans $dest
    }
    
    if {[info exists channel_spamwords($source)]} {
        set channel_spamwords($dest) $channel_spamwords($source)
        save_channel_spamwords $dest
    }
    
    putserv "NOTICE $nick :Copied $count settings and word lists from $source to $dest"
    putlog "COPYCHAN: $nick copied settings from $source to $dest"
}

proc pub_resetchan {nick uhost hand chan text} {
    set target_chan $chan
    if {$text != ""} { set target_chan $text }
    
    if {![is_admin_on_channel $nick $target_chan]} {
        putserv "NOTICE $nick :Access denied on $target_chan."
        return
    }
    
    global default_settings channel_settings
    global channel_badwords channel_badchans channel_spamwords
    
    set count 0
    foreach setting [array names default_settings] {
        if {[info exists channel_settings($target_chan,$setting)]} {
            unset channel_settings($target_chan,$setting)
            incr count
        }
    }
    
    if {[info exists channel_badwords($target_chan)]} {
        unset channel_badwords($target_chan)
    }
    if {[info exists channel_badchans($target_chan)]} {
        unset channel_badchans($target_chan)
    }
    if {[info exists channel_spamwords($target_chan)]} {
        unset channel_spamwords($target_chan)
    }
    
    save_channel_config $target_chan
    save_channel_badwords $target_chan
    save_channel_badchans $target_chan  
    save_channel_spamwords $target_chan
    
    putserv "NOTICE $nick :Reset $target_chan to default settings (cleared $count overrides and all word lists)"
    putlog "RESETCHAN: $nick reset $target_chan to defaults"
}

# ========================================================================
# WORD LIST MANAGEMENT COMMANDS
# ========================================================================

proc pub_badwords {nick uhost hand chan text} {
    set args [split $text]
    set action [lindex $args 0]
    set word [lindex $args 1]
    set target_chan $chan
    
    # Check if last argument is a channel
    if {[llength $args] > 2 && [string index [lindex $args end] 0] == "#"} {
        set target_chan [lindex $args end]
        set word [join [lrange $args 1 end-1] " "]
    }
    
    # Permission check
    if {![is_admin_on_channel $nick $target_chan]} {
        putserv "NOTICE $nick :Access denied on $target_chan."
        return
    }
    
    switch -nocase $action {
        "add" {
            if {$word == ""} {
                putserv "NOTICE $nick :Syntax: badwords add <word> \[#channel\]"
                return
            }
            if {[add_channel_badword $target_chan $word]} {
                putserv "NOTICE $nick :Added '$word' to badwords for $target_chan"
                putlog "BADWORDS: $nick added '$word' to badwords for $target_chan"
            } else {
                putserv "NOTICE $nick :Word '$word' already exists in badwords for $target_chan"
            }
        }
        "del" - "delete" - "remove" {
            if {$word == ""} {
                putserv "NOTICE $nick :Syntax: badwords del <word> \[#channel\]"
                return
            }
            if {[del_channel_badword $target_chan $word]} {
                putserv "NOTICE $nick :Removed '$word' from badwords for $target_chan"
                putlog "BADWORDS: $nick removed '$word' from badwords for $target_chan"
            } else {
                putserv "NOTICE $nick :Word '$word' not found in badwords for $target_chan"
            }
        }
        "list" {
            if {$word != "" && [string index $word 0] == "#"} {
                set target_chan $word
            }
            set words [get_channel_badwords $target_chan]
            if {[llength $words] == 0} {
                putserv "NOTICE $nick :No badwords defined for $target_chan"
            } else {
                putserv "NOTICE $nick :Badwords for $target_chan ([llength $words]): [join $words {, }]"
            }
        }
        "clear" {
            if {[llength $args] > 1 && [string index [lindex $args 1] 0] == "#"} {
                set target_chan [lindex $args 1]
            }
            global channel_badwords
            set channel_badwords($target_chan) {}
            save_channel_badwords $target_chan
            putserv "NOTICE $nick :Cleared all badwords for $target_chan"
            putlog "BADWORDS: $nick cleared all badwords for $target_chan"
        }
        default {
            putserv "NOTICE $nick :Syntax: badwords <add|del|list|clear> \[word\] \[#channel\]"
        }
    }
}

proc pub_badchans {nick uhost hand chan text} {
    set args [split $text]
    set action [lindex $args 0]
    set badchan [lindex $args 1]
    set target_chan $chan
    
    if {[llength $args] > 2 && [string index [lindex $args end] 0] == "#"} {
        set target_chan [lindex $args end]
        set badchan [join [lrange $args 1 end-1] " "]
    }
    
    if {![is_admin_on_channel $nick $target_chan]} {
        putserv "NOTICE $nick :Access denied on $target_chan."
        return
    }
    
    switch -nocase $action {
        "add" {
            if {$badchan == ""} {
                putserv "NOTICE $nick :Syntax: badchans add <#channel> \[#target_channel\]"
                return
            }
            if {[add_channel_badchan $target_chan $badchan]} {
                putserv "NOTICE $nick :Added '$badchan' to bad channels for $target_chan"
                putlog "BADCHANS: $nick added '$badchan' to bad channels for $target_chan"
            } else {
                putserv "NOTICE $nick :Channel '$badchan' already exists in bad channels for $target_chan"
            }
        }
        "del" - "delete" - "remove" {
            if {$badchan == ""} {
                putserv "NOTICE $nick :Syntax: badchans del <#channel> \[#target_channel\]"
                return
            }
            if {[del_channel_badchan $target_chan $badchan]} {
                putserv "NOTICE $nick :Removed '$badchan' from bad channels for $target_chan"
                putlog "BADCHANS: $nick removed '$badchan' from bad channels for $target_chan"
            } else {
                putserv "NOTICE $nick :Channel '$badchan' not found in bad channels for $target_chan"
            }
        }
        "list" {
            if {$badchan != "" && [string index $badchan 0] == "#"} {
                set target_chan $badchan
            }
            set chans [get_channel_badchans $target_chan]
            if {[llength $chans] == 0} {
                putserv "NOTICE $nick :No bad channels defined for $target_chan"
            } else {
                putserv "NOTICE $nick :Bad channels for $target_chan ([llength $chans]): [join $chans {, }]"
            }
        }
        "clear" {
            if {[llength $args] > 1 && [string index [lindex $args 1] 0] == "#"} {
                set target_chan [lindex $args 1]
            }
            global channel_badchans
            set channel_badchans($target_chan) {}
            save_channel_badchans $target_chan
            putserv "NOTICE $nick :Cleared all bad channels for $target_chan"
            putlog "BADCHANS: $nick cleared all bad channels for $target_chan"
        }
        default {
            putserv "NOTICE $nick :Syntax: badchans <add|del|list|clear> \[#channel\] \[#target_channel\]"
        }
    }
}

proc pub_spamwords {nick uhost hand chan text} {
    set args [split $text]
    set action [lindex $args 0]
    set word [lindex $args 1]
    set target_chan $chan
    
    if {[llength $args] > 2 && [string index [lindex $args end] 0] == "#"} {
        set target_chan [lindex $args end]
        set word [join [lrange $args 1 end-1] " "]
    }
    
    if {![is_admin_on_channel $nick $target_chan]} {
        putserv "NOTICE $nick :Access denied on $target_chan."
        return
    }
    
    switch -nocase $action {
        "add" {
            if {$word == ""} {
                putserv "NOTICE $nick :Syntax: spamwords add <word> \[#channel\]"
                return
            }
            if {[add_channel_spamword $target_chan $word]} {
                putserv "NOTICE $nick :Added '$word' to spam words for $target_chan"
                putlog "SPAMWORDS: $nick added '$word' to spam words for $target_chan"
            } else {
                putserv "NOTICE $nick :Word '$word' already exists in spam words for $target_chan"
            }
        }
        "del" - "delete" - "remove" {
            if {$word == ""} {
                putserv "NOTICE $nick :Syntax: spamwords del <word> \[#channel\]"
                return
            }
            if {[del_channel_spamword $target_chan $word]} {
                putserv "NOTICE $nick :Removed '$word' from spam words for $target_chan"
                putlog "SPAMWORDS: $nick removed '$word' from spam words for $target_chan"
            } else {
                putserv "NOTICE $nick :Word '$word' not found in spam words for $target_chan"
            }
        }
        "list" {
            if {$word != "" && [string index $word 0] == "#"} {
                set target_chan $word
            }
            set words [get_channel_spamwords $target_chan]
            if {[llength $words] == 0} {
                putserv "NOTICE $nick :No spam words defined for $target_chan"
            } else {
                putserv "NOTICE $nick :Spam words for $target_chan ([llength $words]): [join $words {, }]"
            }
        }
        "clear" {
            if {[llength $args] > 1 && [string index [lindex $args 1] 0] == "#"} {
                set target_chan [lindex $args 1]
            }
            global channel_spamwords
            set channel_spamwords($target_chan) {}
            save_channel_spamwords $target_chan
            putserv "NOTICE $nick :Cleared all spam words for $target_chan"
            putlog "SPAMWORDS: $nick cleared all spam words for $target_chan"
        }
        default {
            putserv "NOTICE $nick :Syntax: spamwords <add|del|list|clear> \[word\] \[#channel\]"
        }
    }
}

# ========================================================================
# SYSTEM COMMANDS
# ========================================================================
proc pub_alias {nick uhost hand chan text} {
    if {![is_global_admin $nick]} {
        putserv "NOTICE $nick :Access denied. Global master/owner required."
        return
    }
    
    global command_aliases
    set args [split $text]
    set action [lindex $args 0]
    
    switch -nocase $action {
        "add" {
            set alias [lindex $args 1]
            set real_cmd [lindex $args 2]
            if {$alias == "" || $real_cmd == ""} {
                putserv "NOTICE $nick :Syntax: alias add <alias> <real_command>"
                return
            }
            
            # Validar que o comando real existe
            set valid_commands {op deop voice devoice kick ban unban chattr match adduser deluser addhost delhost whois chaninfo chanset protection protectionall channels copychan resetchan badwords badchans spamwords alias char save reload help update addchan delchan}
            
            if {[lsearch -exact $valid_commands $real_cmd] == -1} {
                putserv "NOTICE $nick :Invalid command: $real_cmd"
                putserv "NOTICE $nick :Valid commands: [join $valid_commands {, }]"
                return
            }
            
            set command_aliases($alias) $real_cmd
            save_aliases
            rebind_all_commands
            putserv "NOTICE $nick :Added alias: $alias -> $real_cmd"
            putlog "ALIAS: $nick added alias $alias -> $real_cmd"
        }
        "del" - "delete" - "remove" {
            set alias [lindex $args 1]
            if {[info exists command_aliases($alias)]} {
                unset command_aliases($alias)
                save_aliases
                rebind_all_commands
                putserv "NOTICE $nick :Deleted alias: $alias"
                putlog "ALIAS: $nick deleted alias $alias"
            } else {
                putserv "NOTICE $nick :Alias $alias not found"
            }
        }
        "list" {
            putserv "NOTICE $nick :=== COMMAND ALIASES ==="
            set aliases [array get command_aliases]
            if {[llength $aliases] == 0} {
                putserv "NOTICE $nick :No aliases defined."
                return
            }
            # aliases é uma lista {alias1 cmd1 alias2 cmd2 …}
            set pairs {}
            foreach {a c} $aliases {
                lappend pairs "$a->$c"
            }
            # Envia em grupos de 5 pares por linha
            set group_size 5
            for {set i 0} {$i < [llength $pairs]} {incr i $group_size} {
                set slice [lrange $pairs $i [expr {$i + $group_size - 1}]]
                putserv "NOTICE $nick :[join $slice { , }]"
            }
        }
        "reset" {
            array unset command_aliases
            load_aliases
            rebind_all_commands
            putserv "NOTICE $nick :Reset aliases to defaults"
            putlog "ALIAS: $nick reset aliases to defaults"
        }
        default {
            putserv "NOTICE $nick :Syntax: alias <add|del|list|reset> \[alias\] \[command\]"
            putserv "NOTICE $nick :Examples: alias add x kick | alias del x | alias list"
        }
    }
}

proc pub_char {nick uhost hand chan text} {
    if {![is_global_admin $nick]} {
        putserv "NOTICE $nick :Access denied. Global master/owner required."
        return
    }
    
    global customscript
    
    if {$text == ""} {
        putserv "NOTICE $nick :Current command characters: $customscript(cmdchars)"
        return
    }
    
    set old_chars $customscript(cmdchars)
    set customscript(cmdchars) $text
    
    putserv "NOTICE $nick :Command characters changed from '$old_chars' to '$text'"
    putlog "CHAR: $nick changed command characters to '$text'"
    
    rebind_all_commands
}

proc pub_save {nick uhost hand chan text} {
    if {![is_global_admin $nick]} {
        putserv "NOTICE $nick :Access denied. Global master/owner required."
        return
    }
    
    set saved_channels 0
    foreach c [channels] {
        save_channel_config $c
        save_channel_badwords $c
        save_channel_badchans $c
        save_channel_spamwords $c
        incr saved_channels
    }
    
    putserv "NOTICE $nick :Saved configuration for $saved_channels channels"
    putlog "SAVE: $nick saved all configurations"
}

proc pub_update {nick uhost hand chan text} {
    if {![is_global_admin $nick]} {
        putserv "NOTICE $nick :Access denied. Global master/owner required."
        return
    }
    putserv "NOTICE $nick :Starting update..."
    # Caminho absoluto do script
    set scriptPath [file normalize "scripts/allinone.tcl"]
    set url $::customscript(update_url)
    if {[catch {fetch_and_write $url $scriptPath} err]} {
        putserv "NOTICE $nick :Update failed: $err"
        putlog "UPDATE ERROR: $err"
        return
    }
    putserv "NOTICE $nick :Update applied. Reloading..."
    putlog "UPDATE: Script updated from $url"
    # Re-sourça o script atualizado (redefine todas as procs)
    source $scriptPath
    putserv "REHASH"
    putserv "NOTICE $nick :Reload complete."
    putlog "UPDATE: Reload complete after update"
}


proc pub_reload {nick uhost hand chan text} {
    if {![is_global_admin $nick]} {
        putserv "NOTICE $nick :Access denied. Global master/owner required."
        return
    }

    set loaded_channels 0
    foreach c [channels] {
        load_channel_config $c
        load_channel_badwords $c
        load_channel_badchans $c
        load_channel_spamwords $c
        incr loaded_channels
    }

    putserv "NOTICE $nick :Reloaded configuration for $loaded_channels channels"
    putlog "RELOAD: $nick reloaded all configurations"

    # Faz também um rehash no Eggdrop
    putserv "REHASH"
    putserv "NOTICE $nick :Eggdrop rehashed"
}


proc pub_help {nick uhost hand chan text} {
    global customscript
    
    putserv "NOTICE $nick :=== ALLINONE TCL HELP ==="
    putserv "NOTICE $nick :Command chars: $customscript(cmdchars) | Use: !help <topic> for details"
    putserv "NOTICE $nick :"
    
    if {$text != ""} {
        set args [split $text]
        set first_word [lindex $args 0]
        set topic [string tolower $first_word]
        
        switch $topic {
            "channel" {
				putserv "NOTICE $nick :=== CHANNEL MANAGEMENT ==="
				putserv "NOTICE $nick :addchan <#channel> \[key\]   – Add & join a new channel"
				putserv "NOTICE $nick :delchan <#channel>        – Part & remove a channel"
				putserv "NOTICE $nick :op/deop <nick>           – Give or take ops"
				putserv "NOTICE $nick :voice/devoice <nick>     – Give or take voice"
				putserv "NOTICE $nick :kick <nick> \[reason\]     – Kick a user"
				putserv "NOTICE $nick :ban <nick/mask> \[mins\]   – Ban a user or mask"
				putserv "NOTICE $nick :unban <hostmask>         – Remove a ban"
			}
            "user" {
                putserv "NOTICE $nick :=== USER MANAGEMENT ==="
                putserv "NOTICE $nick :chattr <handle> \[flags\] \[#chan\] | adduser <handle> <mask>"
                putserv "NOTICE $nick :deluser <handle> | addhost/delhost <handle> <mask>"
                putserv "NOTICE $nick :whois <handle> | match <flags> \[#chan\]"
            }
            "info" {
                putserv "NOTICE $nick :=== CHANNEL INFO ==="
                putserv "NOTICE $nick :chaninfo \[#chan\] - Full channel config & live status"
                putserv "NOTICE $nick :chanset \[#chan\] \[setting\] \[value\] - Change eggdrop settings"
                putserv "NOTICE $nick :channels - List all channels with protection summary"
            }
            "protection" {
                putserv "NOTICE $nick :=== PROTECTION SYSTEM ==="
                putserv "NOTICE $nick :protection \[option\] \[value\] \[#chan\] - Configure protections"
                putserv "NOTICE $nick :protectionall <option> <value> - Apply to all channels"
                putserv "NOTICE $nick :copychan <#source> <#dest> | resetchan \[#chan\]"
                putserv "NOTICE $nick :"
                putserv "NOTICE $nick :Types: msgflood(maxmsg:5 msgtime:10s) repeatflood(maxrepeat:3 repeattime:60s)"
                putserv "NOTICE $nick :caps(caps_percent:70% caps_minlen:10) spam(spam_time:300s)"
                putserv "NOTICE $nick :badwords badpart badchan | Each: <type>_punishment <type>_bantime"
            }
            "lists" {
                putserv "NOTICE $nick :=== WORD LISTS (PER CHANNEL) ==="
                putserv "NOTICE $nick :badwords <add/del/list/clear> \[word\] \[#channel\] - Prohibited words"
                putserv "NOTICE $nick :badchans <add/del/list/clear> \[#channel\] \[#target\] - Prohibited channels"
                putserv "NOTICE $nick :spamwords <add/del/list/clear> \[word\] \[#channel\] - Spam triggers"
                putserv "NOTICE $nick :Each channel has independent word lists!"
            }
            "system" {
                putserv "NOTICE $nick :=== SYSTEM ==="
                putserv "NOTICE $nick :char <chars> - Change command characters"
                putserv "NOTICE $nick :save - Save all settings | reload - Reload settings"
                putserv "NOTICE $nick :Current chars: $customscript(cmdchars)"
            }
            "permissions" {
                putserv "NOTICE $nick :=== PERMISSION LEVELS ==="
                putserv "NOTICE $nick :Global Admin (n/m global): Full access to everything"
                putserv "NOTICE $nick :Channel Admin (n/m on channel): Manage that channel + lists"
                putserv "NOTICE $nick :Op (o): Channel management + view info"
                putserv "NOTICE $nick :Voice (v): View information commands only"
                putserv "NOTICE $nick :MSG usage: /msg botname !command - channel cmds need #channel"
            }
            "examples" {
                putserv "NOTICE $nick :=== USAGE EXAMPLES ==="
                putserv "NOTICE $nick :!protection - View current channel | !protection msgflood 1 - Enable"
                putserv "NOTICE $nick :!protection maxmsg 3 #soccer - Set for #soccer"
                putserv "NOTICE $nick :!badwords add spam - Add to current | !badwords add spam #soccer"
                putserv "NOTICE $nick :!badwords list #soccer | !chaninfo | !copychan #src #dest"
            }
            default {
                putserv "NOTICE $nick :Available topics: channel user info protection lists system permissions examples"
                putserv "NOTICE $nick :Usage: !help <topic>"
            }
        }
        return
    }
    
    putserv "NOTICE $nick :TOPICS: channel user info protection lists system permissions examples"
    putserv "NOTICE $nick :Quick: !addchan, !delchan, !op, !kick, !ban, !badwords, etc."
    putserv "NOTICE $nick :7 protections: msgflood repeatflood caps spam badwords badpart badchan"
    putserv "NOTICE $nick :Permissions: Global(n/m) Channel(n/m on chan) Op(o) Voice(v) | Works via /msg"
}

# ========================================================================
# PRIVATE MESSAGE COMMANDS
# ========================================================================

proc msg_pub_op {nick uhost hand text} { 
    set args [split $text]
    if {[llength $args] < 2} {
        putserv "NOTICE $nick :Syntax: op <nick> <#channel>"
        return
    }
    set target [lindex $args 0]
    set chan [lindex $args 1]
    
    if {![validchan $chan]} {
        putserv "NOTICE $nick :Invalid channel: $chan"
        return
    }
    
    pub_op $nick $uhost $hand $chan $target
}

proc msg_pub_deop {nick uhost hand text} { 
    set args [split $text]
    if {[llength $args] < 2} {
        putserv "NOTICE $nick :Syntax: deop <nick> <#channel>"
        return
    }
    set target [lindex $args 0]
    set chan [lindex $args 1]
    
    if {![validchan $chan]} {
        putserv "NOTICE $nick :Invalid channel: $chan"
        return
    }
    
    pub_deop $nick $uhost $hand $chan $target
}

proc msg_pub_voice {nick uhost hand text} { 
    set args [split $text]
    if {[llength $args] < 2} {
        putserv "NOTICE $nick :Syntax: voice <nick> <#channel>"
        return
    }
    set target [lindex $args 0]
    set chan [lindex $args 1]
    
    if {![validchan $chan]} {
        putserv "NOTICE $nick :Invalid channel: $chan"
        return
    }
    
    pub_voice $nick $uhost $hand $chan $target
}

proc msg_pub_devoice {nick uhost hand text} { 
    set args [split $text]
    if {[llength $args] < 2} {
        putserv "NOTICE $nick :Syntax: devoice <nick> <#channel>"
        return
    }
    set target [lindex $args 0]
    set chan [lindex $args 1]
    
    if {![validchan $chan]} {
        putserv "NOTICE $nick :Invalid channel: $chan"
        return
    }
    
    pub_devoice $nick $uhost $hand $chan $target
}

proc msg_pub_kick {nick uhost hand text} { 
    set args [split $text]
    if {[llength $args] < 2} {
        putserv "NOTICE $nick :Syntax: kick <nick> <#channel> \[reason\]"
        return
    }
    set target [lindex $args 0]
    set chan [lindex $args 1]
    set reason [join [lrange $args 2 end] " "]
    
    if {![validchan $chan]} {
        putserv "NOTICE $nick :Invalid channel: $chan"
        return
    }
    
    pub_kick $nick $uhost $hand $chan "$target $reason"
}

proc msg_pub_ban {nick uhost hand text} { 
    set args [split $text]
    if {[llength $args] < 2} {
        putserv "NOTICE $nick :Syntax: ban <nick/mask> <#channel> \[minutes\]"
        return
    }
    set target [lindex $args 0]
    set chan [lindex $args 1]
    set minutes [lindex $args 2]
    
    if {![validchan $chan]} {
        putserv "NOTICE $nick :Invalid channel: $chan"
        return
    }
    
    pub_ban $nick $uhost $hand $chan "$target $minutes"
}

proc msg_pub_unban {nick uhost hand text} { 
    set args [split $text]
    if {[llength $args] < 2} {
        putserv "NOTICE $nick :Syntax: unban <hostmask> <#channel>"
        return
    }
    set mask [lindex $args 0]
    set chan [lindex $args 1]
    
    if {![validchan $chan]} {
        putserv "NOTICE $nick :Invalid channel: $chan"
        return
    }
    
    pub_unban $nick $uhost $hand $chan $mask
}

proc msg_pub_chattr {nick uhost hand text} { pub_chattr $nick $uhost $hand "" $text }
proc msg_pub_match {nick uhost hand text} { pub_match $nick $uhost $hand "" $text }
proc msg_pub_adduser {nick uhost hand text} { pub_adduser $nick $uhost $hand "" $text }
proc msg_pub_deluser {nick uhost hand text} { pub_deluser $nick $uhost $hand "" $text }
proc msg_pub_addhost {nick uhost hand text} { pub_addhost $nick $uhost $hand "" $text }
proc msg_pub_delhost {nick uhost hand text} { pub_delhost $nick $uhost $hand "" $text }
proc msg_pub_whois {nick uhost hand text} { pub_whois $nick $uhost $hand "" $text }
proc msg_pub_chanset {nick uhost hand text} { pub_chanset $nick $uhost $hand $nick $text }
proc msg_pub_chaninfo {nick uhost hand text} { pub_chaninfo $nick $uhost $hand $nick $text }
proc msg_pub_protection {nick uhost hand text} { pub_protection $nick $uhost $hand $nick $text }
proc msg_pub_protectionall {nick uhost hand text} { pub_protectionall $nick $uhost $hand $nick $text }
proc msg_pub_channels {nick uhost hand text} { pub_channels $nick $uhost $hand $nick $text }
proc msg_pub_copychan {nick uhost hand text} { pub_copychan $nick $uhost $hand $nick $text }
proc msg_pub_resetchan {nick uhost hand text} { pub_resetchan $nick $uhost $hand $nick $text }
proc msg_pub_badwords {nick uhost hand text} { pub_badwords $nick $uhost $hand $nick $text }
proc msg_pub_badchans {nick uhost hand text} { pub_badchans $nick $uhost $hand $nick $text }
proc msg_pub_spamwords {nick uhost hand text} { pub_spamwords $nick $uhost $hand $nick $text }
proc msg_pub_char {nick uhost hand text} { pub_char $nick $uhost $hand $nick $text }
proc msg_pub_save {nick uhost hand text} { pub_save $nick $uhost $hand $nick $text }
proc msg_pub_reload {nick uhost hand text} { pub_reload $nick $uhost $hand $nick $text }
proc msg_pub_help {nick uhost hand text} { pub_help $nick $uhost $hand $nick $text }
proc msg_pub_alias {nick uhost hand text} { pub_alias $nick $uhost $hand $nick $text }
proc msg_pub_update {nick uhost hand text} { pub_update $nick $uhost $hand $nick $text }
proc msg_pub_addchan {nick uhost hand text} { pub_addchan $nick $uhost $hand $nick $text }
proc msg_pub_delchan {nick uhost hand text} { pub_delchan $nick $uhost $hand $nick $text }


# ========================================================================
# COMMAND BINDING AND INITIALIZATION
# ========================================================================

proc rebind_all_commands {} {
    global customscript command_aliases
    
    set commands {
        op pub_op
        deop pub_deop
        voice pub_voice
        devoice pub_devoice
        kick pub_kick
        ban pub_ban
        unban pub_unban
        chattr pub_chattr
        match pub_match
        adduser pub_adduser
        deluser pub_deluser
        addhost pub_addhost
        delhost pub_delhost
        whois pub_whois
        chaninfo pub_chaninfo
        chanset pub_chanset
        protection pub_protection
        protectionall pub_protectionall
        channels pub_channels
        copychan pub_copychan
        resetchan pub_resetchan
        badwords pub_badwords
        badchans pub_badchans
        spamwords pub_spamwords
        alias pub_alias
        char pub_char
        save pub_save
        reload pub_reload
        help pub_help
		update pub_update
		addchan pub_addchan
		delchan pub_delchan
    }
    
    # Create lookup table for aliases
    array set cmd_to_proc {}
    foreach {cmd proc} $commands {
        set cmd_to_proc($cmd) $proc
    }
    
    # Bind main commands
    foreach {cmd proc} $commands {
        bind_all_command $customscript(cmdchars) $cmd $proc
    }
    
    # Bind aliases
    foreach alias [array names command_aliases] {
        set real_cmd $command_aliases($alias)
        if {[info exists cmd_to_proc($real_cmd)]} {
            bind_all_command $customscript(cmdchars) $alias $cmd_to_proc($real_cmd)
        }
    }
    
    putlog "Commands and aliases rebound to: $customscript(cmdchars)"
}


# ========================================================================
# INITIALIZATION
# ========================================================================

if {![file exists $customscript(datadir)]} {
    file mkdir $customscript(datadir)
}

# Run migration and load existing data
migrate_global_lists

# Load aliases
load_aliases


foreach chan [channels] {
    load_channel_config $chan
    load_channel_badwords $chan
    load_channel_badchans $chan
    load_channel_spamwords $chan
}

# Bind all commands
rebind_all_commands

putlog "AllInOne Protection System v2.6 loaded successfully!"
putlog "Features: Channel-specific word lists, refined permissions, 7 protections"
putlog "Command characters: $customscript(cmdchars)"
putlog "Data directory: $customscript(datadir)"
putlog "Loaded configuration for [llength [channels]] channels"
