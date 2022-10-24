# Скрипт для создания проекта Quartus в папке quartus, со всеми
# исходниками из папки src
#
# Команда запуска скрипта:
# quartus_sh -t tcl/quartus_sh_create_project.tcl
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
execute_flow -analysis_and_elaboration