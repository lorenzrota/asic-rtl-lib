# Synopsys DC flow for ssp 12b14b encoder
# Authors: Faisal T. Abu-Nimeh
# Date: 20170927i
# ############ changed by Aseem on May 16, 2019 to match with Faisal flow done in April 2018

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
# set upf_create_implicit_supply_sets false
set_svf enc.svf

set src_dir ../../src/ssp12b14benc
#set vhdl_infiles {$src_dir/StdRtlPkg.vhd $src_dir/Code12b14bPkg.vhd $src_dir/SspFramer.vhd $src_dir/Encoder12b14b.vhd $src_dir/SspEncoder12b14b.vhd}
#### modified by Aseem G on May 16. 2019
set vhdl_infiles {$src_dir/StdRtlPkg.vhd $src_dir/Code12b14bPkg.vhd $src_dir/SspFramer.vhd $src_dir/Encoder12b14b.vhd $src_dir/SspEncoder12b14b.vhd $src_dir/ssp_enc12b14b_ext.vhd}
read_vhdl $vhdl_infiles
#current_design SspEncoder12b14b--------------------- added by Aseem G on May 16, 2019  to match with RTL Simulations
current_design ssp_enc12b14b_ext
#elaborate SspEncoder12b14b

###### added by Aseem G on May 16,2019 ##### 10ns =100MHz########
create_clock -period 10 -name design_clk clk_i
link
uniquify

check_timing
check_design

# set power domain
# create_power_domain PD
# create_supply_net vdd -domain PD
# create_supply_net gnd -domain PD
# set_domain_supply_net -primary_power_net vdd -primary_ground_net gnd PD
# set_voltage 1.08 -object_list vdd
# set_voltage 0 -object_list gnd

# set_operating_conditions LTCOM
set_operating_conditions WCCOM
#set_max_fanout 100 SspEncoder12b14b
set_max_fanout 100 ssp_enc12b14b_ext
# set_wire_load_model -library tcb013ghplt -name "TSMC8K_Fsg_Conservative"
set_wire_load_model -library tcb013ghpwc -name "TSMC8K_Fsg_Conservative"
# compile 
compile_ultra
set_svf -off
#write -format verilog -hierarchy -output enc.v
write -format verilog -hierarchy -output ssp_enc12b14b_ext_g.v
write -format ddc -hierarchy -output ssp_enc12b14b_ext_g.ddc
write_sdf ssp_enc12b14b_ext_g.sdf
write_sdc ssp_enc12b14b_ext_g.sdc
report_area -nosplit -hierarchy > area.rpt
report_timing -nosplit -transition_time -nets -attributes > timing.rpt
report_power -nosplit -hierarchy > power.rpt
