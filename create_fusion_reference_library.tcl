##########################################################################################
# Script: create_fusion_reference_library.tcl
# Version: U-2022.12
# Copyright (C) 2014-2022 Synopsys, Inc. All rights reserved.
##########################################################################################


source ./rm_utilities/procs_global.tcl 
source ./rm_utilities/procs_fc.tcl 
rm_source -file ./rm_setup/design_setup.tcl
if {$HPC_CORE != "" && $DESIGN_STYLE == "hier"} {
	rm_source -file ./rm_setup/design_setup.tcl -after_file block_override.tcl
}

rm_source -file ./rm_setup/fc_setup.tcl
rm_source -file ./rm_setup/header_fc.tcl
rm_source -file sidefile_setup.tcl -after_file technology_override.tcl
if {$HPC_CORE != ""} {rm_source -file ./rm_hpc_core_scripts/sidefile_setup_hpc_core.tcl}

set CURRENT_STEP  create_fusion_reference_library
set PREVIOUS_STEP $ROUTE_OPT_BLOCK_NAME
if { [info exists env(RM_VARFILE)] } {
	if { [file exists $env(RM_VARFILE)] } {
		rm_source -file $env(RM_VARFILE)
	} else {
		puts "RM-error: env(RM_VARFILE) specified but not found"
	}
}

set REPORT_PREFIX $CURRENT_STEP
file mkdir ${REPORTS_DIR}/${REPORT_PREFIX}
puts "RM-info: PREVIOUS_STEP = $PREVIOUS_STEP"
puts "RM-info: CURRENT_STEP  = $CURRENT_STEP"
puts "RM-info: REPORT_PREFIX = $REPORT_PREFIX"
redirect -tee -file ${REPORTS_DIR}/${REPORT_PREFIX}/run_start.rpt {run_start}
set_svf ${OUTPUTS_DIR}/${CURRENT_STEP}.svf 

open_lib $DESIGN_LIBRARY
copy_block -from ${DESIGN_NAME}/${PREVIOUS_STEP} -to ${DESIGN_NAME}/${CURRENT_STEP}
current_block ${DESIGN_NAME}/${CURRENT_STEP}
link_block

###generate frame
create_frame

####etm generation
set ::g_execname ptshell
extract_model

set FUSION_REFERENCE_LIBRARY_DB_LIST [list ]
lappend FUSION_REFERENCE_LIBRARY_DB_LIST "./work_dir/DMSA/func_fast/${DESIGN_LIBRARY}_lib.db"
lappend FUSION_REFERENCE_LIBRARY_DB_LIST "./work_dir/DMSA/func_slow/${DESIGN_LIBRARY}_lib.db"

write_lef -library [current_lib ] outputs_fc/${DESIGN_LIBRARY}.lef

set FUSION_REFERENCE_LIBRARY_LEF_LIST [list ]
lappend FUSION_REFERENCE_LIBRARY_LEF_LIST "outputs_fc/${DESIGN_LIBRARY}.lef"

## Create fusion library
## FUSION_REFERENCE_LIBRARY_FRAM_LIST, FUSION_REFERENCE_LIBRARY_LOG_DIR require user inputs
if {$FUSION_REFERENCE_LIBRARY_LEF_LIST != "" && $FUSION_REFERENCE_LIBRARY_DB_LIST != ""} {

	if {[file exists $FUSION_REFERENCE_LIBRARY_DIR]} {
		puts "RM-info: FUSION_REFERENCE_LIBRARY_DIR ($FUSION_REFERENCE_LIBRARY_DIR) is specified and exists. The directory will be overwritten." 
	}

	lc_sh {\
		source ./rm_setup/design_setup.tcl; \
		source ./rm_setup/header_fc.tcl; \
		compile_fusion_lib -lef $FUSION_REFERENCE_LIBRARY_LEF_LIST \
		-dbs $FUSION_REFERENCE_LIBRARY_DB_LIST \
		-technology $TECH_FILE
		-log_file_dir $FUSION_REFERENCE_LIBRARY_LOG_DIR \
		-output_directory $FUSION_REFERENCE_LIBRARY_DIR \
		-force
		
	}
} else {
	puts "RM-error: either FUSION_REFERENCE_LIBRARY_FRAM_LIST or FUSION_REFERENCE_LIBRARY_DB_LIST is not specified. Fusion library creation is skipped!"	
}

redirect -tee -file ${REPORTS_DIR}/${REPORT_PREFIX}/run_end.rpt {run_end}

echo [date] > create_fusion_reference_library
exit
