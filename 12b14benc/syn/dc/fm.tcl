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

# set_app_var synopsys_auto_setup true

set_mismatch_message_filter -suppress FMR_VHDL-1002
# set_mismatch_message_filter -suppress FMR_VHDL-1014
set_mismatch_message_filter -suppress FMR_VHDL-1027
# set_mismatch_message_filter -suppress FMR_ELAB-149

set_svf enc.svf

read_db -technology_library tcb013ghpwc.db
read_vhdl -work_library WORK -r ../../src/ssp12b14benc/StdRtlPkg.vhd
read_vhdl -work_library WORK -r ../../src/ssp12b14benc/Code12b14bPkg.vhd
read_vhdl -work_library WORK -r ../../src/ssp12b14benc/SspFramer.vhd
read_vhdl -work_library WORK -r ../../src/ssp12b14benc/Encoder12b14b.vhd
read_vhdl -work_library WORK -r ../../src/ssp12b14benc/SspEncoder12b14b.vhd
set_top r:/WORK/SspEncoder12b14b

read_ddc -i ./enc.ddc
set_top i:/WORK/SspEncoder12b14b

# set_dont_verify r:/WORK/SspEncoder12b14b/Encoder12b14b_1_r_reg_DISPOUT__0_

match

report_unmatched_points > enc.fm.unmatched

if { ![verify] }  {
  save_session -replace enc.fm.sessionname
  report_failing_points > enc.fm.fp
  report_aborted > enc.fm.ap
  # Use analyze_points to help determine the next step in resolving verification
  # issues. It runs heuristic analysis to determine if there are potential causes
  # other than logical differences for failing or hard verification points.
  analyze_points -all > enc.fm.allpoints
}
