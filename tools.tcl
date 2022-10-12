set tcl_dir [file dirname [info script]]
source $tcl_dir/puts_colors.tcl

proc update_src_path {src_dir src_dir_exclude} {

    array set src [find_src_qip ${src_dir} ${src_dir_exclude}]
    array set settings { \
        qip QIP_FILE \
        synt_vhd VHDL_FILE tb_vhd VHDL_TEST_BENCH_FILE \
        synt_v VERILOG_FILE tb_v VERILOG_TEST_BENCH_FILE \
        synt_sv SYSTEMVERILOG_FILE tb_sv SYSTEMVERILOG_TEST_BENCH_FILE \
    }
    foreach s [array names settings] {
        foreach f $src($s) {
            set_global_assignment -name $settings($s) $f
        }
    }
    array get src
}

proc split_src {src separator} {
    set src_exc [lsearch -inline -all -regexp -not $src $separator]
    set src_inc [lsearch -inline -all -regexp $src $separator]
    return [list $src_exc $src_inc]
}

proc find_src {src_dir src_excluded_folders} {

    if {[file isdirectory ${src_dir}] == 0} {
        puts_warn "No such source directory '${src_dir}'"
        return
    }

    package require fileutil
    set src_all [lsort [fileutil::findByPattern ${src_dir} {*.vhd *.v *.sv}]]
    set src_all [lsearch -inline -all -not -regexp ${src_all} .*\/inst_.*|.*_inst\..*]

    foreach folder ${src_excluded_folders} {
        set src_all [lsearch -inline -all -regexp -not $src_all .*\/$folder\/.*]
    }

    if {[llength ${src_all}] == 0} {
        puts_warn "No such source file in directory '${src_dir}'"
        return
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
        return
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
