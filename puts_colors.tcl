proc puts_all_colors {} {
    for {set i 0} {$i < 8} {incr i} {
        puts [color $i $i]
    }
}

proc color {foreground text} {
    # tput is a little Unix utility that lets you use the termcap database
    # *much* more easily...
    return [exec tput setaf $foreground]$text[exec tput sgr0]
}

proc puts_warn {text} {
    puts -nonewline [color 6 "Warning "]
    puts [color 6 $text]
}

proc puts_err {text} {
    puts -nonewline [color 1 "Error "]
    puts [color 1 $text]
}

proc puts_all_colors {} {
    for {set i 0} {$i < 8} {incr i} {
        puts [color $i $i]
    }
}
