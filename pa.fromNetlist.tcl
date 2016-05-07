
# PlanAhead Launch Script for Post-Synthesis floorplanning, created by Project Navigator

create_project -name Seminar -dir "E:/FRI/DN/Seminar/planAhead_run_2" -part xc3s500efg320-5
set_property design_mode GateLvl [get_property srcset [current_run -impl]]
set_property edif_top_file "E:/FRI/DN/Seminar/FRISoC_top.ngc" [ get_property srcset [ current_run ] ]
add_files -norecurse { {E:/FRI/DN/Seminar} }
set_property target_constrs_file "uci.ucf" [current_fileset -constrset]
add_files [list {uci.ucf}] -fileset [get_property constrset [current_run]]
link_design
