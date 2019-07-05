#####################################################################
#
# RTL Compiler setup file
# Created by Encounter(R) RTL Compiler RC14.28 - v14.20-s067_1
#   on 07/03/2019 13:58:49
#
#
#####################################################################


# This script is intended for use with RTL Compiler version RC14.28 - v14.20-s067_1


# Remove Existing Design
###########################################################
if {[find -design /designs/ssp_enc12b14b_ext] ne ""} {
  puts "** A design with the same name is already loaded. It will be removed. **"
  rm /designs/ssp_enc12b14b_ext
}


# Libraries
###########################################################
set_attribute library {/home/slac_designs/PPA/cryo_v2.0/tsmc130mm/TSMCHOME/digital/Front_End/timing_power_noise/NLDM/tcb013ghp_220a/tcb013ghplt.lib {}} /

set_attribute lef_library {/home/slac_designs/PPA/cryo_v2.0/tsmc130mm/TSMCHOME/digital/Back_End/lef/tcb013ghp_211a/lef/tsmc013gFsg_8lm.lef /home/slac_designs/PPA/cryo_v2.0/tsmc130mm/TSMCHOME/digital/Back_End/lef/tcb013ghp_211a/lef/tcb013ghp.lef} /
set_attribute cap_table_file /home/slac_designs/PPA/cryo_v2.0/tsmc130mm/TSMCHOME/digital/Back_End/lef/tcb013ghp_211a/techfiles/t013s8mg_fsg_v2.0b.cap /


# Design
###########################################################
read_netlist -top ssp_enc12b14b_ext rc_enc_des/rc.v

source rc_enc_des/rc.g
puts "\n** Restoration Completed **\n"


# Data Integrity Check
###########################################################
# program version
if {"[string_representation [get_attribute program_version /]]" != "{RC14.28 - v14.20-s067_1}"} {
   mesg_send [find -message /messages/PHYS/PHYS-91] "golden program_version: {RC14.28 - v14.20-s067_1}  current program_version: [string_representation [get_attribute program_version /]]"
}
# license
if {"[string_representation [get_attribute startup_license /]]" != "Genus_Synthesis"} {
   mesg_send [find -message /messages/PHYS/PHYS-91] "golden license: Genus_Synthesis  current license: [string_representation [get_attribute startup_license /]]"
}
# slack
set _slk_ [get_attribute slack /designs/ssp_enc12b14b_ext]
if {[regexp {^-?[0-9.]+$} $_slk_]} {
  set _slk_ [format %.1f $_slk_]
}
if {$_slk_ != "5751.6"} {
   mesg_send [find -message /messages/PHYS/PHYS-92] "golden slack: 5751.6,  current slack: $_slk_"
}
unset _slk_
# multi-mode slack
# tns
set _tns_ [get_attribute tns /designs/ssp_enc12b14b_ext]
if {[regexp {^-?[0-9.]+$} $_tns_]} {
  set _tns_ [format %.0f $_tns_]
}
if {$_tns_ != "0"} {
   mesg_send [find -message /messages/PHYS/PHYS-92] "golden tns: 0,  current tns: $_tns_"
}
unset _tns_
# cell area
set _cell_area_ [get_attribute cell_area /designs/ssp_enc12b14b_ext]
if {[regexp {^-?[0-9.]+$} $_cell_area_]} {
  set _cell_area_ [format %.0f $_cell_area_]
}
if {$_cell_area_ != "7694"} {
   mesg_send [find -message /messages/PHYS/PHYS-92] "golden cell area: 7694,  current cell area: $_cell_area_"
}
unset _cell_area_
# net area
set _net_area_ [get_attribute net_area /designs/ssp_enc12b14b_ext]
if {[regexp {^-?[0-9.]+$} $_net_area_]} {
  set _net_area_ [format %.0f $_net_area_]
}
if {$_net_area_ != "5131"} {
   mesg_send [find -message /messages/PHYS/PHYS-92] "golden net area: 5131,  current net area: $_net_area_"
}
unset _net_area_
