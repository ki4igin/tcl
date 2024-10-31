package require fileutil
package require cmdline
set tcl_dir [file dirname [info script]]

################################################################################
# Для поиска исходников 
################################################################################
proc split_src {src separator} {
    set src_exc [lsearch -inline -all -regexp -not $src $separator]
    set src_inc [lsearch -inline -all -regexp $src $separator]
    return [list $src_exc $src_inc]
}

proc find_default_qsf {board_name} {
    set dir board
    set reqexp .*${board_name}.*\.qsf$
    set file [find_file $reqexp $dir ""]
    if {![string equal "" $file]} {
        return $file
    }
    puts_warn "Default qsf filt not found in directory 'board'"
    return ""
}

proc find_top_level {project_name src_dir src_excluded_folders} {
    set reqexp (top.*${project_name})|(${project_name}.*top).*(vhd|sv|v)$
    set file [find_file $reqexp $src_dir $src_excluded_folders]
    if {![string equal "" $file]} {
        return $file
    }

    set reqexp ${project_name}.*(vhd|sv|v)$
    set file [find_file $reqexp $src_dir $src_excluded_folders]
    if {![string equal "" $file]} {
        return $file
    }
    puts_warn "Top level not found in directory '${src_dir}'"
    return ""
}

proc find_file {reqexp src_dir src_excluded_folders} {

    if {[file isdirectory ${src_dir}] == 0} {
        puts_warn "No such source directory '${src_dir}'"
        return ""
    }    

    set files [lsort [fileutil::findByPattern ${src_dir} -regexp $reqexp]]
    foreach folder ${src_excluded_folders} {
        set files [lsearch -inline -all -regexp -not $files .*\/$folder\/.*]
    }

    if {[llength ${files}] == 0} {        
        return ""
    }

    return [lindex $files 0]
}

proc find_src {src_dir src_excluded_folders} {

    if {[file isdirectory ${src_dir}] == 0} {
        puts_warn "No such source directory '${src_dir}'"
        return [create_empty_array {synt_vhd tb_vhd synt_v tb_v synt_sv tb_sv}]
    }
    
    set src_all [lsort [fileutil::findByPattern ${src_dir} {*.vhd *.v *.sv}]]
    set src_all [lsearch -inline -all -not -regexp ${src_all} .*\/inst_.*|.*_inst\..*]

    foreach folder ${src_excluded_folders} {
        set src_all [lsearch -inline -all -regexp -not $src_all .*\/$folder\/.*]
    }

    if {[llength ${src_all}] == 0} {
        puts_warn "No such source file in directory '${src_dir}'"
        return [create_empty_array {synt_vhd tb_vhd synt_v tb_v synt_sv tb_sv}]
    }

    set separator ".*\/tb_.*|.*_tb\..*"
    foreach ext [list vhd v sv] {
        set src_temp [lsearch -inline -all ${src_all} *.$ext]
        lassign [split_src $src_temp $separator] src(synt_$ext) src(tb_$ext)
    }

    array get src    
}

proc find_src_qip {src_dir src_excluded_folders} {

    if {[file isdirectory ${src_dir}] == 0} {
        puts_warn "No such source directory '${src_dir}'"
        return [create_empty_array {qip synt_vhd tb_vhd synt_v tb_v synt_sv tb_sv}]
    }

    set src(qip) [fileutil::findByPattern ${src_dir} *.qip]
    set folders_qip {}
    foreach dir $src(qip) {
        lappend folders_qip [regsub {.*/} [file dirname $dir] {}]
    }

    lappend src_excluded_folders {*}$folders_qip
    array set src [find_src $src_dir $src_excluded_folders]

    array get src
}

################################################################################
# Процедуры работы с массивами
################################################################################
proc array2list {arr_str} {
    set l {}
    if {[expr {[llength $arr_str]%2}]} {
        puts_warn "proc array2list: \
            arr_str must have an even number of elements"
        return $l;
    }
    array set arr $arr_str
    foreach el [array names arr] {
        lappend l $arr($el)
    }
    lsort [join $l]
}

proc create_empty_array {names} {
    foreach name $names {
        set arr($name) "";
    }
    array get arr
}

################################################################################
# Процедуры для работы с агрументами командной строки
################################################################################
proc getoptions {arglistVar optlist usage} {
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

proc cmd_getopts {arglistVar optlist} {
    upvar 1 $arglistVar argv
    set my_usage "options are:"
    if {[catch {array set params [getoptions argv $optlist $my_usage]} msg]} {
        if {[string equal -length 14 "Illegal option" $msg]} {
            set tcl_name [info script]
            puts_err "$tcl_name $msg"
        } else {
            puts $msg
        }    
        exit 0
    }
    array get params
}

################################################################################
# Процедуры для цветного вывода 
################################################################################
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
    puts -nonewline [color 6 "Warning: "]
    puts [color 6 $text]
}

proc puts_err {text} {
    puts -nonewline [color 1 "Error: "]
    puts [color 1 $text]
}

proc puts_all_colors {} {
    for {set i 0} {$i < 8} {incr i} {
        puts [color $i $i]
    }
}

