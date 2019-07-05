# ####################################################################

#  Created by Encounter(R) RTL Compiler RC14.28 - v14.20-s067_1 on Wed Jul 03 13:58:49 -0700 2019

# ####################################################################

set sdc_version 1.7

set_units -capacitance 1000.0fF
set_units -time 1000.0ps

# Set the current design
current_design ssp_enc12b14b_ext

create_clock -name "clk_i" -add -period 10.0 -waveform {0.0 5.0} [get_ports clk_i]
set_clock_gating_check -setup 0.0 
set_operating_conditions LTCOM
set_wire_load_selection_group "WireAreaForZero" -library "tcb013ghplt"
set_dont_use [get_lib_cells tcb013ghplt/ANTENNA]
set_dont_use [get_lib_cells tcb013ghplt/BHD]
set_dont_use [get_lib_cells tcb013ghplt/BUFFD20]
set_dont_use [get_lib_cells tcb013ghplt/BUFFD24]
set_dont_use [get_lib_cells tcb013ghplt/BUFTD20]
set_dont_use [get_lib_cells tcb013ghplt/BUFTD24]
set_dont_use [get_lib_cells tcb013ghplt/CKBD20]
set_dont_use [get_lib_cells tcb013ghplt/CKBD24]
set_dont_use [get_lib_cells tcb013ghplt/CKBXD20]
set_dont_use [get_lib_cells tcb013ghplt/CKBXD24]
set_dont_use [get_lib_cells tcb013ghplt/CKLHQD20]
set_dont_use [get_lib_cells tcb013ghplt/CKLHQD24]
set_dont_use [get_lib_cells tcb013ghplt/CKLNQD20]
set_dont_use [get_lib_cells tcb013ghplt/CKLNQD24]
set_dont_use [get_lib_cells tcb013ghplt/CKND20]
set_dont_use [get_lib_cells tcb013ghplt/CKND24]
set_dont_use [get_lib_cells tcb013ghplt/CKNXD20]
set_dont_use [get_lib_cells tcb013ghplt/CKNXD24]
set_dont_use [get_lib_cells tcb013ghplt/DCAP]
set_dont_use [get_lib_cells tcb013ghplt/DCAP4]
set_dont_use [get_lib_cells tcb013ghplt/DCAP8]
set_dont_use [get_lib_cells tcb013ghplt/DCAP16]
set_dont_use [get_lib_cells tcb013ghplt/DCAP32]
set_dont_use [get_lib_cells tcb013ghplt/DCAP64]
set_dont_use [get_lib_cells tcb013ghplt/DEL0]
set_dont_use [get_lib_cells tcb013ghplt/DEL005]
set_dont_use [get_lib_cells tcb013ghplt/DEL01]
set_dont_use [get_lib_cells tcb013ghplt/DEL015]
set_dont_use [get_lib_cells tcb013ghplt/DEL02]
set_dont_use [get_lib_cells tcb013ghplt/DEL1]
set_dont_use [get_lib_cells tcb013ghplt/DEL2]
set_dont_use [get_lib_cells tcb013ghplt/DEL3]
set_dont_use [get_lib_cells tcb013ghplt/DEL4]
set_dont_use [get_lib_cells tcb013ghplt/INVD20]
set_dont_use [get_lib_cells tcb013ghplt/INVD24]
set_dont_use [get_lib_cells tcb013ghplt/TIEH]
set_dont_use [get_lib_cells tcb013ghplt/TIEL]
