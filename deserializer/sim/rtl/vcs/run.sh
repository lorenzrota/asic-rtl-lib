#!/usr/bin/env tcsh
#
# Script to simulate and test a generic DDR serializer using Synopsys VCS
# Faisal T. Abu-Nimeh 20171109

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
vhdlan $cargs $src/serializer.vhd
vhdlan $cargs $src/sync.vhd
vhdlan $cargs $src/deserializer.vhd
vhdlan $cargs $src/deserializer_tb.vhd

# run the testbench
vcs $cargs deserializer_tb -debug_all
# vcs deserializer_tb -debug_all -R +vcs+vcdpluson -debug_pp

echo "\n\n### You can run\nvcs deserializer_tb -debug_all -R -gui"
echo "\nor ./simv"
