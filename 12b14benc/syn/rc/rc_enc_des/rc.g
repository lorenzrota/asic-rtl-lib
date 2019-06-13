######################################################################

# Created by Encounter(R) RTL Compiler RC14.28 - v14.20-s067_1 on Tue Jun 11 14:54:03 -0400 2019

# This file contains the RC script for /designs/ssp_enc12b14b_ext

######################################################################

set_attribute -quiet runtime_by_stage { {global_incr_map 0 81 0 76}  {incr_opt 1 82 0 77} } /
set_attribute -quiet print_error_info true /
set_attribute -quiet gui_auto_update false /
set_attribute -quiet use_area_from_lef true /
set_attribute -quiet phys_use_segment_parasitics true /
set_attribute -quiet probabilistic_extraction true /
set_attribute -quiet ple_correlation_factors {1.9000 2.0000} /
set_attribute -quiet maximum_interval_of_vias infinity /
set_attribute -quiet ple_mode global /
set_attribute -quiet operating_conditions LTCOM /
set_attribute -quiet wireload_selection /libraries/tcb013ghplt/wireload_selections/WireAreaForZero /
set_attribute -quiet tree_type balanced_tree /libraries/tcb013ghplt/operating_conditions/LTCOM
set_attribute -quiet tree_type balanced_tree /libraries/tcb013ghplt/operating_conditions/_nominal_
# BEGIN MSV SECTION
# END MSV SECTION
define_clock -name clk_i -domain domain_1 -period 10000.0 -divide_period 1 -rise 0 -divide_rise 1 -fall 1 -divide_fall 2 -design /designs/ssp_enc12b14b_ext /designs/ssp_enc12b14b_ext/ports_in/clk_i
define_cost_group -design /designs/ssp_enc12b14b_ext -name clk_i
external_delay -accumulate -input {0.0 no_value 0.0 no_value} -clock /designs/ssp_enc12b14b_ext/timing/clock_domains/domain_1/clk_i -name create_clock_delay_domain_1_clk_i_R_0 /designs/ssp_enc12b14b_ext/ports_in/clk_i
set_attribute -quiet clock_network_latency_included true /designs/ssp_enc12b14b_ext/timing/external_delays/create_clock_delay_domain_1_clk_i_R_0
external_delay -accumulate -input {no_value 0.0 no_value 0.0} -clock /designs/ssp_enc12b14b_ext/timing/clock_domains/domain_1/clk_i -edge_fall -name create_clock_delay_domain_1_clk_i_F_0 /designs/ssp_enc12b14b_ext/ports_in/clk_i
set_attribute -quiet clock_network_latency_included true /designs/ssp_enc12b14b_ext/timing/external_delays/create_clock_delay_domain_1_clk_i_F_0
path_group -paths [specify_paths -to /designs/ssp_enc12b14b_ext/timing/clock_domains/domain_1/clk_i]  -name clk_i -group /designs/ssp_enc12b14b_ext/timing/cost_groups/clk_i -user_priority -1047552
# BEGIN DFT SECTION
set_attribute -quiet dft_scan_style muxed_scan /
set_attribute -quiet dft_scanbit_waveform_analysis false /
# END DFT SECTION
set_attribute -quiet hdl_user_name ssp_enc12b14b_ext /designs/ssp_enc12b14b_ext
set_attribute -quiet hdl_filelist {{default -vhdl1993 {SYNTHESIS} {../../src/ssp12b14benc/StdRtlPkg.vhd ../../src/ssp12b14benc/Code12b14bPkg.vhd ../../src/ssp12b14benc/SspFramer.vhd ../../src/ssp12b14benc/Encoder12b14b.vhd ../../src/ssp12b14benc/SspEncoder12b14b.vhd ../../src/ssp12b14benc/ssp_enc12b14b_ext.vhd} {}}} /designs/ssp_enc12b14b_ext
set_attribute -quiet seq_reason_deleted {{{U_SspEncoder12b14b/SspFramer_1/r[eof]} unloaded} {{U_SspEncoder12b14b/SspFramer_1/r[eofLast]} unloaded} {{U_SspEncoder12b14b/SspFramer_1/r[readyIn]} unloaded} {{U_SspEncoder12b14b/Encoder12b14b_1/r[readyIn]} unloaded} {{U_SspEncoder12b14b/SspFramer_1/r_reg[validOut]} unloaded} {{U_SspEncoder12b14b/Encoder12b14b_1/r_reg[validOut]} unloaded}} /designs/ssp_enc12b14b_ext
set_attribute -quiet rc_current_verification_directory fv/ssp_enc12b14b_ext /designs/ssp_enc12b14b_ext
set_attribute -quiet arch_filename ../../src/ssp12b14benc/ssp_enc12b14b_ext.vhd /designs/ssp_enc12b14b_ext
set_attribute -quiet entity_filename ../../src/ssp12b14benc/ssp_enc12b14b_ext.vhd /designs/ssp_enc12b14b_ext
set_attribute -quiet hdl_user_name SspEncoder12b14b /designs/ssp_enc12b14b_ext/subdesigns/SspEncoder12b14b_RST_POLARITY_G0_RST_ASYNC_G1_AUTO_FRAME_G1_FLOW_CTRL_EN_G0
set_attribute -quiet hdl_filelist {{default -vhdl1993 {SYNTHESIS} {../../src/ssp12b14benc/StdRtlPkg.vhd ../../src/ssp12b14benc/Code12b14bPkg.vhd ../../src/ssp12b14benc/SspFramer.vhd ../../src/ssp12b14benc/Encoder12b14b.vhd ../../src/ssp12b14benc/SspEncoder12b14b.vhd} {}}} /designs/ssp_enc12b14b_ext/subdesigns/SspEncoder12b14b_RST_POLARITY_G0_RST_ASYNC_G1_AUTO_FRAME_G1_FLOW_CTRL_EN_G0
set_attribute -quiet arch_filename ../../src/ssp12b14benc/SspEncoder12b14b.vhd /designs/ssp_enc12b14b_ext/subdesigns/SspEncoder12b14b_RST_POLARITY_G0_RST_ASYNC_G1_AUTO_FRAME_G1_FLOW_CTRL_EN_G0
set_attribute -quiet entity_filename ../../src/ssp12b14benc/SspEncoder12b14b.vhd /designs/ssp_enc12b14b_ext/subdesigns/SspEncoder12b14b_RST_POLARITY_G0_RST_ASYNC_G1_AUTO_FRAME_G1_FLOW_CTRL_EN_G0
set_attribute -quiet is_sop_cluster true /designs/ssp_enc12b14b_ext/subdesigns/Encoder12b14b_RST_POLARITY_G0_RST_ASYNC_G1_DEBUG_DISP_G0_FLOW_CTRL_EN_G0
set_attribute -quiet hdl_user_name Encoder12b14b /designs/ssp_enc12b14b_ext/subdesigns/Encoder12b14b_RST_POLARITY_G0_RST_ASYNC_G1_DEBUG_DISP_G0_FLOW_CTRL_EN_G0
set_attribute -quiet hdl_filelist {{default -vhdl1993 {SYNTHESIS} {../../src/ssp12b14benc/StdRtlPkg.vhd ../../src/ssp12b14benc/Code12b14bPkg.vhd ../../src/ssp12b14benc/Encoder12b14b.vhd} {}}} /designs/ssp_enc12b14b_ext/subdesigns/Encoder12b14b_RST_POLARITY_G0_RST_ASYNC_G1_DEBUG_DISP_G0_FLOW_CTRL_EN_G0
set_attribute -quiet arch_filename ../../src/ssp12b14benc/Encoder12b14b.vhd /designs/ssp_enc12b14b_ext/subdesigns/Encoder12b14b_RST_POLARITY_G0_RST_ASYNC_G1_DEBUG_DISP_G0_FLOW_CTRL_EN_G0
set_attribute -quiet entity_filename ../../src/ssp12b14benc/Encoder12b14b.vhd /designs/ssp_enc12b14b_ext/subdesigns/Encoder12b14b_RST_POLARITY_G0_RST_ASYNC_G1_DEBUG_DISP_G0_FLOW_CTRL_EN_G0
set_attribute -quiet hdl_user_name SspFramer /designs/ssp_enc12b14b_ext/subdesigns/SspFramer_RST_POLARITY_G0_RST_ASYNC_G1_AUTO_FRAME_G1_FLOW_CTRL_EN_G0_WORD_SIZE_G12_K_SIZE_G1_SSP_IDLE_CODE_G1528_11_downto_0_SSP_IDLE_K_G1_0_to_0_SSP_SOF_CODE_G120_11_downto_0_SSP_SOF_K_G1_0_to_0_SSP_EOF_CODE_G248_11_downto_0_SSP_EOF_K_G1_0_to_0
set_attribute -quiet hdl_filelist {{default -vhdl1993 {SYNTHESIS} {../../src/ssp12b14benc/StdRtlPkg.vhd ../../src/ssp12b14benc/SspFramer.vhd} {}}} /designs/ssp_enc12b14b_ext/subdesigns/SspFramer_RST_POLARITY_G0_RST_ASYNC_G1_AUTO_FRAME_G1_FLOW_CTRL_EN_G0_WORD_SIZE_G12_K_SIZE_G1_SSP_IDLE_CODE_G1528_11_downto_0_SSP_IDLE_K_G1_0_to_0_SSP_SOF_CODE_G120_11_downto_0_SSP_SOF_K_G1_0_to_0_SSP_EOF_CODE_G248_11_downto_0_SSP_EOF_K_G1_0_to_0
set_attribute -quiet arch_filename ../../src/ssp12b14benc/SspFramer.vhd /designs/ssp_enc12b14b_ext/subdesigns/SspFramer_RST_POLARITY_G0_RST_ASYNC_G1_AUTO_FRAME_G1_FLOW_CTRL_EN_G0_WORD_SIZE_G12_K_SIZE_G1_SSP_IDLE_CODE_G1528_11_downto_0_SSP_IDLE_K_G1_0_to_0_SSP_SOF_CODE_G120_11_downto_0_SSP_SOF_K_G1_0_to_0_SSP_EOF_CODE_G248_11_downto_0_SSP_EOF_K_G1_0_to_0
set_attribute -quiet entity_filename ../../src/ssp12b14benc/SspFramer.vhd /designs/ssp_enc12b14b_ext/subdesigns/SspFramer_RST_POLARITY_G0_RST_ASYNC_G1_AUTO_FRAME_G1_FLOW_CTRL_EN_G0_WORD_SIZE_G12_K_SIZE_G1_SSP_IDLE_CODE_G1528_11_downto_0_SSP_IDLE_K_G1_0_to_0_SSP_SOF_CODE_G120_11_downto_0_SSP_SOF_K_G1_0_to_0_SSP_EOF_CODE_G248_11_downto_0_SSP_EOF_K_G1_0_to_0
