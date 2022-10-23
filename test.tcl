# package require try ;# In case you're still using tcl 8.5 for some reason
package require cmdline

proc better_getoptions {arglistVar optlist usage} {
    upvar 1 $arglistVar argv
    # Warning: Internal cmdline function
    set opts [::cmdline::GetOptionDefaults $optlist result]
    while {[set err [::cmdline::getopt argv $opts opt arg]]} {
        if {$err < 0} {
            return -code error -errorcode {CMDLINE ERROR} $arg
        }
        set result($opt) $arg
    }
    if {[info exists result(?)] || [info exists result(help)]} {
        return -code error -errorcode {CMDLINE USAGE} \
            [::cmdline::usage $optlist $usage]
    }
    return [array get result]
}

set run_options {
    {input_1.arg 8 "first input argument"}
    {input_2.arg 1 "second input argument"}
    {msb  "choose it if input data has msb first"}
    {lsb  "choose it if input data has lsb first"}
}
set my_usage "options are:"

puts [catch {
    array set params [better_getoptions argv $run_options $my_usage]
    puts "All options valid"
} msg]

puts $msg
