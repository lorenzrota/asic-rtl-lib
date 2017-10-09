# Synopsys DC flow for ssp 12b14b encoder
# Authors: Faisal T. Abu-Nimeh
# Date: 20170927

set pdk_dir [ getenv  "TSMC130_DIR" ]

set search_path $pdk_dir/Front_End/timing_power_noise/NLDM/tcb013ghp_220a/
# set target_library "tcb013ghplt.db"
# set link_library "* tcb013ghplt.db"
set target_library "tcb013ghpwc.db"
set link_library "* tcb013ghpwc.db"
lappend search_path $pdk_dir/Front_End/physical_compiler/tcb013ghp_211a/
set physical_library {tcb013ghp_Fsg_8lm_6x6.pdb}
lappend search_path $pdk_dir/Front_End/timing_power_noise/tcb013ghp_211a/
set symbol_library "tcb013ghp.sdb"

# custom voltages
set upf_create_implicit_supply_sets false

set src_dir ../../src/ssp12b14benc
set vhdl_infiles {$src_dir/StdRtlPkg.vhd $src_dir/Code12b14bPkg.vhd $src_dir/SspFramer.vhd $src_dir/Encoder12b14b.vhd $src_dir/SspEncoder12b14b.vhd}
read_vhdl $vhdl_infiles
current_design SspEncoder12b14b
#elaborate SspEncoder12b14b

create_clock -period 10 -name design_clk clk
link
uniquify

check_timing
check_design

# set power domain
create_power_domain PD
create_supply_net vdd -domain PD
create_supply_net gnd -domain PD
set_domain_supply_net -primary_power_net vdd -primary_ground_net gnd PD
set_voltage 1.08 -object_list vdd
set_voltage 0 -object_list gnd

# set_operating_conditions LTCOM
set_operating_conditions WCCOM
set_max_fanout 100 SspEncoder12b14b
# set_wire_load_model -library tcb013ghplt -name "TSMC8K_Fsg_Conservative"
set_wire_load_model -library tcb013ghpwc -name "TSMC8K_Fsg_Conservative"
compile_ultra
write -format verilog -hierarchy -output enc.v
write -format ddc -hierarchy -output enc.ddc
write_sdf enc.sdf
write_sdc enc.sdc
report_area -nosplit -hierarchy > area.rpt
report_timing -nosplit -transition_time -nets -attributes > timing.rpt
report_power -nosplit -hierarchy > power.rpt
