#!/usr/bin/env tcsh
#
# Example full-chip co-simulation using SV saci master and SPICE slave using Synopsys VCS
# Faisal T. Abu-Nimeh 20180722

# load vcs env variables
source /afs/slac/g/reseng/synopsys/vcs-mx/N-2017.12-1/settings.csh
source /afs/slac/g/reseng/synopsys/finesim/N-2017.12-2/settings.csh

# clean up some files
rm -rf AN.DB simv* csrc DVEfiles inter.vpd ucli.key .vlogansetup.args 64
rm -rf .vlogansetup.env

# compiler arguments
set cargs='-nc' # common arguments
set src=../../../src

# compile spice verilog wrapper
vlogan $cargs $src/SaciSlave2.v

# vhdl
vhdlan $cargs $src/StdRtlPkg.vhd
vhdlan $cargs $src/SaciSlaveRam.vhd
vhdlan $cargs $src/SaciSlaveWrapper.vhd

# compile sverilog tb
vlogan -sverilog $src/saci_master.sv $src/saci_master_tb.sv

# link example stimfile
ln -s $src/saci.stim .

vcs -ad=vcsAD.init -time ns -time_resolution 1ns -top saci_master_tb -debug_all -assert dve -lca

# Run
./simv -ucli -do vcs.ucli -l simv.log
