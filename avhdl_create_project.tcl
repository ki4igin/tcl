# Скрипт для создания проекта Active HDL в папке active_hdl, со всеми
# исходниками из папки src и библиотеками для Cyclone II
# 
# Команда запуска скрипта без библиотек для Cyclone II:
# avhdl -do "do tcl/avhdl_create_project.tcl"
#
# Команда запуска скрипта с библиотеками для Cyclone II:
# avhdl -do "do tcl/avhdl_create_project.tcl -cII"
#
package require cmdline

# Чтение аргументов командной строки
set options {\
    { project.arg   ""              "Project name" } \
    { folder.arg    "active_hdl"    "Folder name project" } \
    { src.arg       "src"           "Source folder" } \
    { cII                           "Include Cyclone II libraries in project" } \
}
array set opts [::cmdline::getKnownOptions argv ${options}]

# Полный путь до корневой папки
set base_dir [pwd]

# Полный путь до папки со скриптами
set tcl_dir [file dirname [info script]]

# Полный путь до папки с исходниками
set src_folder $opts(src)
set src_dir $base_dir/$src_folder

# Имя проекта Active HDL
set project_name $opts(project)
puts $project_name
if {[string equal "" $project_name]} { 
    set project_name [regsub {.*/} [pwd] {}] 
}

# Создание проекта Active HDL
set avhdl_folder $opts(folder)
cd ${base_dir}

if {[string equal $avhdl_folder [glob -nocomplain -types d $avhdl_folder]]} {
    file delete -force $avhdl_folder
}
file mkdir $avhdl_folder

workspace create $avhdl_folder/${project_name}
design create -a -nodesdir ${project_name} $avhdl_folder

# Добавление исходников с помощью процедуры find_src_avhdl из tools.tcl
source ${tcl_dir}/tools.tcl
set src_excluded_folders {testbench software}
set src_all [array2list [find_src ${src_dir} ${src_excluded_folders}]]

foreach file ${src_all} {
    addfile -auto ${file}
}

# Компиляция библиотек для Cyclone II
if {$opts(cII)} {
    source ${tcl_dir}/avhdl_compile_cyclone_lib.tcl    
}

# Компиляция всех исходников
comp -reorder
comp -reorder
