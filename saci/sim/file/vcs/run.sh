#!/usr/bin/env tcsh
#
# Script to simulate saci master and slave using Synopsys VCS
# Faisal T. Abu-Nimeh 20180712

# load vcs env variables
source /afs/slac/g/reseng/synopsys/vcs-mx/N-2017.12-1/settings.csh

# clean up some files
rm -rf AN.DB simv* csrc DVEfiles inter.vpd ucli.key .vlogansetup.args 64
rm -rf .vlogansetup.env

# compiler arguments
set cargs='-nc' # common arguments
set src=../../../src

# compile vhd files
vhdlan $cargs $src/StdRtlPkg.vhd $src/SaciSlaveRam.vhd $src/SaciSlave2.vhd $src/SaciSlaveWrapper.vhd

# compile sv files
vlogan -sverilog $src/saci_master.sv $src/saci_master_tb.sv

# link example stimfile
ln -s $src/saci.stim .

# run the testbench
vcs -debug_all -assert dve saci_master_tb
echo "\n# Run ./simv or ./simv -gui"
