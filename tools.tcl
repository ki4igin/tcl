set tcl_dir [file dirname [info script]]
source $tcl_dir/puts_colors.tcl

proc split_src {src separator} {
    set src_exc [lsearch -inline -all -regexp -not $src $separator]
    set src_inc [lsearch -inline -all -regexp $src $separator]
    return [list $src_exc $src_inc]
}

proc find_src {src_dir src_excluded_folders} {

    if {[file isdirectory ${src_dir}] == 0} {
        puts_warn "No such source directory '${src_dir}'"
        return [create_empty_array {synt_vhd tb_vhd synt_v tb_v synt_sv tb_sv}]
    }

    package require fileutil
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

    package require fileutil
    set src(qip) [fileutil::findByPattern ${src_dir} *.qip]
    set folders_qip {}
    foreach dir $src(qip) {
        lappend folders_qip [regsub {.*/} [file dirname $dir] {}]
    }

    lappend src_excluded_folders {*}$folders_qip
    array set src [find_src $src_dir $src_excluded_folders]

    array get src
}

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

