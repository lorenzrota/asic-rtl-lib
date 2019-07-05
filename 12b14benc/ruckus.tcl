# Load RUCKUS library
source -quiet $::env(RUCKUS_DIR)/vivado_proc.tcl

# Check for submodule tagging
if { [SubmoduleCheck {ruckus} {1.7.2} ] < 0 } {exit -1}

# Load source files
loadSource -sim_only -path "$::DIR_PATH/src/ssp12b14benc/ssp_enc12b14b_ext.vhd"

