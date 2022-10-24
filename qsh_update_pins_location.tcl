set tcl_dir [file dirname [info script]]
source $tcl_dir/tools.tcl

set options {\
    { project.arg   ""                      "Project name"                  } \
}
array set opts [cmd_getopts argv ${options}]

set argv [list -project $opts(project) -obj pin]
set argc [llength $argv]
source $tcl_dir/qsh_update.tcl 
