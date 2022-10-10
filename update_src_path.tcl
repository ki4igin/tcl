package require cmdline
set options {\
    { "project_name.arg" "" "Project name" } \
    { "src_dir.arg" "" "Source directory" } \
    { "src_dir_exclude.arg" "" "Exclude source directory" }
}
array set opts [::cmdline::getoptions argv ${options}]

set tcl_scripts_dir [file dirname [file normalize [info script]]]
cd ${tcl_scripts_dir}/..

if {[string equal "" ${opts(project_name)}]} {
    set opts(project_name) [regsub {.*/} [pwd] {}]
}

if {[string equal "" ${opts(src_dir)}]} {
    set opts(src_dir) ../src
}

if {[string equal "" ${opts(src_dir_exclude)}]} {
    set opts(src_dir_exclude) {testbench software}
}

cd quartus

set need_to_close_project 0

if {[is_project_open]} {
    if {${project_name} != [get_current_project]} {
        project_close
        project_open ${project_name}
        set need_to_close_project 1
    }
} else {
    project_open ${project_name}
    set need_to_close_project 1
}

source ${tcl_scripts_dir}/tools.tcl
update_src_path ${opts(project_name)} ${opts(src_dir)}

# Close project
if {${need_to_close_project}} {
    project_close
}
