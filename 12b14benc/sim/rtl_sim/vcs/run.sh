#!/usr/bin/env tcsh
#
# Script to simulate and test 12b14b encoder using Synopsys VCS
# Faisal T. Abu-Nimeh 20171005

# load vcs env variables
source /afs/slac/g/reseng/synopsys/vcs-mx/M-2017.03-SP2/settings.csh

# clean up some files
rm -rf wlib simv* csrc DVEfiles inter.vpd ucli.key .vlogansetup.args
rm -rf .vlogansetup.env
# create work dir
mkdir -p wlib

# compiler arguments
set cargs='-nc' # common arguments

# compile vhd files
vhdlan $cargs ../src/ssp/StdRtlPkg.vhd
vhdlan $cargs ../src/ssp/Code12b14bPkg.vhd
vhdlan $cargs ../src/ssp/Encoder12b14b.vhd
vhdlan $cargs ../src/ssp/SspFramer.vhd
vhdlan $cargs ../src/ssp/SspDeframer.vhd
vhdlan $cargs ../src/ssp/Decoder12b14b.vhd
vhdlan $cargs ../src/ssp/SspDecoder12b14b.vhd
vhdlan $cargs ../src/ssp/SspEncoder12b14b.vhd
vhdlan $cargs ../src/ssp/syncbus.vhd

# compile verilog files
vlogan $cargs ../src/verilog-lfsr/rtl/lfsr.v
vlogan $cargs ../src/verilog-lfsr/rtl/lfsr_prbs_gen.v

# This is the top
vhdlan $cargs ../src/ssp/ssp12b14b_tb.vhd

# run the testbench
vcs $cargs ssp12b14b_tb -debug_all

echo "\n\n### You can run\nvcs ssp12b14b_tb -debug_all -R -gui"
echo "\nor ./simv"
