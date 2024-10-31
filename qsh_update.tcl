set tcl_dir [file dirname [info script]]
source $tcl_dir/tools.tcl
source $tcl_dir/qsh_tools.tcl

set options {\
    { project.arg   ""                      "Project name"                  } \
    { src.arg       "src"                   "Source folder"                 } \
    { src_exc.arg   "testbench software"    "Exclude source folder"         } \
    { obj.arg       "all"                   "Objects to update: all, src, pin, tcl"} \
}

array set opts [cmd_getopts argv ${options}]

set base_dir [pwd]
set project_name [open $opts(project)]
set rel_base_dir [regsub -all {/[^/]*} [regsub $base_dir [pwd] ""] "../" ]

switch $opts(obj) {
    all {
        update_src_path $rel_base_dir$opts(src) $opts(src_exc)
        update_tcl_path $rel_base_dir$tcl_dir
    }
    src {update_src_path $rel_base_dir$opts(src) $opts(src_exc)}
    tcl {update_tcl_path $rel_base_dir$tcl_dir}
    default {}
}

export_assignments

cd $base_dir
