package require fileutil
set tcl_dir [file dirname [info script]]
source $tcl_dir/puts_colors.tcl
source $tcl_dir/tools.tcl

proc update_src_path {src_dir src_dir_exclude} {

    array set src [find_src_qip ${src_dir} ${src_dir_exclude}]
    array set settings { \
        qip QIP_FILE \
        synt_vhd VHDL_FILE tb_vhd VHDL_TEST_BENCH_FILE \
        synt_v VERILOG_FILE tb_v VERILOG_TEST_BENCH_FILE \
        synt_sv SYSTEMVERILOG_FILE tb_sv SYSTEMVERILOG_TEST_BENCH_FILE \
    }
    
    # Добавление ситезируемых модулей
    foreach s [array names settings] {
        remove_all_global_assignments -name $settings($s)
        foreach f $src($s) {
            set_global_assignment -name $settings($s) $f
        }
    }

    # Добавление тестов
    remove_all_global_assignments -name EDA_TEST_BENCH_NAME
    remove_all_global_assignments -name EDA_TEST_BENCH_MODULE_NAME
    remove_all_global_assignments -name EDA_TEST_BENCH_FILE
    foreach tb [join [list $src(tb_sv) $src(tb_vhd) $src(tb_v)]] {
        set tb_name [regsub ".*/" [file rootname $tb] ""]
        set_global_assignment -name EDA_TEST_BENCH_NAME $tb_name -section_id eda_simulation
        set_global_assignment -name EDA_TEST_BENCH_MODULE_NAME $tb_name -section_id $tb_name
        set_global_assignment -name EDA_TEST_BENCH_FILE $tb -section_id $tb_name
    }

    array get src
}

proc update_pins_location {tcl_dir} {
    if {![file exists ${tcl_dir}/pins_location.tcl]} {
        puts_warn "File pins location ${tcl_dir}/pins_location.tcl not found"
        return
    }
    remove_all_instance_assignments -name LOCATION -to *
    remove_all_instance_assignments -name IO_STANDARD -to *
    source $tcl_dir/pins_location.tcl
}

proc update_tcl_path {tcl_dir} {    
    set tcl_all [lsort [fileutil::findByPattern $tcl_dir {*.tcl}]]
    set tcl_qsh [lsearch -inline -all -regexp $tcl_all .*/qsh_.*]]

    remove_all_global_assignments -name TCL_SCRIPT_FILE
    foreach f $tcl_qsh {
        set_global_assignment -name TCL_SCRIPT_FILE $f
    }
}

proc open {project_name} {    

    package require fileutil
    set prj_files [lsort [fileutil::findByPattern . {*.qpf}]]
    set prj_file [lsearch -inline -all -regexp ${prj_files} .*$project_name.*]

    if [string equal "" $prj_file] {
        puts_warn "Project $project_name not found"
        return
    }

    cd [file dirname $prj_file]
    project_open [regsub ".*/" [file rootname $prj_file] ""]

    return $project_name
}
