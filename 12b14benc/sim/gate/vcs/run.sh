#!/usr/bin/env tcsh
#
# Script to simulate and test 12b14b encoder using Synopsys VCS
# Faisal T. Abu-Nimeh 20171005

# load vcs env variables
#source /afs/slac/g/reseng/synopsys/vcs-mx/M-2017.03-SP2/settings.csh
#source /afs/slac.stanford.edu/g/reseng/synopsys/vcs-mx/N-2017.12-1/settings.csh
setenv TSMC130_DIR /afs/slac.stanford.edu/g/airic/cryo/tsmc130mm/TSMCHOME/digital

# clean up some files
rm -rf wlib simv* csrc DVEfiles inter.vpd ucli.key .vlogansetup.args
rm -rf .vlogansetup.env
# create work dir
mkdir -p wlib

# compiler arguments
set cargs='-nc' # common arguments
set src=../../../src/ssp12b14benc
set vsrc=../../../src/verilog-lfsr/rtl
set gsrc=../../../syn/dc
# compile vhd files
vhdlan $cargs $src/StdRtlPkg.vhd
vhdlan $cargs $src/Code12b14bPkg.vhd
vhdlan $cargs $src/Encoder12b14b.vhd
vhdlan $cargs $src/SspFramer.vhd
vhdlan $cargs $src/SspDeframer.vhd
vhdlan $cargs $src/Decoder12b14b.vhd
vhdlan $cargs $src/SspDecoder12b14b.vhd
# vhdlan $cargs $src/SspEncoder12b14b.vhd
# modified by Aseem G on May 16, 2019
#vhdlan $cargs $src/SspEncoder12b14b.vhd
vhdlan $cargs $src/syncbus.vhd

# compile verilog files
vlogan $cargs $vsrc/lfsr.v
vlogan $cargs $vsrc/lfsr_prbs_gen.v
# std verilog
vlogan $cargs $TSMC130_DIR/Front_End/verilog/tcb013ghp_220a/tcb013ghp.v
# gate-level file
#vlogan $cargs $gsrc/enc.v
##--------cadence file instead------
vlogan $gsrc/ssp_enc12b14b_ext_g_cad.v

# This is the top
vhdlan $cargs $src/ssp12b14b_g_tb.vhd

# run the testbench
vcs $cargs ssp12b14b_g_tb -debug_all
echo "\n\n### You can run\nvcs ssp12b14b_g_tb -debug_all -R -gui"
echo "\nor ./simv"
