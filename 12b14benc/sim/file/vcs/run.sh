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
set src=../../../src/ssp12b14benc

# compile vhd files
vhdlan $cargs $src/StdRtlPkg.vhd
vhdlan $cargs $src/Code12b14bPkg.vhd
vhdlan $cargs $src/SspDeframer.vhd
vhdlan $cargs $src/Decoder12b14b.vhd
vhdlan $cargs $src/SspDecoder12b14b.vhd

# This is the top
vhdlan $cargs $src/decodefile.vhd

# run the testbench
vcs $cargs decodefile -debug_all
# vcs decodefile -debug_all -R +vcs+vcdpluson -debug_pp

echo "\n\n### You can run\nvcs decodefile -debug_all -R -gui"
echo "\nor ./simv"
