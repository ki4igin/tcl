# Скрипт для создания проекта Active HDL в папке active_hdl, со всеми
# исходниками из папки src и библиотеками для Cyclone II
# 
# Команда запуска скрипта без библиотек для Cyclone II:
# avhdl -do "runscript -tcl tcl/avhdl_create_project.tcl"
#
# Команда запуска скрипта с библиотеками для Cyclone II:
# avhdl -do "runscript -tcl tcl/avhdl_create_project.tcl -cycloneII"
#

package require cmdline
# Чтение аргументов командной строки
set options {\
    { cycloneII "Include cycloneII libraries in project" } \
}
array set opts [::cmdline::getKnownOptions argv ${options}]


# Полный путь до папки с данным скриптом
set tcl_scripts_dir [file dirname [file normalize [info script]]]

# Переход на уровень выше папки со скриптом для создания проекта
cd ${tcl_scripts_dir}/..

# Имя проекта
set project_name [regsub {.*/} [pwd] {}]

# Создание проекта в папке active_hdl
if {[string equal active_hdl [glob -nocomplain -types d active_hdl]]} {
    file delete -force active_hdl
}
file mkdir active_hdl
workspace create active_hdl/${project_name}
design create -a -nodesdir ${project_name} active_hdl
# После создания проекта текущая папка active_hdl/src

# Добавление исходников из папки src, на два уровня выше относительно active_hdl/src
source ${tcl_scripts_dir}/tools.tcl
set src_dir ../../src
set src_dir_exclude {testbench software} 

set src_all [join [find_src_avhdl ${src_dir} ${src_dir_exclude}]]

puts ${src_all}
foreach file ${src_all} {
    addfile -auto ${file}
}

# Компиляция библиотек для Cyclone II
if {$opts(cycloneII)} {
    source ${tcl_scripts_dir}/avhdl_compile_cyclone_lib.tcl    
}

# Компиляция всех исходников
comp -reorder
comp -reorder
