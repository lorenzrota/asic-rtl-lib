#!/usr/bin/env tcsh
#
# Script to simulate and test 12b14b encoder using Synopsys VCS
# Faisal T. Abu-Nimeh 20171005

# load vcs env variables
source /afs/slac/g/reseng/synopsys/vcs-mx/N-2017.12-1/settings.csh

# clean up some files
rm -rf wlib simv* csrc DVEfiles inter.vpd ucli.key .vlogansetup.args
rm -rf .vlogansetup.env
# create work dir
mkdir -p wlib

# compiler arguments
set cargs='-full64 -nc' # common arguments
set src=../../../src/ssp12b14benc
set vsrc=../../../src/verilog-lfsr/rtl

# compile vhd files
vhdlan $cargs $src/StdRtlPkg.vhd
vhdlan $cargs $src/Code12b14bPkg.vhd
vhdlan $cargs $src/Encoder12b14b.vhd
vhdlan $cargs $src/SspFramer.vhd
vhdlan $cargs $src/SspDeframer.vhd
vhdlan $cargs $src/Decoder12b14b.vhd
vhdlan $cargs $src/SspDecoder12b14b.vhd
vhdlan $cargs $src/SspEncoder12b14b.vhd
vhdlan $cargs $src/syncbus.vhd
vhdlan $cargs $src/ssp_enc12b14b_ext.vhd

# compile verilog files
vlogan $cargs $vsrc/lfsr.v
vlogan $cargs $vsrc/lfsr_prbs_gen.v

# This is the top
vhdlan $cargs $src/ssp_enc12b14b_ext_tb.vhd

# run the testbench
vcs $cargs ssp_enc12b14b_ext_tb -debug_all
# vcs ssp12b14b_tb -debug_all -R +vcs+vcdpluson -debug_pp

echo "\n\n### You can run\nvcs ssp_enc12b14b_ext_tb -full64 -debug_all -R -gui"
echo "\nor ./simv"
