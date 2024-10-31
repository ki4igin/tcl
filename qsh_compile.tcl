# Скрипт для полной компиляции проекта Quartus
#
# Команда запуска скрипта:
# quartus_sh -t tcl/qsh_compile.tcl
#
set tcl_dir [file dirname [info script]]
source $tcl_dir/tools.tcl
source $tcl_dir/qsh_tools.tcl

set options {\
    { project.arg   ""      "Project name"                                  } \
}
array set opts [cmd_getopts argv ${options}]

set project_name [open $opts(project)]

# ******************************************************************************
#  Project
# ******************************************************************************

load_package flow
execute_flow -compile