create_library_set -name WCCOM\
   -timing\
    [list ../../../../../tsmc130mm/TSMCHOME/digital/Front_End/timing_power_noise/NLDM/tcb013ghp_220a/tcb013ghpwc.lib]\
   -si\
    [list ../../../../../tsmc130mm/TSMCHOME/digital/Back_End/celtic/tcb013ghp_211a/tcb013ghpwc.cdb]
create_library_set -name LTCOM\
   -timing\
    [list ../../../../../tsmc130mm/TSMCHOME/digital/Front_End/timing_power_noise/NLDM/tcb013ghp_220a/tcb013ghplt.lib]\
   -si\
    [list ../../../../../tsmc130mm/TSMCHOME/digital/Back_End/celtic/tcb013ghp_211a/tcb013ghplt.cdb]
create_library_set -name BCCOM\
   -timing\
    [list ../../../../../tsmc130mm/TSMCHOME/digital/Front_End/timing_power_noise/NLDM/tcb013ghp_220a/tcb013ghpbc.lib]\
   -si\
    [list ../../../../../tsmc130mm/TSMCHOME/digital/Back_End/celtic/tcb013ghp_211a/tcb013ghpbc.cdb]
create_rc_corner -name default_rc_corner\
   -preRoute_res 1\
   -postRoute_res 1\
   -preRoute_cap 1\
   -postRoute_cap 1\
   -postRoute_xcap 1\
   -preRoute_clkres 0\
   -preRoute_clkcap 0
create_delay_corner -name WCCOM\
   -library_set WCCOM
create_constraint_mode -name CLK_SDC\
   -sdc_files\
    [list ../../syn/rc/ssp_enc12b14b_ext_g.sdc]
create_analysis_view -name WCCOM -constraint_mode CLK_SDC -delay_corner WCCOM
set_analysis_view -setup [list WCCOM] -hold [list WCCOM]
