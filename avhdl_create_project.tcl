# Скрипт для создания проекта Active HDL в папке active_hdl, со всеми
# исходниками из папки src и библиотеками для Cyclone II
# 
# Команда запуска скрипта без библиотек для Cyclone II:
# avhdl -do "do tcl/avhdl_create_project.tcl"
#
# Команда запуска скрипта с библиотеками для Cyclone II:
# avhdl -do "do tcl/avhdl_create_project.tcl -cII"
#
set tcl_dir [file dirname [info script]]
source $tcl_dir/tools.tcl

# Чтение аргументов командной строки
set options {\
    { project.arg   ""                      "Project name"                  } \
    { folder.arg    "active_hdl"            "Folder name project"           } \
    { src.arg       "src"                   "Source folder"                 } \
    { src_exc.arg   "testbench software"    "Exclude source folder"         } \
    { cII                                   "Include Cyclone II libraries in project" } \
}
array set opts [cmd_getopts argv ${options}]

# Полный путь до корневой папки
set base_dir [pwd]

# Имя проекта Active HDL
set project_name $opts(project)
puts $project_name
if {[string equal "" $project_name]} { 
    set project_name [regsub {.*/} [pwd] {}] 
}

# Создание проекта Active HDL
set avhdl_folder $opts(folder)
if {[string equal $avhdl_folder [glob -nocomplain -types d $avhdl_folder]]} {
    file delete -force $avhdl_folder
}
file mkdir $avhdl_folder

workspace create $avhdl_folder/${project_name}
design create -a -nodesdir ${project_name} $avhdl_folder
set rel_base_dir [regsub -all {/[^/]*} [regsub $base_dir [pwd] ""] "../" ]

# Добавление исходников с помощью процедуры find_src из tools.tcl
set src_all [array2list [find_src $rel_base_dir$opts(src) $opts(src_exc)]]

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
