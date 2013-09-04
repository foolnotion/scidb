#!/bin/sh
# Try to find the best version of Tcl/Tk 8.x that is installed,
# by searching the PATH directories for tclsh8.5, tclsh85, etc. If no
# tclsh program with a version number in the file name is found, the
# default program to execute is just tclsh.
# The backslashes at the end of these lines are needed: \
tclsh=tclsh; \
for tclver in 86 8.6 85 8.5; do \
    IFS=:; \
    for dir in $PATH; do \
        if [ -x $dir/tclsh$tclver ]; \
            then tclsh=$dir/tclsh$tclver; \
        fi; \
    done; \
done

# Now execute this script using the best tclsh version found:
# The backslash at the end of this line is needed: \
exec $tclsh "$0" ${1+"$@"}

##########################################################################

array set order {
    application/x-chess-pgn             before:scidvspc;scid
    application/x-chess-gzpgn           before:scidvspc;scid
    application/x-chess-scidb           default
    application/x-chess-scid4           after:scidvspc;scid
    application/x-chess-scid3           default
    application/x-chess-archive         default
    application/x-chess-chessbase       default
    application/x-chess-chessbasedos    default
}

set myapp scidb

##########################################################################

if {$argc != 2 || [lindex $argv 0] ni {add remove}} {
    puts stderr "Usage: $argv0 add|remove /path/to/mimeapps.list"
    exit 1
}

set method [lindex $argv 0]
set file [lindex $argv 1]

if {$method eq "remove" && ![file exists $file]} { return }


proc sortApplications {mimetype applications} {
    global order myapp

    if {[string match *$myapp.desktop* $applications]} {
        # fix previous script version bug
        if {[string index $applications end] ne ";"} { append applications ";" }
        return $applications
    }

    if {$order($mimetype) eq "default"} {
        append result $myapp.desktop ";" $applications
    } elseif {$order($mimetype) eq "end"} {
        append result $applications ";" $myapp.desktop
    } else {
        set other {}
        foreach app [split [lindex [split $order($mimetype) ":"] 1] ";"] {
            if {[string length $other]} { lappend other $app.desktop }
        }
        set apps [split $applications ";"]
        set delim ""
        set i 0

        if {[string match before:* $order($mimetype)]} {
            for {} {$i < [llength $apps]} {incr i} {
                set k [lsearch -exact $other $app.desktop]
                if {$k >= 0} { break }
                append result ";" [lindex $apps $i]
            }
        } else { ;# after:*
            for {} {$i < [llength $apps]} {incr i} {
                if {[llength $other] == 0} { break; }
                append result ";" [lindex $apps $i]
                set k [lsearch -exact $other $app.desktop]
                if {$k >= 0} { set other [lreplace $other $k $k] }
            }
        }

        append result ";" $myapp.desktop

        for {} {$i < [llength $apps]} {incr i} {
            append result ";" [lindex $apps $i]
        }
    }

    append result ";"
    if {[string index $result 0] == ";"} { set result [string range $result 1 end] }
    return [string map {";;" ";"} $result]
}


proc stripApplications {mimetype applications} {
    global order myapp

    if {![string match *$myapp.desktop* $applications]} {
       # fix previous script version bug
        if {[string index $applications end] ne ";"} { append applications ";" }
        return $applications
    }

    set result ""

    foreach app [split $applications ";"] {
        if {[string length $app] && "$myapp.desktop" != $app} {
            append result ";" $app
        }
    }

    append result ";"
    if {[string index $result 0] == ";"} { set result [string range $result 1 end] }
    return [string map {";;" ";"} $result]
}


if {[file extension $file] eq ".cache"} {
    set header "\[MIME Cache\]"
} elseif {[file tail $file] eq "defaults.list"} {
    set header "\[Default Applications\]"
} else {
    set header "\[Added Associations\]"
}
array set content {0 {} 1 {} 2 {}}
if {$method eq "add"} { set handleProc sortApplications} else { set handleProc stripApplications }
set countEntries 0

if {[file readable $file]} {
    set chan [open $file "r"]
    set section 0

    while {[gets $chan line] >= 0} {
        set line [string trim $line]
        if {$line eq $header} {
            set section 1
        } elseif {[string match {[*]*} $line]} {
            if {$section == 1} { incr section }
            incr countEntries
        } elseif {$section == 1 && [string length $line] && [string index $line 0] ne "#"} {
            set parts [split $line =]
            if {[llength $parts] == 2} {
                lassign $parts mimetype applications
                if {[info exists order($mimetype)]} {
                    set applications [$handleProc $mimetype $applications]
                    if {[string length $applications] == 0} { continue }
                    set line "${mimetype}="
                    append line $applications
                    array unset order $mimetype
                }
            }
            incr countEntries
        }

        lappend content($section) $line
    }

    close $chan
} elseif {$method eq "add"} {
    lappend content(1) $header
}

if {$method eq "remove" && $countEntries == 0} {
    file delete -force $file
} elseif {$countEntries > 0} {
    set tmpfile "[file dirname $file]/.[file tail $file].037369839329"
    set chan [open $tmpfile "w" 0644]

    foreach entry $content(0) { puts $chan $entry }
    foreach entry $content(1) { puts $chan $entry }
    if {$method eq "add"} {
        foreach mimetype [array names order] {
            puts $chan "${mimetype}=$myapp.desktop;"
        }
    }
    foreach entry $content(2) { puts $chan $entry }

    close $chan
    file rename -force $tmpfile $file
}

# vi:set ts=4 sw=4 et filetype=tcl:
