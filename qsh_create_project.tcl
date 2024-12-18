# Скрипт для создания проекта Quartus
#
# Команда запуска скрипта:
# quartus_sh -t tcl/qsh_create_project.tcl
#
set tcl_dir [file dirname [info script]]
source $tcl_dir/tools.tcl

# Чтение аргументов командной строки
set options { \
    { project.arg   ""                      "Project name"                  } \
    { folder.arg    "quartus"               "Folder name project"           } \
    { src.arg       "src"                   "Source folder"                 } \
    { src_exc.arg   "testbench software"    "Exclude source folder"         } \
    { top.arg       ""                      "Top level name"                } \
    { tb.arg        ""                      "Testbensh name for top level"  } \
    { board.arg     ""                      "Board name"                    } \
}
array set opts [cmd_getopts argv ${options}]

# Полный путь до корневой папки
set base_dir [pwd]

# ******************************************************************************
# Настройки проекта
# ******************************************************************************
# Имя проекта, имя верхнего уровня, имя теста верхнего уровня
if {[string equal "" $opts(project)]} { 
    set project_name [regsub ".*/" [pwd] ""]     
} else {
    set project_name $opts(project)
}

if {[string equal "" $opts(top)]} {
    set top_level [find_top_level $project_name $opts(src) $opts(src_exc)]
    set top_level_entity [regsub ".*/" [file rootname $top_level] ""]
} else {
    set top_level_entity $opts(top)
}

if {[string equal "" $opts(tb)]} { 
    set tb_top_level ${project_name}_tb
} else {
    set tb_top_level $opts(tb)
}

# Создание проекта Quartus
set quartus_folder $opts(folder)
file mkdir $quartus_folder
cd $quartus_folder
project_new $project_name -overwrite
cd $base_dir

# ******************************************************************************
# Add default board Assignments abd source files to project 
# ******************************************************************************
set default_qsf [find_default_qsf $opts(board)]
source ${default_qsf}
set argv [list -project $project_name -src $opts(src) -src_exc $opts(src_exc)]
set argc [llength $argv]
source ${tcl_dir}/qsh_update.tcl

# ******************************************************************************
# Analysis & Synthesis Assignments
# ******************************************************************************
set_global_assignment -name TOP_LEVEL_ENTITY ${top_level_entity}
set_global_assignment -name VHDL_INPUT_VERSION VHDL_2008
set_global_assignment -name SMART_RECOMPILE ON

# ******************************************************************************
# Fitter Assignments
# ******************************************************************************
set_global_assignment -name PROJECT_OUTPUT_DIRECTORY output_files

# ******************************************************************************
# EDA Settings
# ******************************************************************************
set_global_assignment -name EDA_OUTPUT_DATA_FORMAT VHDL -section_id eda_simulation
set_global_assignment -name EDA_SIMULATION_TOOL "Active-HDL (VHDL)"
set_global_assignment -name EDA_TEST_BENCH_ENABLE_STATUS TEST_BENCH_MODE -section_id eda_simulation
set_global_assignment -name EDA_NATIVELINK_SIMULATION_TEST_BENCH ${tb_top_level} -section_id eda_simulation

# ******************************************************************************
# Close Project
# ******************************************************************************
project_close
