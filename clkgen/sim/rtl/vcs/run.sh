#!/usr/bin/env tcsh
#
# Script to simulate and test a generic clock divider Synopsys VCS
# Faisal T. Abu-Nimeh 20171114

# load vcs env variables
source /afs/slac/g/reseng/synopsys/vcs-mx/N-2017.12-1/settings.csh

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
vhdlan $cargs $src/pulsegen.vhd
vhdlan $cargs $src/clkgen.vhd
vhdlan $cargs $src/clkgen_tb.vhd

# run the testbench
vcs $cargs clkgen_tb -debug_all
# vcs clkgen_tb -debug_all -R +vcs+vcdpluson -debug_pp

echo "\n\n### You can run\nvcs clkgen_tb -debug_all -R -gui"
echo "\nor ./simv"
