# Скрипт для создания проекта Quartus в папке quartus, со всеми
# исходниками из папки src
# 
# Команда запуска скрипта:
# quartus_sh -t tcl/quartus_sh_create_project.tcl
#

# Полный путь до папки с данным скриптом
set tcl_scripts_dir [file dirname [file normalize [info script]]]

# Переход на уровень выше папки со скриптом для создания проекта
cd ${tcl_scripts_dir}/..

# ******************************************************************************
# Настройки проекта
# ******************************************************************************

# Имя проекта, имя верхнего уровня
set project_name [regsub {.*/} [pwd] {}]
set top_level_name ${project_name}
# set top_level_name lcd_test_top

# Путь к исходным файлам относительно папки проекта quartus
set src_dir ../src

# Папки исключенные из поиска иходных файлов
set src_dir_exclude {testbench software} 

# Имя семейства и микросхемы
set family "Cyclone II"
set device EP2C35F672C6

# Имя верхнего уровня теста и имя объекта тестирования
set tb_entity_name ${top_level_name}_tb
set tb_instance_name syncronisation

# Создание проекта в папке quartus
file mkdir quartus
cd quartus
project_new ${project_name} -overwrite

# ******************************************************************************
# Add source files to project
# ******************************************************************************

source ${tcl_scripts_dir}/tools.tcl
lassign [update_src_path ${src_dir} ${src_dir_exclude}] \
    src_qip src_synt_vhd src_tb_vhd src_synt_v src_tb_v src_synt_sv src_tb_sv

# ******************************************************************************
# Analysis & Synthesis Assignments
# ******************************************************************************

set_global_assignment -name FAMILY ${family}
set_global_assignment -name TOP_LEVEL_ENTITY ${top_level_name}
set_global_assignment -name VHDL_INPUT_VERSION VHDL_2008
set_global_assignment -name SMART_RECOMPILE ON

# ******************************************************************************
# Pin & Location Assignments
# ******************************************************************************

source ${tcl_scripts_dir}/DE2_pin_location.tcl

# ******************************************************************************
# Fitter Assignments
# ******************************************************************************

set_global_assignment -name DEVICE ${device}
set_global_assignment -name PROJECT_OUTPUT_DIRECTORY output_files
set_global_assignment -name RESERVE_ALL_UNUSED_PINS "AS INPUT TRI-STATED"

# ******************************************************************************
# EDA Settings
# ******************************************************************************

# Поиск файла теста по его имени из списка тестов
set tb_file_name ""
if {[string equal "" ${src_tb_vhd}]} {

} else {
    set tb_file_name [lsearch -inline -all ${src_tb_vhd} */${tb_entity_name}.vhd]
}

if {[string equal "" ${tb_file_name}]} {

} else {
    set_global_assignment -name EDA_OUTPUT_DATA_FORMAT VHDL -section_id eda_simulation
    set_global_assignment -name EDA_SIMULATION_TOOL "Active-HDL (VHDL)"
    # set_global_assignment -name EDA_TIME_SCALE "1 ps"
    set_global_assignment -name EDA_TEST_BENCH_ENABLE_STATUS TEST_BENCH_MODE -section_id eda_simulation
    set_global_assignment -name EDA_NATIVELINK_SIMULATION_TEST_BENCH ${tb_entity_name} -section_id eda_simulation
    set_global_assignment -name EDA_TEST_BENCH_NAME ${tb_entity_name} -section_id eda_simulation
    set_global_assignment -name EDA_DESIGN_INSTANCE_NAME ${tb_entity_name}/${tb_instance_name} -section_id ${tb_entity_name}
    set_global_assignment -name EDA_TEST_BENCH_MODULE_NAME ${tb_entity_name} -section_id ${tb_entity_name}
    set_global_assignment -name EDA_TEST_BENCH_FILE ${tb_file_name} -hdl_version VHDL_2008 -section_id ${tb_entity_name}
}


# ******************************************************************************
# Analysis Project
# ******************************************************************************

load_package flow
execute_flow -analysis_and_elaboration

# ******************************************************************************
# Close Project
# ******************************************************************************

project_close
