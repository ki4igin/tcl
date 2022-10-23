package require cmdline
set tcl_dir [file dirname [info script]]

set options {\
    { project.arg   ""                      "Project name"                  } \
}
array set opts [::cmdline::getKnownOptions argv ${options}]

set argv [list -project $opts(project) -obj pin]
set argc [llength $argv]
source $tcl_dir/qsh_update.tcl 
