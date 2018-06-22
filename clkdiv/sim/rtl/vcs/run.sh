#!/usr/bin/env tcsh
#
# Script to simulate and test a generic clock divider Synopsys VCS
# Faisal T. Abu-Nimeh 20171114

# load vcs env variables
source /afs/slac/g/reseng/synopsys/vcs-mx/M-2017.03-SP2/settings.csh

# clean up some files
rm -rf wlib simv* csrc DVEfiles inter.vpd ucli.key .vlogansetup.args
rm -rf .vlogansetup.env
# create work dir
mkdir -p wlib

# compiler arguments
set cargs='-nc' # common arguments
set src=../../../src

# compile vhd files
vhdlan $cargs $src/clkdiv.vhd
vhdlan $cargs $src/clkdiv_tb.vhd

# run the testbench
vcs $cargs clkdiv_tb -debug_all
# vcs clkdiv_tb -debug_all -R +vcs+vcdpluson -debug_pp

echo "\n\n### You can run\nvcs clkdiv_tb -debug_all -R -gui"
echo "\nor ./simv"
