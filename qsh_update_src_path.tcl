set tcl_dir [file dirname [info script]]
source $tcl_dir/tools.tcl

set options {\
    { project.arg   ""                      "Project name"                  } \
    { src.arg       "src"                   "Source folder"                 } \
    { src_exc.arg   "testbench software"    "Exclude source folder"         } \
}
array set opts [cmd_getopts argv ${options}]

set argv [list -project $opts(project) -src $opts(src) -src_exc $opts(src_exc) -obj src]
set argc [llength $argv]
source $tcl_dir/qsh_update.tcl 
