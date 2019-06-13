create_library_set -name default_library_set -timing /home/slac_designs/PPA/cryo_v2.0/tsmc130mm/TSMCHOME/digital/Front_End/timing_power_noise/NLDM/tcb013ghp_220a/tcb013ghplt.lib
create_rc_corner -name _default_rc_corner_ -T -40.0
update_rc_corner -name _default_rc_corner_ -cap_table /home/slac_designs/PPA/cryo_v2.0/tsmc130mm/TSMCHOME/digital/Back_End/lef/tcb013ghp_211a/techfiles/t013s8mg_fsg_v2.0b.cap
create_delay_corner -name _default_delay_corner_ -library_set default_library_set -opcond LTCOM  -opcond_library tcb013ghplt -rc_corner _default_rc_corner_
create_constraint_mode -name _default_constraint_mode_ -sdc_files {rc_enc_des/rc._default_constraint_mode_.sdc}
 
create_analysis_view -name _default_view_  -constraint_mode _default_constraint_mode_ -delay_corner _default_delay_corner_
 
 
set_analysis_view -setup _default_view_  -hold _default_view_
 
