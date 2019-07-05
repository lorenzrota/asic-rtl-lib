# Load RUCKUS library
source -quiet $::env(RUCKUS_DIR)/vivado_proc.tcl

# Check for submodule tagging
if { [SubmoduleCheck {ruckus} {1.7.2} ] < 0 } {exit -1}

# Load ruckus files
loadRuckusTcl "$::DIR_PATH/12b14benc"


