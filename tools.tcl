proc update_src_path {src_dir src_dir_exclude} {

    lassign [find_src ${src_dir} ${src_dir_exclude}] \
        src_qip src_synt_vhd src_tb_vhd src_synt_v src_tb_v src_synt_sv src_tb_sv    

    foreach file ${src_qip} {
        set_global_assignment -name QIP_FILE ${file}
    }
    foreach file ${src_synt_vhd} {
        set_global_assignment -name VHDL_FILE ${file}
    }
    foreach file ${src_tb_vhd} {
        set_global_assignment -name VHDL_TEST_BENCH_FILE ${file}
    }
    foreach file ${src_synt_v} {
        set_global_assignment -name VERILOG_FILE ${file}
    }
    foreach file ${src_tb_v} {
        set_global_assignment -name VERILOG_TEST_BENCH_FILE ${file}
    }
    foreach file ${src_synt_sv} {
        set_global_assignment -name SYSTEMVERILOG_FILE ${file}
    }
    foreach file ${src_tb_sv} {
        set_global_assignment -name SYSTEMVERILOG_TEST_BENCH_FILE ${file}
    }

    return [list ${src_qip} ${src_synt_vhd} ${src_tb_vhd} ${src_synt_v} ${src_tb_v} ${src_synt_sv} ${src_tb_sv}]
}

proc find_src {src_dir src_dir_exclude} {

    if {[file isdirectory ${src_dir}] == 0} {        
        post_message -type warning "No such source directory '${src_dir}'"
        return
    }

    package require fileutil   
    set src_all [fileutil::findByPattern ${src_dir} {*.qip *.vhd *.v *.sv}]
    set src_all [lsort ${src_all}]  
   
    foreach dir_exclude ${src_dir_exclude} {
        set index [lsearch -all -glob ${src_all} *\/${dir_exclude}\/*]
        if {[llength $index] != 0} {
            set src_all [lreplace ${src_all} [lindex ${index} 0] [lindex ${index} end]]
        }
    }

    if {[llength ${src_all}] == 0} {        
        post_message -type warning "No such source file in directory '${src_dir}'"
        return
    }

    set src_qip [lsearch -inline -all ${src_all} *.qip]

    foreach file_qip ${src_qip} {
        set file_qip_dir [file dirname ${file_qip}]
        set index [lsearch -all -glob ${src_all} ${file_qip_dir}*]
        if {[llength $index] != 0} {
            set src_all [lreplace ${src_all} [lindex ${index} 0] [lindex ${index} end]]
        }
    }

    set src_all_vhd [lsearch -inline -all ${src_all} *.vhd]
    set src_synt_vhd [lsearch -inline -all -regexp -not ${src_all_vhd} .*tb\.vhd|.*inst\.vhd]
    set src_tb_vhd [lsearch -inline -all ${src_all_vhd} *tb.vhd]

    set src_all_v [lsearch -inline -all ${src_all} *.v]
    set src_synt_v [lsearch -inline -all -regexp -not ${src_all_v} .*tb\.v|.*inst\.v]
    set src_tb_v [lsearch -inline -all ${src_all_v} *tb.v]

    set src_all_sv [lsearch -inline -all ${src_all} *.sv]
    set src_synt_sv [lsearch -inline -all -regexp -not ${src_all_sv} .*tb\.sv|.*inst\.sv]
    set src_tb_sv [lsearch -inline -all ${src_all_sv} *tb.sv]

    return [list ${src_qip} ${src_synt_vhd} ${src_tb_vhd} ${src_synt_v} ${src_tb_v} ${src_synt_sv} ${src_tb_sv}]
}

proc find_src_avhdl {src_dir src_dir_exclude} {

    if {[file isdirectory ${src_dir}] == 0} {        
        post_message -type warning "No such source directory '${src_dir}'"
        return
    }

    package require fileutil   
    set src_all [fileutil::findByPattern ${src_dir} {*.vhd *.v *.sv}]
    set src_all [lsort ${src_all}]  
   
    foreach dir_exclude ${src_dir_exclude} {
        set index [lsearch -all -glob ${src_all} *\/${dir_exclude}\/*]
        if {[llength $index] != 0} {
            set src_all [lreplace ${src_all} [lindex ${index} 0] [lindex ${index} end]]
        }
    }

    if {[llength ${src_all}] == 0} {        
        post_message -type warning "No such source file in directory '${src_dir}'"
        return
    }    

    set src_all_vhd [lsearch -inline -all ${src_all} *.vhd]
    set src_synt_vhd [lsearch -inline -all -regexp -not ${src_all_vhd} .*tb\.vhd|.*inst\.vhd]
    set src_tb_vhd [lsearch -inline -all ${src_all_vhd} *tb.vhd]

    set src_all_v [lsearch -inline -all ${src_all} *.v]
    set src_synt_v [lsearch -inline -all -regexp -not ${src_all_v} .*tb\.v|.*inst\.v]
    set src_tb_v [lsearch -inline -all ${src_all_v} *tb.v]

    set src_all_sv [lsearch -inline -all ${src_all} *.sv]
    set src_synt_sv [lsearch -inline -all -regexp -not ${src_all_sv} .*tb\.sv|.*inst\.sv]
    set src_tb_sv [lsearch -inline -all ${src_all_sv} *tb.sv]

    return [list ${src_synt_vhd} ${src_tb_vhd} ${src_synt_v} ${src_tb_v} ${src_synt_sv} ${src_tb_sv}]
}

proc color {foreground text} {
    # tput is a little Unix utility that lets you use the termcap database
    # *much* more easily...
    return [exec tput setaf $foreground]$text[exec tput sgr0]
}
