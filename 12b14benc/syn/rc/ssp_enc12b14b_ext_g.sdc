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
#set_wire_load_selection_group "WireAreaForZero" -library "tcb013ghp"
#set_dont_use [get_lib_cells tcb013ghp/ANTENNA]
#set_dont_use [get_lib_cells tcb013ghp/BHD]
#set_dont_use [get_lib_cells tcb013ghp/BUFFD20]
#set_dont_use [get_lib_cells tcb013ghp/BUFFD24]
#set_dont_use [get_lib_cells tcb013ghp/BUFTD20]
#set_dont_use [get_lib_cells tcb013ghp/BUFTD24]
#set_dont_use [get_lib_cells tcb013ghp/CKBD20]
#set_dont_use [get_lib_cells tcb013ghp/CKBD24]
#set_dont_use [get_lib_cells tcb013ghp/CKBXD20]
#set_dont_use [get_lib_cells tcb013ghp/CKBXD24]
#set_dont_use [get_lib_cells tcb013ghp/CKLHQD20]
#set_dont_use [get_lib_cells tcb013ghp/CKLHQD24]
#set_dont_use [get_lib_cells tcb013ghp/CKLNQD20]
#set_dont_use [get_lib_cells tcb013ghp/CKLNQD24]
#set_dont_use [get_lib_cells tcb013ghp/CKND20]
#set_dont_use [get_lib_cells tcb013ghp/CKND24]
#set_dont_use [get_lib_cells tcb013ghp/CKNXD20]
#set_dont_use [get_lib_cells tcb013ghp/CKNXD24]
#set_dont_use [get_lib_cells tcb013ghp/DCAP]
#set_dont_use [get_lib_cells tcb013ghp/DCAP4]
#set_dont_use [get_lib_cells tcb013ghp/DCAP8]
#set_dont_use [get_lib_cells tcb013ghp/DCAP16]
#set_dont_use [get_lib_cells tcb013ghp/DCAP32]
#set_dont_use [get_lib_cells tcb013ghp/DCAP64]
#set_dont_use [get_lib_cells tcb013ghp/DEL0]
#set_dont_use [get_lib_cells tcb013ghp/DEL005]
#set_dont_use [get_lib_cells tcb013ghp/DEL01]
#set_dont_use [get_lib_cells tcb013ghp/DEL015]
#set_dont_use [get_lib_cells tcb013ghp/DEL02]
#set_dont_use [get_lib_cells tcb013ghp/DEL1]
#set_dont_use [get_lib_cells tcb013ghp/DEL2]
#set_dont_use [get_lib_cells tcb013ghp/DEL3]
#set_dont_use [get_lib_cells tcb013ghp/DEL4]
#set_dont_use [get_lib_cells tcb013ghp/INVD20]
#set_dont_use [get_lib_cells tcb013ghp/INVD24]
#set_dont_use [get_lib_cells tcb013ghp/TIEH]
#set_dont_use [get_lib_cells tcb013ghp/TIEL]
